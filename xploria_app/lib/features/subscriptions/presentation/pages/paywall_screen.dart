import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../../account/data/repositories/account_repository.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionRepository _repository = SubscriptionRepository();
  bool _isLoading = false;
  String _selectedTier = 'premium';

  Future<void> _handleSubscribe() async {
    setState(() => _isLoading = true);
    try {
      // 1. Panggil API Subscription untuk membuat langganan (MOCK checkout)
      await _repository.subscribe(_selectedTier);
      
      // 2. Refresh profil user dari backend agar isPremium menjadi true
      // Kita panggil auth api me
      final accountRepo = AccountRepository();
      await accountRepo.getUserProfile(); // refresh user info // Ini akan memperbarui data di AuthStorage
      if (mounted) {
        // Tampilkan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pembayaran Berhasil! Selamat datang di Xploria Pro! 🚀'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(true); // Return true menandakan sukses langganan
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal berlangganan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
      backgroundColor: const Color(0xFF0F172A), // Dark premium background
      body: Stack(
        children: [
          // Background Gradient effect
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF005CFF).withValues(alpha: 0.2),
                // Blur filter removed
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(false),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Crown Icon or Logo
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 64,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Buka Potensi Penuh\ndengan Xploria Pro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Akses semua modul pembelajaran IoT tingkat lanjut, buat proyek tanpa batas, dan nikmati kanvas Blynk VIP.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Features List
                        _buildFeatureItem(Icons.check_circle_rounded, 'Akses ke semua modul Premium'),
                        _buildFeatureItem(Icons.check_circle_rounded, 'Proyek Blockly tanpa batas'),
                        _buildFeatureItem(Icons.check_circle_rounded, 'Template Blynk Canvas VIP'),
                        _buildFeatureItem(Icons.check_circle_rounded, 'Sertifikat kelulusan digital'),
                        
                        const SizedBox(height: 40),

                        // Pricing Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildPricingCard(
                                title: 'Bulanan',
                                price: 'Rp 49.000',
                                duration: '/ bulan',
                                isSelected: _selectedTier == 'premium',
                                onTap: () => setState(() => _selectedTier = 'premium'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPricingCard(
                                title: 'Tahunan',
                                price: 'Rp 490.000',
                                duration: '/ tahun',
                                isSelected: _selectedTier == 'pro',
                                badge: 'HEMAT 20%',
                                onTap: () => setState(() => _selectedTier = 'pro'),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Subscribe Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubscribe,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005CFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading 
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Mulai Berlangganan Sekarang',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Restore purchase logic here later
                          },
                          child: Text(
                            'Pulihkan Pembelian (Restore Purchase)',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E3A2), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String duration,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005CFF).withValues(alpha: 0.1) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF005CFF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF005CFF) : Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              duration,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
