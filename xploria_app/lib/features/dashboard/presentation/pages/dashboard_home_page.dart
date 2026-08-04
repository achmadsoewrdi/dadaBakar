import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../projects/domain/models/project_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../projects/data/repositories/project_repository_impl.dart';
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
  bool _isLoading = true;
  List<ProjectModel> _projects = [];
  UserModel? _user;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Carousel Header
                    const DashboardHeroCarousel(),
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
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF005CFF), size: 28),
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
                    backgroundColor: const Color(0xFF005CFF),
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
    IconData icon;
    Color color;
    
    if (project.name.toLowerCase().contains("garden") || project.name.toLowerCase().contains("agri") || project.name.toLowerCase().contains("taman")) {
      icon = Icons.water_drop_outlined;
      color = const Color(0xFF005CFF);
    } else if (project.name.toLowerCase().contains("temp") || project.name.toLowerCase().contains("suhu")) {
      icon = Icons.thermostat_rounded;
      color = const Color(0xFF005CFF);
    } else {
      icon = Icons.security_rounded;
      color = const Color(0xFF005CFF);
    }

    return GestureDetector(
      onTap: () async {
        await context.push('/blockly', extra: project);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Last edited recently",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class DashboardHeroCarousel extends StatefulWidget {
  const DashboardHeroCarousel({super.key});

  @override
  State<DashboardHeroCarousel> createState() => _DashboardHeroCarouselState();
}

class _DashboardHeroCarouselState extends State<DashboardHeroCarousel> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  final List<Map<String, String>> _carouselItems = [
    {
      'title': 'SMART\nAGRICULTURE',
      'image': 'assets/images/modules/dashboard/smart_farm 1.png',
    },
    {
      'title': 'SMART\nCITY',
      'image': 'assets/images/modules/dashboard/smart_city 1.png',
    },
    {
      'title': 'SMART\nHOME',
      'image': 'assets/images/modules/dashboard/smart_home 1.png',
    },
  ];

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
        // Fixed Title that changes with cross-fade animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _carouselItems[_currentIndex]['title']!,
            key: ValueKey<int>(_currentIndex),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF005CFF),
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // The Carousel containing only images
        SizedBox(
          height: 200, 
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return Image.asset(
                item['image']!,
                height: 200,
                fit: BoxFit.contain,
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
        color: active ? const Color(0xFF005CFF) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

