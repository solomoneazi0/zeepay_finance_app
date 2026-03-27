import 'package:flutter/foundation.dart';

enum SearchSuggestionType { recent, category, service }

@immutable
class SearchSuggestion {
  final SearchSuggestionType type;
  final String title;
  final String? subtitle;

  /// Optional payload (e.g. `ServiceModel`).
  final Object? data;

  const SearchSuggestion({
    required this.type,
    required this.title,
    this.subtitle,
    this.data,
  });
}

