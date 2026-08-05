import 'package:flutter/material.dart';
import '../widgets/ai_sensor_card.dart';
import '../widgets/analysis_option_card.dart';
import '../../../projects/domain/models/project_model.dart';
import '../../../projects/data/data_sources/project_api_service.dart';
import '../../../../features/iot_lab/domain/entities/blynk_widget_entity.dart';
import 'package:go_router/go_router.dart';

class AiLabScreen extends StatefulWidget {
  const AiLabScreen({Key? key}) : super(key: key);

  @override
  State<AiLabScreen> createState() => _AiLabScreenState();
}

class _AiLabScreenState extends State<AiLabScreen> {
  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  bool _isLoadingProjects = true;
  String _selectedSubject = 'Biology';

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final projects = await ProjectApiService().getProjects();
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoadingProjects = false;
          if (_projects.isNotEmpty) {
            _selectedProject = _projects.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProjects = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grayish blue background
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120, left: 24, right: 24, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'AI Lab',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF005CFF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '🪄',
                    style: TextStyle(fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoadingProjects
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _projects.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Belum ada project tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<ProjectModel>(
                              value: _selectedProject,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                              items: _projects.map((ProjectModel project) {
                                return DropdownMenuItem<ProjectModel>(
                                  value: project,
                                  child: Row(
                                    children: [
                                      const Text('🌱', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          project.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedProject = newValue;
                                  });
                                }
                              },
                            ),
                          ),
              ),
              const SizedBox(height: 24),

              // Sensors
              Builder(
                builder: (context) {
                  final blynkConfig = _selectedProject?.blynkConfigJson ?? [];
                  List<BlynkWidgetEntity> widgets = blynkConfig.map((json) => BlynkWidgetEntity.fromJson(json)).toList();
                  List<BlynkWidgetEntity> sensorWidgets = widgets.where((w) => w.type != BlynkWidgetType.toggle).toList();

                  if (sensorWidgets.isEmpty) {
                    return Center(
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
                              onPressed: () {
                                if (_selectedProject != null) {
                                  context.push('/blynk-canvas', extra: {'project': _selectedProject});
                                }
                              },
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
                    );
                  }

                  return SingleChildScrollView(
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
                  );
                },
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
                            color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6).withOpacity(0.3),
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
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.4),
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
          ),
        ),
      ),
    );
  }
}
