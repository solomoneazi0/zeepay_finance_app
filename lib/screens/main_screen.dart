import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zepay_app/screens/activity_screen.dart';
import 'package:zepay_app/screens/message_screen.dart';
import 'package:zepay_app/screens/promo%20tab/promo_screen.dart';
import '../widgets/bottom_nav.dart';
import 'home/home_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);

    // All screens
    final screens = [
      const HomeScreen(),
      const PromoScreen(),
      const ActivityScreen(),
      const MessageScreen(),
    ];

    return Scaffold(
      // IndexedStack keeps all screens alive
      // so state is preserved when switching tabs
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: const ZevoaBottomNav(),
    );
  }
}
