import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xploria_app/features/dashboard/presentation/pages/teacher_dashboard_home_page.dart';
import 'package:xploria_app/features/classroom/presentation/pages/classroom_mockup_screen.dart';
import 'package:xploria_app/features/assignments/presentation/pages/assignments_mockup_screen.dart';

import 'package:xploria_app/features/dashboard/presentation/widgets/teacher_bottom_navbar.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return TeacherDashboardHomePage(
          key: const ValueKey('teacher_home'),
          onTabTapped: _onTabTapped,
        );
      case 1:
        return ClassroomMockupScreen(
          key: const ValueKey('teacher_classes'),
          onBack: () => _onTabTapped(0),
        );
      case 2:
        return AssignmentsMockupScreen(
          key: const ValueKey('teacher_assignments'),
          onBack: () => _onTabTapped(0),
        );
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: TeacherBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            context.pop();
            return;
          }
          _onTabTapped(index);
        },
      ),
    );
  }
}
