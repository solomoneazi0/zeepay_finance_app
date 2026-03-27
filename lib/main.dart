import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zepay_app/providers/theme_providers.dart';
import 'package:zepay_app/screens/onboardScreens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: ZePayApp()));
}

class ZePayApp extends ConsumerWidget {
  const ZePayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watches the provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ZePay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
