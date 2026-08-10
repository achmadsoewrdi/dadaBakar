import 'package:flutter/material.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

import '../pages/dashboard_home_page.dart';
import '../widgets/dashboard_bottom_navbar.dart';
import '../../../projects/presentation/pages/project_list_screen.dart';
import '../../../device/presentation/pages/device_connection_screen.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../../features/lab/presentation/pages/lab_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<DashboardHomePageState> _homePageKey = GlobalKey<DashboardHomePageState>();
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildCurrentPage(String userName) {
    switch (_currentIndex) {
      case 0:
        return DashboardHomePage(
          key: const ValueKey('home'),
          userName: userName,
          onTabTapped: _onTabTapped,
        );
      case 1:
        return const ProjectListScreen(key: ValueKey('projects'));
      case 2:
        return const DeviceConnectionScreen(key: ValueKey('devices'));
      case 3:
        return const LabScreen(key: ValueKey('lab'));
      case 4:
        return const AccountPage(key: ValueKey('account'));
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthStorageService().currentUser;
    final userName = (user?.fullName.isNotEmpty == true) ? user!.fullName.split(' ').first : 'Achmad';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _buildCurrentPage(userName),
      ),
      bottomNavigationBar: DashboardBottomNavbar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}


