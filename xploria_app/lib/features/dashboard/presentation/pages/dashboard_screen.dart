import 'package:flutter/material.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';
import '../../../blockly_workspace/presentation/pages/blockly_workspace_screen.dart';

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

  void _showCreateProjectModal(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
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

  void _addNewProject(String name, String deviceType) {
    // Navigate to workspace directly
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BlocklyWorkspaceScreen(),
      ),
    );
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
                    userName: userName,
                    onTabTapped: _onTabTapped,
                    onCreateProjectTapped: () => _showCreateProjectModal(context),
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
              onTap: () => _showCreateProjectModal(context),
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

