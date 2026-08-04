import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../data/repositories/account_repository.dart';
import 'edit_account_screen.dart';
import '../../../../core/config/app_constants.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AccountRepository _repository = AccountRepository();
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _repository.getUserProfile();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  void _showFeatureSnackbar(String message) {
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
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF4F6F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Icon(Icons.close, color: Colors.black87, size: 20),
                            ),
                          ),
                        ),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003092),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          // Card 1: Account, Parental Control, Notifications
                          _buildSettingsGroup([
                            _buildSettingsItem(
                              icon: Icons.person_outline_rounded,
                              iconColor: const Color(0xFF005CFF),
                              iconBgColor: const Color(0xFFDDE5FF),
                              title: 'Account',
                              onTap: () async {
                                context.pop(); // close modal
                                final result = await context.push<bool>('/edit-account') ?? 
                                               await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const EditAccountScreen()));
                                
                                if (result == true) {
                                  _loadData();
                                }
                              },
                            ),
                            _buildSettingsDivider(),
                            _buildSettingsItem(
                              icon: Icons.shield_outlined,
                              iconColor: const Color(0xFFFF7A00),
                              iconBgColor: const Color(0xFFFFE8D6),
                              title: 'Parental Control & Security',
                              onTap: () {
                                context.pop();
                                _showFeatureSnackbar('Pengaturan Keamanan');
                              },
                            ),
                            _buildSettingsDivider(),
                            _buildSettingsItem(
                              icon: Icons.notifications_none_rounded,
                              iconColor: const Color(0xFF005CFF),
                              iconBgColor: const Color(0xFFDDE5FF),
                              title: 'Notifications',
                              onTap: () {
                                context.pop();
                                _showFeatureSnackbar('Notifikasi Ditampilkan');
                              },
                            ),
                          ]),
                          
                          const SizedBox(height: 16),
                          
                          // Card 2: Appearance
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'APPEARANCE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F6F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            context.pop();
                                            _showFeatureSnackbar('Tema Cerah Aktif');
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                )
                                              ]
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text('Light', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003092))),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            context.pop();
                                            _showFeatureSnackbar('Tema Gelap Aktif');
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            alignment: Alignment.center,
                                            child: Text('Dark', style: TextStyle(color: Colors.grey.shade600)),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            context.pop();
                                            _showFeatureSnackbar('Tema Sistem Aktif');
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            alignment: Alignment.center,
                                            child: Text('Auto', style: TextStyle(color: Colors.grey.shade600)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Card 3: Support
                          _buildSettingsGroup([
                            _buildSettingsItem(
                              icon: Icons.info_outline_rounded,
                              iconColor: const Color(0xFF005CFF),
                              iconBgColor: const Color(0xFFDDE5FF),
                              title: 'About',
                              onTap: () {
                                context.pop();
                                _showFeatureSnackbar('Tentang Xploria');
                              },
                            ),
                            _buildSettingsDivider(),
                            _buildSettingsItem(
                              icon: Icons.help_outline_rounded,
                              iconColor: Colors.blueGrey,
                              iconBgColor: Colors.blueGrey.shade100,
                              title: 'Help',
                              onTap: () {
                                context.pop();
                                _showFeatureSnackbar('Pusat Bantuan Xploria');
                              },
                            ),
                            _buildSettingsDivider(),
                            _buildSettingsItem(
                              icon: Icons.flag_outlined,
                              iconColor: Colors.blueGrey,
                              iconBgColor: Colors.blueGrey.shade100,
                              title: 'Report a problem',
                              onTap: () {
                                context.pop();
                                _showFeatureSnackbar('Laporkan Masalah');
                              },
                            ),
                          ]),
                          
                          const SizedBox(height: 16),
                          
                          // Card 4: Logout
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: InkWell(
                              onTap: () async {
                                await AuthStorageService().clearSession();
                                try {
                                  await GoogleSignIn().signOut();
                                } catch (_) {}
                                
                                if (context.mounted) {
                                  context.go('/welcome');
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Log out',
                                    style: TextStyle(
                                      color: Color(0xFFD32F2F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 56);
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A122C),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6F9),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = (_user?.fullName.isNotEmpty == true) ? _user!.fullName : 'Young Coder';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'Y';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name, Settings
              Row(
                children: [
                  if (_user?.photoUrl != null && _user!.photoUrl!.isNotEmpty)
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFDDE5FF),
                      backgroundImage: NetworkImage(
                        _user!.photoUrl!.startsWith('http') 
                            ? _user!.photoUrl! 
                            : '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}${_user!.photoUrl}'
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDE5FF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005CFF),
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A122C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: _showSettingsModal,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF005CFF),
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Premium Banner
            if (_user?.isPremium != true)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005CFF), Color(0xFF00E3A2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF005CFF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final success = await context.push('/paywall');
                      if (success == true) {
                        _loadData();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Upgrade ke Xploria Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Dapatkan akses modul tanpa batas!', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Stats Row: Max Streak & Lifetime XP
            Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.bolt_rounded, color: Color(0xFF005CFF), size: 24),
                              SizedBox(width: 8),
                              Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A122C))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Max Streak', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.star_rounded, color: Color(0xFF005CFF), size: 24),
                              SizedBox(width: 8),
                              Text('140', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A122C))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Lifetime XP', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Weekly Leaderboard
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDE5FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, color: Color(0xFF005CFF), size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Weekly Leaderboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A122C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are currently Rank #12',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () {
                        _showFeatureSnackbar('Leaderboard belum tersedia');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'View Leaderboard',
                            style: TextStyle(
                              color: Color(0xFF005CFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Color(0xFF005CFF), size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Achievements & Badges
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Achievements &\nBadges',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A122C),
                          height: 1.2,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _showFeatureSnackbar('Achievements belum tersedia');
                      },
                      child: const Text(
                        'View\nAll',
                        style: TextStyle(
                          color: Color(0xFF005CFF),
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

