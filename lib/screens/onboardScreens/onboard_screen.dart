import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/screens/home/home_screen.dart';
import 'package:zepay_app/screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Send Money,\nAnywhere Instantly',
      subtitle:
          'Transfer money to anyone, pay bills\nand top up your wallet in seconds.',
      lightImage: 'assets/images/onboard1screen.png',
      darkImage: 'assets/images/onboard1screendark.png',
    ),
    _OnboardingData(
      title: 'Rides, Food &\nDelivery On Demand',
      subtitle:
          'Book a ride, order food or send\nparcels to anyone at your doorstep.',
      lightImage: 'assets/images/onboard2screen.png',
      darkImage: 'assets/images/onboard2screendark.png',
    ),
    _OnboardingData(
      title: 'Shop Smarter,\nSave Every Day',
      subtitle:
          'Buy groceries, enjoy exclusive deals\nand get cashback with Zevoa Plus.',
      lightImage: 'assets/images/onboardslide3.png',
      darkImage: 'assets/images/onboard3screendark.png',
    ),
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fading Pages ──────────────────────────
          // Uses SizedBox.expand so AnimatedSwitcher
          // knows exactly how big to be
          SizedBox.expand(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _OnboardingPage(
                key: ValueKey(_currentPage),
                data: _pages[_currentPage],
                isDark: isDark,
                size: size,
              ),
            ),
          ),

          // ── Top Row: Dots + Skip ──────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots on the left
                  AnimatedSmoothIndicator(
                    activeIndex: _currentPage,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: Colors.white.withOpacity(0.4),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 6,
                    ),
                  ),

                  // Skip on the right
                  Opacity(
                    opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _currentPage >= _pages.length - 1,
                      child: GestureDetector(
                        onTap: _goToHome,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Button at bottom ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual Page Widget ─────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final bool isDark;
  final Size size;

  const _OnboardingPage({
    super.key,
    required this.data,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final image = isDark ? data.darkImage : data.lightImage;

    return Column(
      children: [
        // ── Image Area (top 70%) ───────────────────
        Expanded(
          flex: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The image
              Image.asset(image, fit: BoxFit.cover, width: double.infinity),

              // Gradient blending into card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Text Area (bottom 30%) ─────────────────
        Expanded(
          flex: 32,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 100),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                      data.title,
                      style: AppTextStyles.h1.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        height: 1.2,
                        fontSize: 32,
                        fontFamily: 'clash display',
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 200.ms,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                      data.subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.6,
                        fontSize: 14,
                        fontFamily: 'inter',
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 350.ms,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data Model for each slide ──────────────────────────────
class _OnboardingData {
  final String title;
  final String subtitle;
  final String lightImage;
  final String darkImage;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.lightImage,
    required this.darkImage,
  });
}
