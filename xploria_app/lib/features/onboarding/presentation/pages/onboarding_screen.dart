import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Use a very large initial page to allow infinite scrolling in both directions
  // Starting at 1000 * length so it's a multiple of the item count.
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Satu Aplikasi. Ribuan Eksperimen.",
      "description": "Lewati teori yang membosankan. Rangkai logika codingmu dan wujudkan ke eksperimen Fisika, Biologi, hingga Ekonomi dalam satu ekosistem.",
      "image": "assets/images/char/onboarding1.png",
    },
    {
      "title": "Kode di Layar, Aksi di Dunia Nyata.",
      "description": "Jangan cuma berhenti di layar aplikasimu. Terbangkan drone, gerakkan robot, dan kendalikan mesin langsung dari susunan blok kodemu.",
      "image": "assets/images/char/onboarding2.png",
    },
    {
      "title": "Masuk Lab Sekarang.",
      "description": "Akses instan. Gunakan email sekolahmu untuk langsung terhubung ke kelas dan proyekmu hari ini.",
      "image": "assets/images/char/onboarding3.png",
    }
  ];

  // Slide button variables
  double _dragPosition = 0.0;
  bool _isDragging = false;
  final double _buttonHeight = 56.0;
  final double _sliderWidth = 56.0;

  @override
  void initState() {
    super.initState();
    final initialPage = _onboardingData.length * 1000;
    _pageController = PageController(initialPage: initialPage);
    _currentPage = initialPage;

    // Auto scroll every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, double maxWidth) {
    setState(() {
      _isDragging = true;
      _dragPosition += details.delta.dx;
      // Clamp the position between 0 and the maximum drag distance
      _dragPosition = _dragPosition.clamp(0.0, maxWidth - _sliderWidth);
    });
  }

  void _onPanEnd(DragEndDetails details, double maxWidth) {
    setState(() {
      _isDragging = false;
    });
    // If dragged more than 75% of the way, complete the action
    if (_dragPosition > (maxWidth - _sliderWidth) * 0.75) {
      setState(() {
        _dragPosition = maxWidth - _sliderWidth;
      });
      // Navigate to welcome
      context.go('/welcome');
    } else {
      // Snap back to start
      setState(() {
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  // Calculate the actual data index using modulo
                  final dataIndex = index % _onboardingData.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Image.asset(
                          _onboardingData[dataIndex]["image"]!,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _onboardingData[dataIndex]["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[dataIndex]["description"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _onboardingData.length,
                            (dotIndex) => buildDot(index: dotIndex, currentDataIndex: _currentPage % _onboardingData.length),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  return Container(
                    height: _buttonHeight,
                    width: maxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE300CD),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Stack(
                      children: [
                        // Center text
                        const Center(
                          child: Text(
                            "Ayo Mulai",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Draggable slider button
                        AnimatedPositioned(
                          duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          left: _dragPosition,
                          top: 0,
                          child: GestureDetector(
                            onPanUpdate: (details) => _onPanUpdate(details, maxWidth),
                            onPanEnd: (details) => _onPanEnd(details, maxWidth),
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              width: _sliderWidth - 8,
                              height: _buttonHeight - 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Color(0xFFE300CD),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot({required int index, required int currentDataIndex}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: currentDataIndex == index ? const Color(0xFF9E00FF) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
