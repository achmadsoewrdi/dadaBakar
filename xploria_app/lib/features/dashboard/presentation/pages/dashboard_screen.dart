import 'package:flutter/material.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

import '../pages/dashboard_home_page.dart';
import '../../../projects/presentation/pages/project_list_screen.dart';
import '../../../device/presentation/pages/device_connection_screen.dart';
import '../../../account/presentation/pages/account_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<DashboardHomePageState> _homePageKey = GlobalKey<DashboardHomePageState>();
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthStorageService().currentUser;
    final userName = (user?.fullName.isNotEmpty == true) ? user!.fullName.split(' ').first : 'Achmad';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: [
          RepaintBoundary(
            child: DashboardHomePage(
              key: _homePageKey,
              userName: userName,
              onTabTapped: _onTabTapped,
            ),
          ),
          RepaintBoundary(child: const ProjectListScreen()),
          RepaintBoundary(child: const DeviceConnectionScreen()),
          RepaintBoundary(child: const AccountPage()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'Learn', Icons.school_rounded),
            _buildNavItem(1, 'Projects', Icons.terminal_rounded),
            _buildNavItem(2, 'Devices', Icons.router_rounded),
            _buildNavItem(3, 'Profile', Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF005CFF) : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? const Color(0xFF005CFF) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
