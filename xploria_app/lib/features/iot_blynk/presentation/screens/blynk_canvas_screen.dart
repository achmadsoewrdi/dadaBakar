import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../projects/domain/models/project_model.dart';
import '../../domain/entities/blynk_widget_entity.dart';
import '../widgets/blynk_chart_widget.dart';
import '../widgets/blynk_gauge_widget.dart';
import '../widgets/blynk_switch_widget.dart';
import '../widgets/blynk_value_widget.dart';
import '../widgets/add_widget_modal.dart';

class BlynkCanvasScreen extends StatefulWidget {
  final ProjectModel project;
  final ValueChanged<ProjectModel>? onSaveBlynkConfig;

  const BlynkCanvasScreen({
    super.key,
    required this.project,
    this.onSaveBlynkConfig,
  });

  @override
  State<BlynkCanvasScreen> createState() => _BlynkCanvasScreenState();
}

class _BlynkCanvasScreenState extends State<BlynkCanvasScreen> {
  late List<BlynkWidgetEntity> _widgets;
  final Map<String, List<double>> _chartHistories = {};

  bool _isEditMode = false;
  Timer? _telemetryTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initWidgetsFromConfig();
    _startLiveSimulation();
  }

  void _initWidgetsFromConfig() {
    if (widget.project.blynkConfigJson != null && widget.project.blynkConfigJson!.isNotEmpty) {
      _widgets = widget.project.blynkConfigJson!
          .map((json) => BlynkWidgetEntity.fromJson(json))
          .toList();
    } else {
      // Default initial Blynk widgets if freshly created
      _widgets = [];
    }

    // Initialize chart telemetry histories
    for (var w in _widgets) {
      if (w.type == BlynkWidgetType.chart) {
        _chartHistories[w.id] = [28.0, 28.5, 29.0, 29.2, 28.8, 29.5];
      }
    }
  }

  void _startLiveSimulation() {
    _telemetryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _widgets.length; i++) {
          final w = _widgets[i];
          if (w.type == BlynkWidgetType.chart || w.type == BlynkWidgetType.gauge || w.type == BlynkWidgetType.value) {
            double delta = (_random.nextDouble() - 0.5) * 0.8;
            double newVal = (w.currentValueNum + delta).clamp(w.minValue, w.maxValue);
            _widgets[i] = w.copyWith(currentValueNum: double.parse(newVal.toStringAsFixed(1)));

            if (w.type == BlynkWidgetType.chart) {
              final list = _chartHistories[w.id] ?? [];
              list.add(newVal);
              if (list.length > 20) list.removeAt(0);
              _chartHistories[w.id] = list;
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  void _saveConfiguration() {
    final updatedJson = _widgets.map((w) => w.toJson()).toList();
    final updatedProject = widget.project.copyWith(blynkConfigJson: updatedJson);

    if (widget.onSaveBlynkConfig != null) {
      widget.onSaveBlynkConfig!(updatedProject);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Layout Blynk IoT berhasil disimpan!'),
        backgroundColor: const Color(0xFF005CFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAddWidgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWidgetModal(
        onWidgetAdded: (newWidget) {
          setState(() {
            _widgets.add(newWidget);
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
          onPressed: () => Navigator.pop(context),
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
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            _buildStatusHeader(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditMode ? 'Atur & Edit Widget Kanvas' : 'Kanvas IoT Real-Time',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0A122C)),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddWidgetModal,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('+ Widget'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Render Dynamic Blynk Widgets
            if (_widgets.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _widgets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final w = _widgets[index];
                  final color = Color(w.primaryColorHex);

                  return _buildWidgetCard(w, color, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
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
                    Text(
                      'Target Device: ${widget.project.deviceType.toUpperCase()}',
                      style: const TextStyle(color: Color(0xFF0A122C), fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E3A2).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('ONLINE', style: TextStyle(color: Color(0xFF00E3A2), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_widgets.length} Widget Terpasang • Synced Live',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetCard(BlynkWidgetEntity w, Color color, int index) {
    VoidCallback? onDeleteAction = _isEditMode
        ? () {
            setState(() {
              _widgets.removeAt(index);
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
            setState(() {
              _widgets[index] = w.copyWith(currentValueBool: val);
            });
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
