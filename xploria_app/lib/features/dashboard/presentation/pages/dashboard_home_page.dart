import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../projects/domain/models/project_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../projects/data/repositories/project_repository_impl.dart';
import '../../../projects/presentation/widgets/project_card.dart';
import '../../../projects/data/data_sources/project_category_service.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../../core/config/app_constants.dart';

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
  final ProjectCategoryService _categoryService = ProjectCategoryService();
  bool _isLoading = true;
  List<ProjectModel> _projects = [];
  UserModel? _user;
  Color _heroColor = const Color(0xFF005CFF);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _categoryService.init();
    final projects = await _repository.getRecentProjects();
    final user = AuthStorageService().currentUser;
    
    if (mounted) {
      setState(() {
        _projects = projects;
        _user = user;
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
      final newProj = await repo.createProject(name); 
      if (mounted) context.pop(); 
      
      if (mounted) {
        await context.push('/blockly', extra: newProj);
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat proyek: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Bar (Profile + Streak)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (_user?.photoUrl != null && _user!.photoUrl!.isNotEmpty)
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                backgroundImage: NetworkImage(
                                  _user!.photoUrl!.startsWith('http') 
                                      ? _user!.photoUrl! 
                                      : '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}${_user!.photoUrl}'
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  (_user?.fullName.isNotEmpty == true) ? _user!.fullName[0].toUpperCase() : 'Y',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Text(
                              'Hello, ${_user?.fullName ?? widget.userName}!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A122C),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    '5',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(width: 4),
                                  Text('🔥', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B5BDB).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.school, color: Color(0xFF3B5BDB), size: 20),
                                tooltip: 'Simulasi Mode Guru',
                                onPressed: () {
                                  context.push('/teacher-dashboard');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Carousel Header
                    DashboardHeroCarousel(
                      onColorChanged: (color) {
                        setState(() {
                          _heroColor = color;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Let's Start Building Action Card
                    _buildHeroActionCard(),
                    const SizedBox(height: 24),

                    // Projects List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _projects.length > 3 ? 3 : _projects.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildProjectItemCard(_projects[index]);
                      },
                    ),
                    const SizedBox(height: 16),

                    // View All Projects Text Button
                    if (_projects.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          await context.push('/projects');
                          _loadData();
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All Projects',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005CFF),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF005CFF)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }



  Widget _buildHeroActionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _heroColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.rocket_launch_rounded, color: _heroColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's Start Building!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A122C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Create a new IoT project from scratch",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _addNewProject("New Project", "raspberry_pi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _heroColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 4),
                      Text("New Project", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItemCard(ProjectModel project) {
    return ProjectCard(
      project: project,
      categoryService: _categoryService,
      showChevron: true,
      onTap: () async {
        await context.push('/blockly', extra: project);
        _loadData();
      },
    );
  }
}

class DashboardHeroCarousel extends StatefulWidget {
  final Function(Color) onColorChanged;

  const DashboardHeroCarousel({super.key, required this.onColorChanged});

  @override
  State<DashboardHeroCarousel> createState() => _DashboardHeroCarouselState();
}

class _DashboardHeroCarouselState extends State<DashboardHeroCarousel> {
  final PageController _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'SMART\nCITY',
      'image': 'assets/images/modules/dashboard/smart_city 1.png',
      'color': const Color(0xFF005CFF),
    },
    {
      'title': 'SMART\nAGRICULTURE',
      'image': 'assets/images/modules/dashboard/smart_farm 1.png',
      'color': const Color(0xFF22C55E),
    },
    {
      'title': 'SMART\nHOME',
      'image': 'assets/images/modules/dashboard/smart_home 1.png',
      'color': const Color(0xFF8B5CF6),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onColorChanged(_carouselItems[_currentIndex]['color'] as Color);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _carouselItems[_currentIndex]['title']!,
            key: ValueKey<int>(_currentIndex),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _carouselItems[_currentIndex]['color'] as Color,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // The Carousel containing only images
        SizedBox(
          height: 250, 
          child: PageView.builder(
            clipBehavior: Clip.none,
            controller: _pageController,
            onPageChanged: (index) {
              if (_currentIndex != index) {
                HapticFeedback.selectionClick(); //efek geter
                setState(() {
                  _currentIndex = index;
                });
                widget.onColorChanged(_carouselItems[index]['color'] as Color);
              }
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                  } else if (index != _currentIndex) {
                    value = 0.8;
                  }
                  
                  return Center(
                    child: Transform.scale(
                      scale: Curves.easeOut.transform(value),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Image.asset(
                    item['image']!,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carouselItems.length,
            (index) => _buildDot(active: index == _currentIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildDot({bool active = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? (_carouselItems[_currentIndex]['color'] as Color) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
