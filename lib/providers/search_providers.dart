import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/models/search_suggestion.dart';
import 'package:zepay_app/models/services_model.dart';

const int _maxRecentSearches = 10;

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super(const []);

  void add(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final normalized = trimmed.toLowerCase();
    final next = <String>[
      trimmed,
      for (final q in state)
        if (q.toLowerCase() != normalized) q,
    ];

    if (next.length > _maxRecentSearches) {
      state = next.take(_maxRecentSearches).toList(growable: false);
      return;
    }

    state = List.unmodifiable(next);
  }

  void remove(String query) {
    state = List.unmodifiable(state.where((q) => q != query));
  }

  void clear() {
    state = const [];
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
      (ref) => RecentSearchesNotifier(),
    );

@immutable
class SearchQuickItem {
  final String title;
  final IconData icon;

  const SearchQuickItem({required this.title, required this.icon});
}

final searchQuickItemsProvider = Provider<List<SearchQuickItem>>((ref) {
  return const [
    SearchQuickItem(title: 'Food', icon: Iconsax.cake),
    SearchQuickItem(title: 'Rides', icon: Iconsax.car),
    SearchQuickItem(title: 'Bills', icon: Iconsax.receipt),
    SearchQuickItem(title: 'Airtime', icon: Iconsax.mobile),
    SearchQuickItem(title: 'Transfers', icon: Iconsax.repeat),
    SearchQuickItem(title: 'Groceries', icon: Iconsax.shopping_bag),
    SearchQuickItem(title: 'Delivery', icon: Iconsax.box),
    SearchQuickItem(title: 'Transport', icon: Iconsax.bus),
    SearchQuickItem(title: 'ZeRide', icon: Iconsax.car),
    SearchQuickItem(title: 'ZeCar', icon: Iconsax.car),
    SearchQuickItem(title: 'ZeFood', icon: Iconsax.cake),
    SearchQuickItem(title: 'ZeSend', icon: Iconsax.box),
    SearchQuickItem(title: 'ZeMart', icon: Iconsax.shopping_bag),
    SearchQuickItem(title: 'ZePay', icon: Iconsax.wallet),
    SearchQuickItem(title: 'ZeTransit', icon: Iconsax.bus),
    SearchQuickItem(title: 'More', icon: Iconsax.more),
  ];
});

final searchSuggestionsProvider =
    Provider.family<List<SearchSuggestion>, String>((ref, rawQuery) {
      final query = rawQuery.trim();
      if (query.isEmpty) return const [];

      final q = query.toLowerCase();
      final recent = ref.watch(recentSearchesProvider);
      final quickItems = ref.watch(searchQuickItemsProvider);
      final services = ServicesData.services;

      final suggestions = <SearchSuggestion>[];

      // Recent matches first.
      for (final r in recent) {
        if (r.toLowerCase().contains(q)) {
          suggestions.add(
            SearchSuggestion(type: SearchSuggestionType.recent, title: r),
          );
        }
      }

      // Category matches.
      for (final item in quickItems) {
        if (item.title.toLowerCase().contains(q)) {
          suggestions.add(
            SearchSuggestion(
              type: SearchSuggestionType.category,
              title: item.title,
              data: item,
            ),
          );
        }
      }

      // Service matches.
      for (final s in services) {
        if (s.name.toLowerCase().contains(q)) {
          suggestions.add(
            SearchSuggestion(
              type: SearchSuggestionType.service,
              title: s.name,
              data: s,
            ),
          );
        }
      }

      return suggestions;
    });
