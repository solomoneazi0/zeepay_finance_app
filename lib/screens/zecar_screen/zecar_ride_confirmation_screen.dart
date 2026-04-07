import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';

/// Shown after the user confirms a ride from the choose-a-ride sheet.
class ZecarRideConfirmationScreen extends StatelessWidget {
  static const String _carLottieAsset =
      'assets/images/Car Animation JSON.json';

  const ZecarRideConfirmationScreen({
    super.key,
    required this.rideName,
    required this.reserveLine,
  });

  final String rideName;
  final String reserveLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _exitToAppRoot(context),
                  icon: Icon(Icons.close, color: textSecondary),
                  tooltip: 'Close',
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  _carLottieAsset,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your ride is on the way',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(color: textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'We are finding a driver for you. You booked $rideName.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reserveLine,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _exitToAppRoot(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Done',
                    style: AppTextStyles.button.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16 + MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );
  }

  void _exitToAppRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
