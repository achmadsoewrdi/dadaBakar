import 'package:flutter/material.dart';
import '../../dashboard/data/repositories/dashboard_repository.dart';
import '../../dashboard/presentation/widgets/dashboard_shared_widgets.dart';
import '../domain/models/project_model.dart';
import '../../blockly_workspace/presentation/blockly_workspace_screen.dart';
// import '../../iot_blynk/presentation/screens/blynk_canvas_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final DashboardRepository _repository = DashboardRepository();
  List<ProjectModel> _allProjects = [];
  List<ProjectModel> _filteredProjects = [];
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projects = await _repository.getRecentProjects();
    setState(() {
      _allProjects = projects;
      _filteredProjects = projects;
    });
  }

  void _filterProjects() {
    setState(() {
      _filteredProjects = _allProjects.where((project) {
        final matchesSearch = project.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = _selectedFilter == 'Semua' || 
                              (_selectedFilter == 'Raspberry Pi' && project.deviceType == 'raspberry_pi') ||
                              (_selectedFilter == 'Orange Pi' && project.deviceType == 'orange_pi') ||
                              (_selectedFilter == 'Arduino' && project.deviceType == 'arduino');
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.textScalerOf(context).scale(236) + 16, 
              bottom: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterProjects();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari nama proyek...',
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: ['Semua', 'Raspberry Pi', 'Orange Pi', 'Arduino'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _selectedFilter = filter;
                              _filterProjects();
                            }
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // List View
                _filteredProjects.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'Tidak ada proyek ditemukan.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = _filteredProjects[index];
                          return _buildProjectCard(project);
                        },
                      ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WavyPageHeader(
              title: 'Proyek Saya',
              subtitle: 'Kelola semua proyek hardware Anda',
              gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
              showBackButton: false,
              categoryPillsWidget: HeaderCategoryPills(
                categories: const ['Semua', 'Proyek'],
                selectedIndex: 1,
                onSelect: (idx) {
                  if (idx == 0) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    IconData deviceIcon;
    Color iconColor;
    String deviceLabel;

    switch (project.deviceType) {
      case 'raspberry_pi':
        deviceIcon = Icons.memory;
        iconColor = const Color(0xFFE53935);
        deviceLabel = 'Raspberry Pi';
        break;
      case 'orange_pi':
        deviceIcon = Icons.developer_board;
        iconColor = const Color(0xFFFF9800);
        deviceLabel = 'Orange Pi';
        break;
      case 'arduino':
      default:
        deviceIcon = Icons.integration_instructions;
        iconColor = const Color(0xFF0097A7);
        deviceLabel = 'Arduino / Lainnya';
        break;
    }

    final dateStr = _formatDate(project.updatedAt);

    return HoverCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BlocklyWorkspaceScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(deviceIcon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A122C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.widgets_outlined, size: 14, color: Colors.green.shade800),
                          const SizedBox(width: 4),
                          Text(
                            deviceLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.green.shade800),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
//                       if (project.blynkConfigJson != null)
//                         GestureDetector(
//                           onTap: () {
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(builder: (context) => BlynkCanvasScreen(project: project)),
//                             // );
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF00C2FF).withValues(alpha: 0.15),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.cloud_done, size: 12, color: Color(0xFF005CFF)),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   'Blynk IoT',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF005CFF),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.green.shade700),
          ],
        ),
      ),
    );
  }
}
