import 'package:flutter/material.dart';

class XploriaColors {
  static const bgTop = Color(0xFFEAF1FB);
  static const bgBottom = Color(0xFFF3F7FD);
  static const accent = Color(0xFF2F6FED);
  static const textPrimary = Color(0xFF1F3A66);
  static const textSecondary = Color(0xFF6B84A8);
  static const trackInactive = Color(0xFFD6E4F7);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.minDuration = const Duration(milliseconds: 1800),
  });

  /// Dipanggil setelah splash selesai (mis. navigasi ke dashboard/login).
  final VoidCallback onFinished;

  /// Durasi minimum splash ditampilkan, walau init selesai lebih cepat.
  final Duration minDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _bootstrap();
  }

  /// Ganti isi fungsi ini dengan init sebenarnya:
  /// - cek token tersimpan (flutter_secure_storage)
  /// - refresh JWT kalau perlu
  /// - preload config awal (hardware_types, dll)
  Future<void> _bootstrap() async {
    final start = DateTime.now();

    // TODO: ganti dengan pemanggilan use-case nyata, contoh:
    // final session = await ref.read(authRepositoryProvider).restoreSession();
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final elapsed = DateTime.now().difference(start);
    final remaining = widget.minDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [XploriaColors.bgTop, XploriaColors.bgBottom],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: XploriaColors.accent.withOpacity(0.08),
                          blurRadius: 0,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      size: 44,
                      color: XploriaColors.accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Xploria',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: XploriaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Explore. Build. Learn.',
                    style: TextStyle(
                      fontSize: 13,
                      color: XploriaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _SplashProgressBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Progress bar indeterminate ringan, tanpa dependency tambahan.
class _SplashProgressBar extends StatefulWidget {
  const _SplashProgressBar();

  @override
  State<_SplashProgressBar> createState() => _SplashProgressBarState();
}

class _SplashProgressBarState extends State<_SplashProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 4,
      decoration: BoxDecoration(
        color: XploriaColors.trackInactive,
        borderRadius: BorderRadius.circular(4),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Align(
            alignment: Alignment(_controller.value * 2 - 1, 0),
            child: FractionallySizedBox(
              widthFactor: 0.45,
              child: Container(
                decoration: BoxDecoration(
                  color: XploriaColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
