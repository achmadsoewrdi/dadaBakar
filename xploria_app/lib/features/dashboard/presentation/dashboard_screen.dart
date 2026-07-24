import 'package:flutter/material.dart';
import '../../auth/data/services/auth_storage_service.dart';
import '../../auth/presentation/welcome/welcome_screen.dart';
import '../../blockly_workspace/presentation/blockly_workspace_screen.dart';
import '../../projects/domain/models/project_model.dart';
import '../../devices/domain/models/device_profile_model.dart';
import '../../content/domain/models/learning_module_model.dart';
import '../../content/presentation/module_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _selectedModuleCategoryIndex = 0;
  late final PageController _pageController;

  // Mock data aligned with ERD tables
  late List<ProjectModel> _projects;
  late List<DeviceProfileModel> _deviceProfiles;
  late List<LearningModuleModel> _learningModules;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initMockDataFromERD();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initMockDataFromERD() {
    final user = AuthStorageService().currentUser;
    final userId = user?.id ?? 'uuid_demo_user';
    final now = DateTime.now();

    // 1. PROJECTS Table data (FK owner_id -> USERS.id, device_type: raspberry_pi | orange_pi)
    _projects = [
      ProjectModel(
        id: 'proj_01',
        ownerId: userId,
        name: 'Kamera Pintar Robot',
        workspaceXml: '<xml><block type="rpi_camera"></block></xml>',
        generatedCode: 'import cv2\nprint("Raspberry Pi Camera Running")',
        deviceType: 'raspberry_pi',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      ProjectModel(
        id: 'proj_02',
        ownerId: userId,
        name: 'Kontrol Lampu Otomatis',
        workspaceXml: '<xml><block type="orangepi_gpio"></block></xml>',
        generatedCode: 'import OPi.GPIO as GPIO',
        deviceType: 'orange_pi',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    // 2. DEVICE_PROFILES Table data (FK owner_id -> USERS.id, protocol: websocket | bluetooth)
    _deviceProfiles = [
      DeviceProfileModel(
        id: 'dev_01',
        ownerId: userId,
        label: 'Node Raspberry Pi Lab Utama',
        protocol: 'websocket',
        host: '192.168.1.105',
        port: 8080,
        useTls: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      DeviceProfileModel(
        id: 'dev_02',
        ownerId: userId,
        label: 'Sensor Robot BLE',
        protocol: 'bluetooth',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    // 3. LEARNING_MODULES Table data (is_premium_only based on is_premium)
    _learningModules = [
      LearningModuleModel(
        id: 'mod_01',
        title: 'Dasar Pemrograman Robotik & IoT',
        description: 'Pelajari dasar-dasar mengontrol pin GPIO, WiFi, dan sensor pada single board computer.',
        stepsJson: {'steps': 5, 'level': 'Pemula'},
        isPremiumOnly: false,
        createdAt: now.subtract(const Duration(days: 10)),
        imageAsset: 'assets/images/modules/robot.png',
        imageBgColor: '0xFFFFF3E0', // Light orange
      ),
      LearningModuleModel(
        id: 'mod_02',
        title: 'Kamera AI & Robotik Raspberry Pi',
        description: 'Membangun sistem pengenal wajah dan kontrol motor otomatis dengan Raspberry Pi.',
        stepsJson: {'steps': 8, 'level': 'Lanjutan'},
        isPremiumOnly: true,
        createdAt: now.subtract(const Duration(days: 7)),
        imageAsset: 'assets/images/modules/car.png',
        imageBgColor: '0xFFE0F7FA', // Light cyan
      ),
      LearningModuleModel(
        id: 'mod_03',
        title: 'Protokol Komunikasi WebSocket & BLE',
        description: 'Koneksikan hardware secara langsung ke Flutter App menggunakan WebSocket & Bluetooth.',
        stepsJson: {'steps': 6, 'level': 'Menengah'},
        isPremiumOnly: false,
        createdAt: now.subtract(const Duration(days: 4)),
        imageAsset: 'assets/images/modules/board.png',
        imageBgColor: '0xFFE8F5E9', // Light green
      ),
    ];
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

  /// Create Project Modal matching PROJECTS table schema (device_type)
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

              // Option 1: Raspberry Pi
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

              // Option 3: Orange Pi
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

  void _addNewProject(String name, String deviceType) {
    final user = AuthStorageService().currentUser;
    final now = DateTime.now();

    final newProject = ProjectModel(
      id: 'proj_${now.millisecondsSinceEpoch}',
      ownerId: user?.id ?? 'uuid_demo_user',
      name: name,
      workspaceXml: '<xml><block type="start"></block></xml>',
      deviceType: deviceType,
      createdAt: now,
      updatedAt: now,
    );

    setState(() {
      _projects.insert(0, newProject);
    });

    _showFeatureSnackbar('Proyek $name ($deviceType) berhasil dibuat!');
    
    // Langsung arahkan ke workspace
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BlocklyWorkspaceScreen(),
      ),
    );
  }

  void _showFeatureSnackbar(String message) {
    // Pesan-pesan ini sengaja dinonaktifkan atas permintaan Anda
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF005CFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthStorageService().currentUser;
    final userName = (user?.fullName.isNotEmpty == true) ? user!.fullName : 'Mary';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF), // Soft bright sky background matching reference
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Stack(
          children: [
            // Silky Smooth Animated PageView for Tabs
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                if (_currentIndex != index) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              children: [
                RepaintBoundary(child: _buildHomeDashboard(userName)),
                RepaintBoundary(child: _buildLearningModulesTab(user)),
                RepaintBoundary(child: _buildDeviceProfilesTab(user)),
                RepaintBoundary(child: _buildUserProfileTab(user)),
              ],
            ),

            // Bottom Navigation Bar with GPU Caching
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

  // --- WAVY PAGE HEADER & CLIPPER (Unified Blue Theme) ---
  Widget _buildWavyPageHeader({
    required String title,
    required String subtitle,
    List<Color>? gradientColors,
    Widget? topActionWidget,
    Widget? categoryPillsWidget,
  }) {
    final colors = gradientColors ?? const [Color(0xFF005CFF), Color(0xFF00C2FF)];
    final topInset = MediaQuery.of(context).padding.top;
    final topPadding = topInset > 0 ? topInset + 20 : 54.0;

    return RepaintBoundary(
      child: ClipPath(
        clipper: WaveHeaderClipper(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: topPadding, bottom: 44),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (topActionWidget != null) topActionWidget,
                ],
              ),
            ),
            if (categoryPillsWidget != null) ...[
              const SizedBox(height: 18),
              categoryPillsWidget,
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeaderCategoryPills(List<String> categories, int selectedIndex, ValueChanged<int> onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              margin: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF9F1C) : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF9F1C).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- 1. HOME DASHBOARD VIEW (Matching Reference Screen with Wavy Header) ---
  Widget _buildHomeDashboard(String userName) {
    final user = AuthStorageService().currentUser;
    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: topInset + 200, bottom: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 2. Level / Progress White Card
                _buildLevelProgressCard(),
                const SizedBox(height: 20),

                // 3. Featured Hero Challenge Banner
                _buildHeroChallengeCard(),
                const SizedBox(height: 20),

                // 4. Two Big Feature Cards: Lessons & Devices
                Row(
                  children: [
                    Expanded(
                      child: _buildSquareShortcutCard(
                        title: 'Lessons',
                        subtitle: '${_learningModules.length} Modul',
                        icon: Icons.menu_book_rounded,
                        bgColor: const Color(0xFFE0F2FE),
                        accentColor: const Color(0xFF005CFF),
                        onTap: () => _onTabTapped(1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSquareShortcutCard(
                        title: 'Devices',
                        subtitle: '${_deviceProfiles.length} Profiles',
                        icon: Icons.memory_rounded,
                        bgColor: const Color(0xFFFEF3C7),
                        accentColor: const Color(0xFFD97706),
                        onTap: () => _onTabTapped(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. Full-Width Bottom Card: My Projects
                _buildProjectsFullWidthCard(),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildWavyPageHeader(
            title: 'Hi, $userName',
            subtitle: 'Selamat datang di Dashboard Xploria!',
            gradientColors: const [Color(0xFF005CFF), Color(0xFF00C2FF)],
            topActionWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFFF9F1C), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    (user?.isPremium ?? false) ? 'VIP' : '120 Pts',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            categoryPillsWidget: _buildHeaderCategoryPills(
              ['Semua', 'Proyek', 'Misi', 'Statistik'],
              0,
              (idx) {},
            ),
          ),
        ),
      ],
    );
  }

  // --- LEVEL PROGRESS CARD (Matching Reference Image Top Card) ---
  Widget _buildLevelProgressCard() {
    return HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Level 1',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0A122C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This is your first step to greatness!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFF9F1C), size: 30),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.45,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9F1C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HERO CHALLENGE CARD (Matching Reference Image Blue Banner) ---
  Widget _buildHeroChallengeCard() {
    return HoverCard(
      onTap: () => _showCreateProjectModal(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C2FF), Color(0xFF005CFF)], // Vibrant Bright Cyan-Blue from Logo
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF005CFF).withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content Left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 70.0),
                  child: Text(
                    'Ready to Start Your Challenge',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showCreateProjectModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF005CFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            // Cute Robot Mascot
            Positioned(
              right: -5,
              bottom: -5,
              child: _buildCuteRobotMascot(),
            ),
          ],
        ),
      ),
    );
  }

  // Cute Robot Mascot Widget
  Widget _buildCuteRobotMascot() {
    return SizedBox(
      width: 95,
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Robot Head/Body
          Container(
            width: 75,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF2ED9C3),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF0A122C), shape: BoxShape.circle)),
                const SizedBox(width: 14),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF0A122C), shape: BoxShape.circle)),
              ],
            ),
          ),
          // Robot Antenna
          Positioned(
            top: 2,
            child: Container(
              width: 8,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SQUARE SHORTCUT CARDS (Matching Lessons & Games in Reference) ---
  Widget _buildSquareShortcutCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 36),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A122C),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FULL-WIDTH PROJECTS CARD (Matching "Play with Friend" Green Card in Reference) ---
  Widget _buildProjectsFullWidthCard() {
    return HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proyek Saya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0A122C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_projects.length} Proyek • Raspberry Pi & Orange Pi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF005CFF), size: 32),
                  onPressed: () => _showCreateProjectModal(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Project items
            ..._projects.map((project) => _buildBrightProjectItem(project)),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightProjectItem(ProjectModel project) {
    Color badgeColor;
    IconData deviceIcon;

    switch (project.deviceType) {
      case 'orange_pi':
        badgeColor = const Color(0xFFFF9F1C);
        deviceIcon = Icons.hardware_rounded;
        break;
      case 'raspberry_pi':
      default:
        badgeColor = const Color(0xFF00C2FF);
        deviceIcon = Icons.developer_board_rounded;
        break;
    }

    return HoverCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BlocklyWorkspaceScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(deviceIcon, color: badgeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  Text(
                    project.deviceType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
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

  // --- 2. LEARNING MODULES TAB (LEARNING_MODULES Table - Wavy Header) ---
  Widget _buildLearningModulesTab(dynamic user) {
    final topInset = MediaQuery.of(context).padding.top;

    final filteredModules = _learningModules.where((module) {
      if (_selectedModuleCategoryIndex == 0) return true; // Hot / Semua
      if (_selectedModuleCategoryIndex == 1) return module.stepsJson?['level'] == 'Pemula';
      if (_selectedModuleCategoryIndex == 2) return module.stepsJson?['level'] == 'Menengah';
      if (_selectedModuleCategoryIndex == 3) return module.isPremiumOnly == true;
      return true;
    }).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: topInset + 200, bottom: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (filteredModules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Center(
                      child: Text(
                        'Belum ada modul di kategori ini.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ...List.generate(filteredModules.length, (index) {
                  final module = filteredModules[index];
                  final userIsPremium = user?.isPremium ?? false;
                  final canAccess = !module.isPremiumOnly || userIsPremium;

                  return _buildColorfulModuleCard(
                    module: module,
                    index: index,
                    canAccess: canAccess,
                    onTap: () {
                      if (canAccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModuleDetailScreen(
                              module: module,
                              canAccess: canAccess,
                            ),
                          ),
                        );
                      } else {
                        _showFeatureSnackbar('Modul ini khusus pengguna Premium VIP!');
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildWavyPageHeader(
            title: 'Lessons & Modules',
            subtitle: 'Pelajari koding & IoT dengan seru!',
            categoryPillsWidget: _buildHeaderCategoryPills(
              ['Hot', 'Pemula', 'Menengah', 'VIP'],
              _selectedModuleCategoryIndex,
              (idx) {
                setState(() {
                  _selectedModuleCategoryIndex = idx;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- COLORFUL PASTEL MODULE CARD (Hero Thumbnail Design) ---
  Widget _buildColorfulModuleCard({
    required LearningModuleModel module,
    required int index,
    required bool canAccess,
    required VoidCallback onTap,
  }) {
    const bgColor = Colors.white;
    const textColor = Color(0xFF0A122C);
    final subColor = Colors.grey.shade600;
    const accentColor = Color(0xFF005CFF);

    final imageBgColor = module.imageBgColor != null
        ? Color(int.parse(module.imageBgColor!))
        : const Color(0xFFE0F2FE); // Fallback color

    return HoverCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Content: Text and Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: subColor,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: module.isPremiumOnly
                              ? const Color(0xFFFF9F1C)
                              : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          module.isPremiumOnly ? 'VIP' : 'FREE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: module.isPremiumOnly ? Colors.white : const Color(0xFF005CFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Level Badge
                      if (module.stepsJson != null && module.stepsJson!['level'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            module.stepsJson!['level'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Content: Hero Thumbnail Image
            Hero(
              tag: 'module_img_${module.id}',
              child: Container(
                width: 110,
                height: 120,
                decoration: BoxDecoration(
                  color: imageBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: module.imageAsset != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          module.imageAsset!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.smart_toy_rounded, size: 40, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cute Vector Illustration at bottom right of each card (Matching Reference Image)
  Widget _buildCuteCardIllustration(int index, Color accentColor) {
    final icons = [
      Icons.emoji_objects_rounded, // Bulb / Sensor
      Icons.smart_toy_rounded,     // Robot
      Icons.wifi_tethering_rounded,// Radio / Wireless
      Icons.sports_esports_rounded,// Game controller
      Icons.auto_awesome_rounded,  // Stars / Wand
    ];
    final icon = icons[index % icons.length];

    return SizedBox(
      width: 100,
      height: 90,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Green Grassy Mound Curve at bottom right
          Positioned(
            right: -20,
            bottom: -25,
            child: Container(
              width: 110,
              height: 70,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          // Floating Cute Mascot / Icon
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: accentColor, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. DEVICE PROFILES TAB (DEVICE_PROFILES Table - Wavy Header) ---
  Widget _buildDeviceProfilesTab(dynamic user) {
    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: topInset + 200, bottom: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                ..._deviceProfiles.map((dev) {
                  final isWebSocket = dev.protocol == 'websocket';

                  return HoverCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    onTap: () => _showFeatureSnackbar('Profil Perangkat: ${dev.label}'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isWebSocket
                                  ? const Color(0xFF005CFF).withValues(alpha: 0.1)
                                  : const Color(0xFF00C2FF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isWebSocket ? Icons.wifi_rounded : Icons.bluetooth_rounded,
                              color: isWebSocket ? const Color(0xFF005CFF) : const Color(0xFF00C2FF),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dev.label,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A122C),
                                  ),
                                ),
                                Text(
                                  isWebSocket ? '${dev.host}:${dev.port}' : (dev.macAddress ?? 'N/A'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF2ED9C3), size: 24),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildWavyPageHeader(
            title: 'Device Profiles',
            subtitle: 'Kelola koneksi hardware WebSocket & BLE',
            topActionWidget: IconButton(
              icon: const Icon(Icons.add_link_rounded, color: Colors.white, size: 28),
              onPressed: () => _showAddDeviceModal(context),
            ),
            categoryPillsWidget: _buildHeaderCategoryPills(
              ['Semua', 'WebSocket', 'Bluetooth'],
              0,
              (idx) {},
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. USER PROFILE TAB (Wavy Header Style) ---
  Widget _buildUserProfileTab(dynamic user) {
    final userName = (user?.fullName.isNotEmpty == true) ? user!.fullName : 'Young Coder';
    final topInset = MediaQuery.of(context).padding.top;
    final topPadding = topInset > 0 ? topInset + 20 : 54.0;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: topInset + 230, bottom: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                _buildProfileMenuItem(
                  title: 'Account & ERD Details',
                  subtitle: user?.email ?? 'hello@xploria.com',
                  icon: Icons.person_outline_rounded,
                  onTap: () => _showFeatureSnackbar('UUID: ${user?.id}'),
                ),
                _buildProfileMenuItem(
                  title: 'Parental Control & Security',
                  subtitle: 'Safety and privacy settings',
                  icon: Icons.shield_outlined,
                  onTap: () => _showFeatureSnackbar('Pengaturan Keamanan'),
                ),
                _buildProfileMenuItem(
                  title: 'Notifications',
                  subtitle: 'Manage your alerts',
                  icon: Icons.notifications_none_rounded,
                  onTap: () => _showFeatureSnackbar('Notifikasi Ditampilkan'),
                ),
                _buildProfileMenuItem(
                  title: 'Themes & Appearance',
                  subtitle: 'Change app appearance',
                  icon: Icons.palette_outlined,
                  onTap: () => _showFeatureSnackbar('Tema Cerah Aktif'),
                ),
                _buildProfileMenuItem(
                  title: 'Help and support',
                  subtitle: 'Get help when you need it',
                  icon: Icons.help_outline_rounded,
                  onTap: () => _showFeatureSnackbar('Pusat Bantuan Xploria'),
                ),
                _buildProfileMenuItem(
                  title: 'Logout',
                  subtitle: 'Keluar dari akun',
                  icon: Icons.logout_rounded,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    AuthStorageService().clearSession();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: WaveHeaderClipper(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: topPadding, bottom: 44),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF005CFF), Color(0xFF00C2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar with Cyan Ring
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C2FF),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'Y',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF005CFF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lv 1  •  ${(user?.role ?? 'user').toUpperCase()} Dev',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final color = iconColor ?? const Color(0xFF00C2FF);

    return HoverCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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

  // --- CUSTOM FLOATING NAVBAR (Matching Reference Image) ---
  Widget _buildCustomFloatingNavbar(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // White Pill Container
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
                const SizedBox(width: 48), // Space for center floating button
                _buildNavbarItem(2, Icons.bar_chart_rounded, Icons.bar_chart_rounded),
                _buildNavbarItem(3, Icons.person_outline_rounded, Icons.person_rounded),
              ],
            ),
          ),

          // Floating Green Action Button in Top Center (Matching Reference Image "+")
          Positioned(
            top: -6,
            child: GestureDetector(
              onTap: () => _showCreateProjectModal(context),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF005CFF), // Blue matching theme
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

  void _showAddDeviceModal(BuildContext context) {
    _showFeatureSnackbar('Form Tambah Device Profile (WebSocket / Bluetooth)');
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
}

class WaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 35);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 22);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 44);
    final secondEndPoint = Offset(size.width, size.height - 18);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.margin,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          transform: _isHovered ? Matrix4.translationValues(0, -5, 0) : Matrix4.identity(),
          child: AnimatedScale(
            scale: _isHovered ? 1.025 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
