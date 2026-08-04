import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionRepository _repository = SubscriptionRepository();
  bool _isLoading = false;
  String _selectedTier =
      'pro'; // default ke tahunan, biar konsisten sama badge hemat

  // Light Mode Colors (Headspace inspired)
  static const Color _bg = Color(0xFFFDFBF7); // Creamy white background
  static const Color _card = Color(
    0xFFF5F4F0,
  ); // Light grey/cream for unselected card
  static const Color _accentBtn = Color(
    0xFF0066FF,
  ); // Blue for button and links
  static const Color _accentCard = Color(
    0xFFFF7A00,
  ); // Orange for selected card and ticks
  static const Color _textColor = Color(0xFF2D2D2D); // Dark grey/black for text

  Future<void> _handleSubscribe() async {
    setState(() => _isLoading = true);
    try {
      await _repository.subscribe(_selectedTier);
      await AuthStorageService().updatePremiumStatus(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Pembayaran Berhasil! Selamat datang di Xploria Pro! 🚀',
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal berlangganan: '),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 60, // Padding for header
                24,
                MediaQuery.of(context).padding.bottom +
                    160, // Padding for footer
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Illustration (Sun Image)
                  Center(
                    child: Image.asset(
                      'assets/icons/headspace_sun.png',
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Buka Potensi Penuh\ndengan Xploria Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Akses semua modul pembelajaran IoT tingkat lanjut, buat proyek tanpa batas, dan nikmati kanvas Blynk VIP.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Features
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Column(
                      children: [
                        _buildFeatureItem('Akses ke semua modul Premium'),
                        _buildFeatureItem('Proyek Blockly tanpa batas'),
                        _buildFeatureItem('Template Blynk Canvas VIP'),
                        _buildFeatureItem(
                          'Sertifikat kelulusan digital',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pricing
                  _buildPricingTile(
                    tier: 'pro',
                    title: 'Tahunan',
                    price: 'Rp 490.000',
                    duration: '(Rp 40.833/bulan)',
                    subtitle: 'ditagih tahunan setelah percobaan 14 hari',
                    badge: 'Best value',
                  ),
                  const SizedBox(height: 12),
                  _buildPricingTile(
                    tier: 'premium',
                    title: 'Bulanan',
                    price: 'Rp 49.000',
                    duration: '/bulan',
                    subtitle: 'ditagih bulanan setelah percobaan 7 hari',
                  ),
                ],
              ),
            ),
          ),

          // 2. Glassmorphism Header (Close Button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  color: _bg.withValues(alpha: 0.8), // Transparan putih
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.black54,
                            size: 28,
                          ),
                          onPressed: () => context.pop(false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Glassmorphism Footer (Action Area)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: _bg.withValues(alpha: 0.8), // Transparan putih
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Pulihkan Pembelian',
                              style: TextStyle(
                                color: _accentBtn,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '•',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Syarat & Ketentuan',
                              style: TextStyle(
                                color: _accentBtn,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubscribe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentBtn,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Text(
                                  'Coba gratis dan berlangganan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: _accentCard, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTile({
    required String tier,
    required String title,
    required String price,
    required String duration,
    required String subtitle,
    String? badge,
  }) {
    final bool isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: isSelected ? _accentCard : _card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.grey.shade600,
                            fontSize: 13.5,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(
                              text: price,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' $duration setelah percobaan'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.grey.shade600,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accentBtn,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
