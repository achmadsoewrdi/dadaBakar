import 'package:flutter/material.dart';

import '../../../blockly_workspace/presentation/pages/blockly_workspace_screen.dart';
import '../../../iot_blynk/presentation/screens/blynk_canvas_screen.dart';
import '../../../projects/domain/models/project_model.dart';
import '../../../projects/presentation/pages/project_list_screen.dart';
import '../../../device_profile/domain/models/device_profile_model.dart';
import '../../../content/domain/models/learning_module_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../projects/data/repositories/project_repository_impl.dart';
import '../widgets/dashboard_shared_widgets.dart';

class DashboardHomePage extends StatefulWidget {
  final String userName;
  final Function(int) onTabTapped;

  const DashboardHomePage({
    super.key,
    required this.userName,
    required this.onTabTapped,
  });

  @override
  State<DashboardHomePage> createState() => DashboardHomePageState();
}

class DashboardHomePageState extends State<DashboardHomePage> with AutomaticKeepAliveClientMixin {
  final DashboardRepository _repository = DashboardRepository();
  bool _isLoading = true;
  List<ProjectModel> _projects = [];
  List<DeviceProfileModel> _deviceProfiles = [];
  List<LearningModuleModel> _learningModules = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final projects = await _repository.getRecentProjects();
    final profiles = await _repository.getDeviceProfiles();
    final modules = await _repository.getLearningModules();
    
    if (mounted) {
      setState(() {
        _projects = projects;
        _deviceProfiles = profiles;
        _learningModules = modules;
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewProject(String name, String deviceType) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator())
    );
    try {
      final repo = ProjectRepositoryImpl();
      final newProj = await repo.createProject(name); // DeviceType isn't currently used in the API request, but you can pass it if supported later
      if (mounted) Navigator.pop(context); // Tutup loading
      
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocklyWorkspaceScreen(project: newProj),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat proyek: $e')));
      }
    }
  }

  void showCreateProjectModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Buat Proyek Hardware Baru!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A122C),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih jenis target device (Hardware Platform):',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              _buildModalOption(
                context,
                title: 'Raspberry Pi',
                subtitle: 'Komputer mini untuk robotik & AI kamera',
                icon: Icons.developer_board_rounded,
                color: const Color(0xFF00C2FF),
                onTap: () {
                  Navigator.pop(context);
                  _addNewProject('Proyek Raspberry Pi Baru', 'raspberry_pi');
                },
              ),
              const SizedBox(height: 12),

              _buildModalOption(
                context,
                title: 'Orange Pi',
                subtitle: 'Single board computer performa tinggi',
                icon: Icons.hardware_rounded,
                color: const Color(0xFFFF9F1C),
                onTap: () {
                  Navigator.pop(context);
                  _addNewProject('Proyek Orange Pi Baru', 'orange_pi');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }




    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.textScalerOf(context).scale(236) + 24, 
            bottom: 120,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 3. Featured Hero Challenge Banner
                _buildHeroChallengeCard(),
                const SizedBox(height: 20),

                // 4. Two Big Feature Cards: Lessons & Devices
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSquareShortcutCard(
                          title: 'Lessons',
                          subtitle: '${_learningModules.length} Modul',
                          icon: Icons.menu_book_rounded,
                          bgColor: const Color(0xFFE0F2FE),
                          accentColor: const Color(0xFF005CFF),
                          onTap: () => widget.onTabTapped(1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSquareShortcutCard(
                          title: 'Devices',
                          subtitle: '${_deviceProfiles.length} Profiles',
                          icon: Icons.memory_rounded,
                          bgColor: const Color(0xFFFEF3C7),
                          accentColor: const Color(0xFFD97706),
                          onTap: () => widget.onTabTapped(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Full-Width Bottom Card: My Projects
                _buildProjectsFullWidthCard(),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WavyPageHeader(
            title: 'Hi, ${widget.userName}',
            subtitle: 'Selamat datang di Dashboard Xploria!',
            gradientColors: const [Color(0xFF005CFF), Color(0xFF00C2FF)],
            categoryPillsWidget: HeaderCategoryPills(
              categories: const ['Dashboard', 'Proyek'],
              selectedIndex: 0,
              onSelect: (idx) {
                if (idx == 1) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ProjectListScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 250),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroChallengeCard() {
    return HoverCard(
      onTap: () => showCreateProjectModal(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C2FF), Color(0xFF005CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF005CFF).withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 70.0),
                  child: Text(
                    'Ready to Start Your Challenge',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => showCreateProjectModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF005CFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              right: -5,
              bottom: -5,
              child: CuteRobotMascot(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareShortcutCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A122C),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsFullWidthCard() {
    return HoverCard(
      onTap: () async {
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ProjectListScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
        _loadData();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Proyek Saya',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A122C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_projects.length} Proyek • Raspberry Pi & Orange Pi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF005CFF), size: 32),
                  onPressed: () => showCreateProjectModal(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._projects.map((project) => _buildBrightProjectItem(project)),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightProjectItem(ProjectModel project) {
    Color badgeColor;
    IconData deviceIcon;

    switch (project.deviceType) {
      case 'orange_pi':
        badgeColor = const Color(0xFFFF9F1C);
        deviceIcon = Icons.hardware_rounded;
        break;
      case 'raspberry_pi':
      default:
        badgeColor = const Color(0xFF00C2FF);
        deviceIcon = Icons.developer_board_rounded;
        break;
    }

    final hasBlynk = project.blynkConfigJson != null;

    return HoverCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocklyWorkspaceScreen(project: project),
          ),
        );
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(deviceIcon, color: badgeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  Text(
                    project.deviceType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasBlynk) ...[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlynkCanvasScreen(
                        project: project,
                        onSaveBlynkConfig: (updatedProject) {
                          setState(() {
                            final idx = _projects.indexWhere((p) => p.id == updatedProject.id);
                            if (idx != -1) {
                              _projects[idx] = updatedProject;
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E3A2).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E3A2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.sensors_rounded, color: Color(0xFF00E3A2), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Blynk IoT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00E3A2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Proyek?'),
                    content: const Text('Apakah Anda yakin ingin menghapus proyek ini? Proyek yang dihapus tidak bisa dikembalikan.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () => Navigator.pop(context, true), 
                        child: const Text('Hapus', style: TextStyle(color: Colors.white))
                      ),
                    ]
                  )
                );
                if (confirm == true) {
                  try {
                    await ProjectRepositoryImpl().deleteProject(project.id);
                    setState(() {
                      _projects.removeWhere((p) => p.id == project.id);
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
                    }
                  }
                }
              },
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

