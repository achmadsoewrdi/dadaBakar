import 'package:flutter/material.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

import '../pages/dashboard_home_page.dart';
import '../../../lessons_modules/presentation/pages/lessons_modules_page.dart';
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
    final userName = (user?.fullName.isNotEmpty == true) ? user!.fullName : 'Mary';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Stack(
          children: [
            PageView(
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
                RepaintBoundary(child: const LessonsModulesPage()),
                RepaintBoundary(child: const DeviceConnectionScreen()),
                RepaintBoundary(child: const AccountPage()),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: RepaintBoundary(
                child: _buildCustomFloatingNavbar(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFloatingNavbar(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavbarItem(0, Icons.grid_view_rounded, Icons.grid_view),
                _buildNavbarItem(1, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
                const SizedBox(width: 48),
                _buildNavbarItem(2, Icons.bar_chart_rounded, Icons.bar_chart_rounded),
                _buildNavbarItem(3, Icons.person_outline_rounded, Icons.person_rounded),
              ],
            ),
          ),
          Positioned(
            top: -6,
            child: GestureDetector(
              onTap: () => _homePageKey.currentState?.showCreateProjectModal(context),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF005CFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF005CFF).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbarItem(int index, IconData iconUnselected, IconData iconSelected) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2E8F0).withValues(alpha: 0.7) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? iconSelected : iconUnselected,
          color: isSelected ? const Color(0xFF1E293B) : Colors.grey.shade400,
          size: 24,
        ),
      ),
    );
  }
}

