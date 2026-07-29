import 'package:flutter/material.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';
import '../../../auth/presentation/pages/welcome_screen.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../dashboard/presentation/widgets/dashboard_shared_widgets.dart';
import '../../data/repositories/account_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final userName = (_user?.fullName.isNotEmpty == true) ? _user!.fullName : 'Young Coder';
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
                  subtitle: _user?.email ?? 'hello@xploria.com',
                  icon: Icons.person_outline_rounded,
                  onTap: () => _showFeatureSnackbar('UUID: ${_user?.id}'),
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
              height: topPadding + 175,
              padding: EdgeInsets.only(top: topPadding - 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF005CFF), Color(0xFF00C2FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
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
}

