import 'package:flutter/material.dart';
import '../../../../features/projects/domain/models/project_model.dart';
import '../../../../features/projects/data/data_sources/project_api_service.dart';
import '../../../../features/iot_lab/presentation/screens/blynk_canvas_screen.dart';
import '../widgets/ai_lab_content.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({Key? key}) : super(key: key);

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  bool _isLoadingProjects = true;
  
  // 0 for IoT Lab, 1 for AI Lab
  int _currentTab = 0;

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
      backgroundColor: const Color(0xFFF8FAFC),
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
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: _currentTab == 0 ? const Color(0xFF005CFF) : const Color(0xFF8B5CF6),
                    ),
                    child: const Text('Lab'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Custom Toggle (IoT Lab | AI Lab)
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    setState(() => _currentTab = 1);
                  } else if (details.primaryVelocity! < 0) {
                    setState(() => _currentTab = 0);
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tabWidth = constraints.maxWidth / 2;
                      return Stack(
                        children: [
                          // Animated sliding background
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: _currentTab == 0 ? 0 : tabWidth,
                            top: 0,
                            bottom: 0,
                            width: tabWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _currentTab == 0 ? const Color(0xFF005CFF) : const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          // Text labels
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _currentTab = 0),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      style: TextStyle(
                                        color: _currentTab == 0 ? Colors.white : Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Roboto', // Avoid default font inheritance issues
                                      ),
                                      child: const Text('IoT Lab'),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _currentTab = 1),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      style: TextStyle(
                                        color: _currentTab == 1 ? Colors.white : Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Roboto', // Avoid default font inheritance issues
                                      ),
                                      child: const Text('AI Lab'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Shared Dropdown
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

              // Content Area
              if (_selectedProject != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentTab == 0
                      ? BlynkCanvasScreen(
                          key: ValueKey('iot_${_selectedProject!.id}'),
                          project: _selectedProject!,
                          isEmbedded: true,
                          onSaveBlynkConfig: (updatedProject) async {
                            try {
                              await ProjectApiService().updateProject(
                                updatedProject.id,
                                blynkConfigJson: updatedProject.blynkConfigJson,
                              );
                              setState(() {
                                _selectedProject = updatedProject;
                                final index = _projects.indexWhere((p) => p.id == updatedProject.id);
                                if (index != -1) {
                                  _projects[index] = updatedProject;
                                }
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to save config: $e')),
                              );
                            }
                          },
                        )
                      : AiLabContent(
                          key: ValueKey('ai_${_selectedProject!.id}'),
                          project: _selectedProject!,
                          onNavigateToIot: () {
                            setState(() {
                              _currentTab = 0;
                            });
                          },
                        ),
                )
              else if (!_isLoadingProjects)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'Buat project terlebih dahulu untuk menggunakan Lab.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
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
