import 'package:flutter/material.dart';
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
                color: Color(0xFF8B5CF6), // Purple from Smart Home
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
            children: ['Biology', 'Physics', 'Chemistry', 'Math'].map((subject) {
              final isSelected = _selectedSubject == subject;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSubject = subject;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      subject,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Choose Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        
        // Analysis Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            AnalysisOptionCard(
              title: 'Optimal\nTemperature',
              icon: Icons.thermostat,
              onTap: () {},
            ),
            AnalysisOptionCard(
              title: 'Humidity\nAnalysis',
              icon: Icons.water_drop,
              onTap: () {},
            ),
            AnalysisOptionCard(
              title: 'Light\nCorrelation',
              icon: Icons.light_mode,
              onTap: () {},
            ),
            AnalysisOptionCard(
              title: 'Anomaly\nDetection',
              icon: Icons.search,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // Purple gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
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
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Analyze with AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('🪄', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
