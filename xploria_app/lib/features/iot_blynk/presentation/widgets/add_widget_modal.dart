import 'package:flutter/material.dart';
import '../../domain/entities/blynk_widget_entity.dart';

class AddWidgetModal extends StatefulWidget {
  final ValueChanged<BlynkWidgetEntity> onWidgetAdded;
  const AddWidgetModal({super.key, required this.onWidgetAdded});

  @override
  State<AddWidgetModal> createState() => _AddWidgetModalState();
}

class _AddWidgetModalState extends State<AddWidgetModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Sensor Suhu');
  final _pinController = TextEditingController(text: 'A0');
  final _unitController = TextEditingController(text: '°C');

  BlynkWidgetType _selectedType = BlynkWidgetType.chart;
  int _selectedColorHex = 0xFF005CFF; // Blue default

  final List<int> _availableColors = [
    0xFF005CFF, // Electric Blue
    0xFF00E3A2, // Mint Teal
    0xFFFF9F1C, // Vibrant Orange
    0xFF9C27B0, // Purple Accent
    0xFFE85D04, // Deep Red/Orange
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _pinController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newWidget = BlynkWidgetEntity(
        id: 'w_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        type: _selectedType,
        sensorPin: _pinController.text.trim(),
        unit: _unitController.text.trim(),
        primaryColorHex: _selectedColorHex,
        isActuator: _selectedType == BlynkWidgetType.toggle,
        currentValueNum: _selectedType == BlynkWidgetType.gauge ? 65.0 : 28.5,
      );

      widget.onWidgetAdded(newWidget);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih & Tambah Widget IoT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A122C),
                ),
              ),
              const SizedBox(height: 16),

              // 1. Widget Type Selection Grid
              const Text(
                'Tipe Widget',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF005CFF)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeOption(BlynkWidgetType.chart, 'Grafik', Icons.show_chart_rounded),
                  const SizedBox(width: 8),
                  _buildTypeOption(BlynkWidgetType.gauge, 'Meteran', Icons.speed_rounded),
                  const SizedBox(width: 8),
                  _buildTypeOption(BlynkWidgetType.toggle, 'Sakelar', Icons.toggle_on_rounded),
                  const SizedBox(width: 8),
                  _buildTypeOption(BlynkWidgetType.value, 'Angka', Icons.tag_rounded),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nama Widget / Sensor',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 14),

              // 3. Pin & Unit Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pinController,
                      decoration: InputDecoration(
                        labelText: 'Pin Hardware (A0/D2)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Pin wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: InputDecoration(
                        labelText: 'Satuan (°C / % / V)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Theme Color Selection
              const Text(
                'Warna Tema',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF005CFF)),
              ),
              const SizedBox(height: 8),
              Row(
                children: _availableColors.map((colorHex) {
                  final isSelected = _selectedColorHex == colorHex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorHex = colorHex),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Color(colorHex),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: const Color(0xFF0A122C), width: 3) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Tambahkan Widget ke Canvas ✨',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(BlynkWidgetType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    final color = isSelected ? const Color(0xFF005CFF) : Colors.grey.shade400;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF005CFF).withValues(alpha: 0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF005CFF) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
