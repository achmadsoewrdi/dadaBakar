import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../projects/domain/models/project_model.dart';
import '../../domain/entities/blynk_widget_entity.dart';
import '../widgets/blynk_chart_widget.dart';
import '../widgets/blynk_gauge_widget.dart';
import '../widgets/blynk_switch_widget.dart';
import '../widgets/blynk_value_widget.dart';
import '../widgets/add_widget_modal.dart';
import '../../../../core/services/device_connection_service.dart';

class BlynkCanvasScreen extends StatefulWidget {
  final ProjectModel project;
  final ValueChanged<ProjectModel>? onSaveBlynkConfig;
  final bool isEmbedded;

  const BlynkCanvasScreen({
    super.key,
    required this.project,
    this.onSaveBlynkConfig,
    this.isEmbedded = false,
  });

  @override
  State<BlynkCanvasScreen> createState() => _BlynkCanvasScreenState();
}

class _BlynkCanvasScreenState extends State<BlynkCanvasScreen> {
  late List<ValueNotifier<BlynkWidgetEntity>> _widgetNotifiers;
  final Map<String, List<double>> _chartHistories = {};

  bool _isEditMode = false;
  Timer? _telemetryTimer;
  Timer? _autoSaveTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initWidgetsFromConfig();
    _startLiveSimulation();
    _startAutoSave();
  }

  @override
  void didUpdateWidget(BlynkCanvasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.project.blynkConfigJson != oldWidget.project.blynkConfigJson) {
      // Avoid overwriting local changes if edit mode is active
      if (!_isEditMode) {
        _initWidgetsFromConfig();
      }
    }
  }

  void _initWidgetsFromConfig() {
    if (widget.project.blynkConfigJson != null && widget.project.blynkConfigJson!.isNotEmpty) {
      _widgetNotifiers = widget.project.blynkConfigJson!
          .map((json) => ValueNotifier(BlynkWidgetEntity.fromJson(json)))
          .toList();
    } else {
      // Default initial Blynk widgets if freshly created
      _widgetNotifiers = [];
    }

    // Initialize chart telemetry histories
    for (var notifier in _widgetNotifiers) {
      final w = notifier.value;
      if (w.type == BlynkWidgetType.chart) {
        _chartHistories[w.id] = [28.0, 28.5, 29.0, 29.2, 28.8, 29.5];
      }
    }
  }

  void _startLiveSimulation() {
    _telemetryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      
      for (int i = 0; i < _widgetNotifiers.length; i++) {
        final notifier = _widgetNotifiers[i];
        final w = notifier.value;
        if (w.type == BlynkWidgetType.chart || w.type == BlynkWidgetType.gauge || w.type == BlynkWidgetType.value) {
          double delta = (_random.nextDouble() - 0.5) * 0.8;
          double newVal = (w.currentValueNum + delta).clamp(w.minValue, w.maxValue);
          
          if (w.type == BlynkWidgetType.chart) {
            final list = _chartHistories[w.id] ?? [];
            list.add(newVal);
            if (list.length > 20) list.removeAt(0);
            _chartHistories[w.id] = list;
          }
          
          notifier.value = w.copyWith(currentValueNum: double.parse(newVal.toStringAsFixed(1)));
        }
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      _saveConfiguration(silent: true);
    });
  }

  void _saveConfiguration({bool silent = false}) {
    final updatedJson = _widgetNotifiers.map((n) => n.value.toJson()).toList();
    final updatedProject = widget.project.copyWith(blynkConfigJson: updatedJson);

    if (widget.onSaveBlynkConfig != null) {
      widget.onSaveBlynkConfig!(updatedProject);
    }

    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Layout Blynk IoT berhasil disimpan!'),
          backgroundColor: const Color(0xFF005CFF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  void _showAddWidgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWidgetModal(
        onWidgetAdded: (newWidget) {
          setState(() {
            _widgetNotifiers.add(ValueNotifier(newWidget));
            if (newWidget.type == BlynkWidgetType.chart) {
              _chartHistories[newWidget.id] = [25.0, 26.0, 27.0];
            }
          });
          _saveConfiguration();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = Column(
      children: [
        // Status Header
        _buildStatusHeader(),
        const SizedBox(height: 24),

        // Canvas Title & Add Widget
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kanvas IoT Real-Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A122C),
              ),
            ),
            Row(
              children: [
                if (widget.isEmbedded)
                  IconButton(
                    icon: Icon(
                      _isEditMode ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                      color: _isEditMode ? const Color(0xFFFF9F1C) : Colors.grey,
                      size: 26,
                    ),
                    tooltip: _isEditMode ? 'Selesai Edit' : 'Edit Mode',
                    onPressed: () {
                      setState(() {
                        _isEditMode = !_isEditMode;
                      });
                      if (!_isEditMode) {
                        _saveConfiguration();
                      }
                    },
                  ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _showAddWidgetModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('+ Widget', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_widgetNotifiers.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _widgetNotifiers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return ValueListenableBuilder<BlynkWidgetEntity>(
                valueListenable: _widgetNotifiers[index],
                builder: (context, w, child) {
                  final color = Color(w.primaryColorHex);
                  return _buildWidgetCard(w, color, index);
                },
              );
            },
          ),
      ],
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF005CFF), Color(0xFF00C2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.project.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              'Blynk IoT Canvas Studio',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          // Edit / Save Mode Toggle
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.check_circle_rounded : Icons.edit_note_rounded,
              color: _isEditMode ? const Color(0xFFFF9F1C) : Colors.white,
              size: 26,
            ),
            tooltip: _isEditMode ? 'Selesai Edit' : 'Edit Mode',
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
              if (!_isEditMode) {
                _saveConfiguration();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
        child: bodyContent,
      ),
    );
  }

  Widget _buildStatusHeader() {
    return ListenableBuilder(
      listenable: DeviceConnectionService.instance,
      builder: (context, _) {
        final connService = DeviceConnectionService.instance;
        String? displayLabel;

    if (connService.connectedDeviceId != null) {
      try {
        final connectedDevice = connService.savedDevices.firstWhere(
            (d) => d.id == connService.connectedDeviceId);
        displayLabel = connectedDevice.label;
      } catch (_) {}
    }
    
    if (displayLabel == null) {
      if (connService.connectionMode == ConnectionMode.bluetooth && connService.selectedDevice != null) {
        displayLabel = connService.selectedDevice!.name;
      } else if (connService.connectedIp != null) {
        displayLabel = connService.connectedIp;
      }
    }

    if (displayLabel == null) {
      final projectDeviceTypeClean = widget.project.deviceType.replaceAll('_', ' ').toLowerCase();
      try {
        final matchingDevice = connService.savedDevices.firstWhere(
            (d) => d.label.toLowerCase().contains(projectDeviceTypeClean));
        displayLabel = matchingDevice.label;
      } catch (_) {}
    }

    if (displayLabel == null) {
      displayLabel = widget.project.deviceType.replaceAll('_', ' ').toUpperCase();
      if (widget.project.deviceType == 'raspberry_pi') displayLabel = 'RASPBERRY PI';
      if (widget.project.deviceType == 'orange_pi') displayLabel = 'ORANGE PI';
    } else {
      displayLabel = displayLabel.toUpperCase();
    }
    
        final deviceNameDisplay = displayLabel;
        final isOnline = connService.isConnected;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF005CFF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sensors_rounded, color: Color(0xFF005CFF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Target Device: $deviceNameDisplay',
                        style: const TextStyle(color: Color(0xFF0A122C), fontWeight: FontWeight.w900, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isOnline ? const Color(0xFF00E3A2) : Colors.red).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isOnline ? 'ONLINE' : 'OFFLINE', 
                        style: TextStyle(
                          color: isOnline ? const Color(0xFF00E3A2) : Colors.red, 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_widgetNotifiers.length} Widget Terpasang • Synced Live',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

  Widget _buildWidgetCard(BlynkWidgetEntity w, Color color, int index) {
    VoidCallback? onDeleteAction = _isEditMode
        ? () {
            setState(() {
              _widgetNotifiers.removeAt(index);
            });
            _saveConfiguration();
          }
        : null;

    switch (w.type) {
      case BlynkWidgetType.chart:
        return BlynkChartWidget(
          title: w.title,
          pin: w.sensorPin,
          history: _chartHistories[w.id] ?? [w.currentValueNum],
          themeColor: color,
          unit: w.unit,
          onDelete: onDeleteAction,
        );
      case BlynkWidgetType.gauge:
        return BlynkGaugeWidget(
          title: w.title,
          pin: w.sensorPin,
          value: w.currentValueNum,
          maxValue: w.maxValue,
          unit: w.unit,
          themeColor: color,
          onDelete: onDeleteAction,
        );
      case BlynkWidgetType.toggle:
        return BlynkSwitchWidget(
          title: w.title,
          pin: w.sensorPin,
          value: w.currentValueBool,
          themeColor: color,
          onDelete: onDeleteAction,
          onChanged: (val) {
            _widgetNotifiers[index].value = w.copyWith(currentValueBool: val);
          },
        );
      case BlynkWidgetType.value:
        return BlynkValueWidget(
          title: w.title,
          pin: w.sensorPin,
          value: w.currentValueNum,
          unit: w.unit,
          themeColor: color,
          onDelete: onDeleteAction,
        );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.widgets_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'Belum ada Widget Blynk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A122C)),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan tombol + Widget di atas untuk menambahkan grafik atau sakelar!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
