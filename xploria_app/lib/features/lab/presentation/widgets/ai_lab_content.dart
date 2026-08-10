import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/projects/domain/models/project_model.dart';
import '../../../../features/ai_lab/presentation/widgets/ai_sensor_card.dart';
import '../../../../features/ai_lab/presentation/widgets/analysis_option_card.dart';
import '../../../../features/iot_lab/domain/entities/blynk_widget_entity.dart';

class AiLabContent extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback? onNavigateToIot;

  const AiLabContent({Key? key, required this.project, this.onNavigateToIot}) : super(key: key);

  @override
  State<AiLabContent> createState() => _AiLabContentState();
}

class _AiLabContentState extends State<AiLabContent> {
  String _selectedSubject = 'Biology';
  String? _selectedAnalysis;

  Widget _buildSubjectChip(String subject, IconData icon) {
    final isSelected = _selectedSubject == subject;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubject = subject),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(
              subject,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blynkConfig = widget.project.blynkConfigJson ?? [];
    List<BlynkWidgetEntity> widgets = blynkConfig.map((json) => BlynkWidgetEntity.fromJson(json)).toList();
    List<BlynkWidgetEntity> sensorWidgets = widgets.where((w) => w.type != BlynkWidgetType.toggle).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sensors
        if (sensorWidgets.isEmpty)
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.sensors_off_rounded, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Data sensor belum dibuat', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: widget.onNavigateToIot,
                    icon: const Icon(Icons.settings),
                    label: const Text('Ayo atur di IoT Lab'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005CFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: sensorWidgets.map((w) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AiSensorCard(
                    title: w.title,
                    value: '${w.currentValueNum}${w.unit}',
                    icon: Icon(Icons.sensors, color: Color(w.primaryColorHex), size: 16),
                    graphColor: Color(w.primaryColorHex),
                    dataPoints: const [20, 22, 25, 23, 27, 28], // Static dummy points for chart
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'View Full Sensor Data',
              style: TextStyle(
                color: Color(0xFF005CFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Subjects
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSubjectChip('Biology', Icons.biotech),
              const SizedBox(width: 12),
              _buildSubjectChip('Math', Icons.calculate_outlined),
              const SizedBox(width: 12),
              _buildSubjectChip('Physics', Icons.science_outlined),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Choose Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        
        // Analysis Grid
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.25, // Diubah agar kotak menjadi lebih tinggi/proporsional
          children: [
            AnalysisOptionCard(
              title: 'Optimal\nTemperature',
              icon: Icons.thermostat,
              isSelected: _selectedAnalysis == 'Optimal Temperature',
              onTap: () => setState(() => _selectedAnalysis = 'Optimal Temperature'),
            ),
            AnalysisOptionCard(
              title: 'Humidity\nAnalysis',
              icon: Icons.water_drop,
              isSelected: _selectedAnalysis == 'Humidity Analysis',
              onTap: () => setState(() => _selectedAnalysis = 'Humidity Analysis'),
            ),
            AnalysisOptionCard(
              title: 'Light\nCorrelation',
              icon: Icons.light_mode,
              isSelected: _selectedAnalysis == 'Light Correlation',
              onTap: () => setState(() => _selectedAnalysis = 'Light Correlation'),
            ),
            AnalysisOptionCard(
              title: 'Anomaly\nDetection',
              icon: Icons.search,
              isSelected: _selectedAnalysis == 'Anomaly Detection',
              onTap: () => setState(() => _selectedAnalysis = 'Anomaly Detection'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: _selectedAnalysis == null 
                  ? null 
                  : const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              color: _selectedAnalysis == null ? Colors.grey.shade300 : null,
              boxShadow: _selectedAnalysis == null 
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _selectedAnalysis == null ? null : () {
                context.push('/ai-analysis-result');
              },
              child: Text(
                'Analyze with AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _selectedAnalysis == null ? Colors.grey.shade500 : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
