import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:xploria_app/features/classroom/presentation/widgets/class_stat_card.dart';
import 'package:xploria_app/features/classroom/presentation/widgets/assignment_item_card.dart';
import 'package:xploria_app/features/classroom/presentation/widgets/student_item_card.dart';
import 'package:xploria_app/features/classroom/presentation/widgets/leaderboard_item.dart';

class ClassroomMockupScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ClassroomMockupScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<ClassroomMockupScreen> createState() => _ClassroomMockupScreenState();
}

class _ClassroomMockupScreenState extends State<ClassroomMockupScreen> {
  int _selectedTab = 0; // 0: Tugas, 1: Murid, 2: Leaderboard
  int _currentIndex = 1; // For bottom navbar (Kelas)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        context.pop();
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Kelas 9A · Robotika Dasar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.copy, size: 12, color: Color(0xFF3B5BDB)),
                              const SizedBox(width: 4),
                              const Text(
                                'XR7K2Q',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B5BDB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.more_vert, size: 24, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: const [
                  ClassStatCard(value: '28', label: 'MURID'),
                  SizedBox(width: 12),
                  ClassStatCard(value: '5', label: 'TUGAS AKTIF'),
                  SizedBox(width: 12),
                  ClassStatCard(value: '82', label: 'RATA XP'),
                ],
              ),
              const SizedBox(height: 24),

              // Custom Tab Segmented Control
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTab(0, 'Tugas'),
                    _buildTab(1, 'Murid'),
                    _buildTab(2, 'Leaderboard'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Button (+ Tugas Baru)
              if (_selectedTab == 0)
                Container(
                  width: double.infinity,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B5BDB).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // TODO: Add new task
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tugas Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              if (_selectedTab == 0)
                Column(
                  children: [
                    AssignmentItemCard(
                      icon: Icons.web_asset, // Using web_asset as placeholder for the UI icon
                      iconBgColor: const Color(0xFFE8F0FE),
                      iconColor: const Color(0xFF3B5BDB),
                      title: 'Proyek: Dashboard Suhu DHT11',
                      deadline: 'Deadline 8 Agu 2026',
                      statusText: 'Aktif',
                      statusBgColor: const Color(0xFFD1FAE5),
                      statusTextColor: const Color(0xFF10B981),
                      progressCount: 18,
                      totalCount: 28,
                      progressColor: const Color(0xFF34D399),
                    ),
                    AssignmentItemCard(
                      icon: Icons.help_outline,
                      iconBgColor: const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF10B981),
                      title: 'Kuis: Prinsip Sensor Ultrasonic',
                      deadline: 'Deadline 5 Agu 2026',
                      statusText: 'Aktif',
                      statusBgColor: const Color(0xFFD1FAE5),
                      statusTextColor: const Color(0xFF10B981),
                      progressCount: 25,
                      totalCount: 28,
                      progressColor: const Color(0xFF34D399),
                    ),
                    AssignmentItemCard(
                      icon: Icons.science_outlined,
                      iconBgColor: const Color(0xFFFFEDD5),
                      iconColor: const Color(0xFFF97316),
                      title: 'Praktikum: Sambungkan ESP32',
                      deadline: 'Selesai 28 Jul 2026',
                      statusText: 'Selesai',
                      statusBgColor: const Color(0xFFF1F5F9),
                      statusTextColor: const Color(0xFF64748B),
                      progressCount: 28,
                      totalCount: 28,
                      progressColor: const Color(0xFF34D399),
                    ),
                  ],
                ),
                
              if (_selectedTab == 1)
                Column(
                  children: const [
                    StudentItemCard(
                      initial: 'R',
                      name: 'Rafi K.',
                      taskProgress: '5/5 tugas',
                      statusText: 'Selesai',
                      statusBgColor: Color(0xFFD1FAE5),
                      statusTextColor: Color(0xFF10B981),
                    ),
                    StudentItemCard(
                      initial: 'S',
                      name: 'Sinta W.',
                      taskProgress: '4/5 tugas',
                      statusText: 'Berjalan',
                      statusBgColor: Color(0xFFFFEDD5),
                      statusTextColor: Color(0xFFF97316),
                    ),
                    StudentItemCard(
                      initial: 'M',
                      name: 'Mutiara A.',
                      taskProgress: '3/5 tugas',
                      statusText: 'Berjalan',
                      statusBgColor: Color(0xFFFFEDD5),
                      statusTextColor: Color(0xFFF97316),
                    ),
                    StudentItemCard(
                      initial: 'D',
                      name: 'Dimas P.',
                      taskProgress: '5/5 tugas',
                      statusText: 'Selesai',
                      statusBgColor: Color(0xFFD1FAE5),
                      statusTextColor: Color(0xFF10B981),
                    ),
                    StudentItemCard(
                      initial: 'A',
                      name: 'Aisyah N.',
                      taskProgress: '2/5 tugas',
                      statusText: 'Berjalan',
                      statusBgColor: Color(0xFFFFEDD5),
                      statusTextColor: Color(0xFFF97316),
                    ),
                  ],
                ),
                
              if (_selectedTab == 2)
                Column(
                  children: const [
                    LeaderboardItem(
                      rank: 1,
                      initial: 'R',
                      name: 'Rafi K.',
                      xp: '320 XP',
                    ),
                    LeaderboardItem(
                      rank: 2,
                      initial: 'D',
                      name: 'Dimas P.',
                      xp: '298 XP',
                    ),
                    LeaderboardItem(
                      rank: 3,
                      initial: 'S',
                      name: 'Sinta W.',
                      xp: '265 XP',
                    ),
                    LeaderboardItem(
                      rank: 4,
                      initial: 'M',
                      name: 'Mutiara A.',
                      xp: '210 XP',
                    ),
                    LeaderboardItem(
                      rank: 5,
                      initial: 'A',
                      name: 'Aisyah N.',
                      xp: '180 XP',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildTab(int index, String text) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B5BDB) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
