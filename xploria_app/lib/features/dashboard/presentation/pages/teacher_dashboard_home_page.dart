import 'package:flutter/material.dart';
import 'package:xploria_app/features/dashboard/presentation/widgets/teacher_stat_card.dart';
import 'package:xploria_app/features/dashboard/presentation/widgets/teacher_action_card.dart';
import 'package:xploria_app/features/dashboard/presentation/widgets/teacher_class_item.dart';

class TeacherDashboardHomePage extends StatelessWidget {
  final Function(int) onTabTapped;

  const TeacherDashboardHomePage({
    Key? key,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: const Text(
                    'S',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Halo, Bu Sarah!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Guru · SMK Telkom',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF0F172A),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stats Row
            Row(
              children: const [
                TeacherStatCard(
                  icon: Icons.people_outline,
                  iconColor: Color(0xFF3B82F6),
                  title: '84',
                  subtitle: 'Murid Aktif',
                ),
                SizedBox(width: 16),
                TeacherStatCard(
                  icon: Icons.check_box_outlined,
                  iconColor: Color(0xFFF97316),
                  title: '7',
                  subtitle: 'Perlu Dinilai',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Cards
            TeacherActionCard(
              icon: Icons.computer,
              iconColor: const Color(0xFF0EA5E9),
              iconBgColor: const Color(0xFFE0F2FE),
              title: 'Pantau progres kelas kamu',
              subtitle: 'Lihat aktivitas belajar & data proyek murid secara real-time.',
              onTap: () {
                onTabTapped(1);
              },
            ),
            const SizedBox(height: 16),
            TeacherActionCard(
              icon: Icons.add,
              iconColor: const Color(0xFF3B5BDB),
              iconBgColor: const Color(0xFFE0E7FF),
              title: 'Buat Tugas Baru',
              subtitle: 'Assign proyek, praktikum, atau kuis ke kelas kamu.',
              buttonText: 'Buat Tugas',
              onButtonTap: () {
                onTabTapped(2);
              },
            ),
            const SizedBox(height: 32),

            // Classes Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kelas Saya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onTabTapped(1);
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B5BDB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Class Items
            TeacherClassItem(
              classInitial: '9A',
              badgeColor: const Color(0xFF3B5BDB),
              title: 'Kelas 9A · Robotika Dasar',
              subtitle: '28 murid · 5 tugas aktif',
              newBadgeCount: 4,
              onTap: () {
                onTabTapped(1);
              },
            ),
            TeacherClassItem(
              classInitial: '10B',
              badgeColor: const Color(0xFF10B981),
              title: 'Kelas 10B · IoT Lanjutan',
              subtitle: '24 murid · 3 tugas aktif',
              onTap: () {
                onTabTapped(1);
              },
            ),
            TeacherClassItem(
              classInitial: '11C',
              badgeColor: const Color(0xFFF59E0B),
              title: 'Kelas 11C · Proyek Akhir',
              subtitle: '32 murid · 1 tugas aktif',
              newBadgeCount: 1,
              onTap: () {
                onTabTapped(1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
