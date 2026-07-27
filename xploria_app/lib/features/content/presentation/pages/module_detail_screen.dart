import 'package:flutter/material.dart';
import '../../../content/domain/models/learning_module_model.dart';

class ModuleDetailScreen extends StatelessWidget {
  final LearningModuleModel module;
  final bool canAccess;

  const ModuleDetailScreen({
    Key? key,
    required this.module,
    required this.canAccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageBgColor = module.imageBgColor != null
        ? Color(int.parse(module.imageBgColor!))
        : const Color(0xFFE0F2FE);

    return Scaffold(
      backgroundColor: imageBgColor,
      body: Stack(
        children: [
          // Background / Top Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              decoration: BoxDecoration(color: imageBgColor),
              child: module.imageAsset != null
                  ? Image.asset(
                      module.imageAsset!,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(Icons.smart_toy_rounded, size: 80, color: Colors.white),
                    ),
            ),
          ),

          // Custom Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Animated Bottom Sheet / Content
          Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) {
                return FractionalTranslation(
                  translation: offset,
                  child: child,
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55, // Overlaps the image slightly
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and VIP/Free row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0A122C),
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: module.isPremiumOnly
                                ? const Color(0xFFFF9F1C)
                                : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            module.isPremiumOnly ? 'VIP' : 'FREE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: module.isPremiumOnly ? Colors.white : const Color(0xFF005CFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      module.description ?? 'Pelajari lebih lanjut tentang modul ini dan tingkatkan kemampuan coding Anda.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Cards (Level, Steps, etc)
                    Row(
                      children: [
                        _buildInfoCard(
                          'Level',
                          module.stepsJson['level']?.toString() ?? 'Semua',
                          Icons.bar_chart_rounded,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                          'Materi',
                          '${module.stepsJson['steps'] ?? 5} Tahap',
                          Icons.menu_book_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: canAccess ? () {
                          // TODO: Navigate to learning workspace
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Membuka materi pelajaran...')),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005CFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF005CFF).withValues(alpha: 0.5),
                        ),
                        child: Text(
                          canAccess ? 'Mulai Belajar' : 'Terkunci untuk VIP',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
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

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0A122C),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
