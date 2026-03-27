import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/search_suggestion.dart';
import 'package:zepay_app/models/services_model.dart';
import 'package:zepay_app/providers/search_providers.dart';
import 'package:zepay_app/screens/provided_services/service_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commitQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    ref.read(recentSearchesProvider.notifier).add(trimmed);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent = ref.watch(recentSearchesProvider);
    final quickItems = ref.watch(searchQuickItemsProvider);

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Search',
          style: AppTextStyles.h3.copyWith(color: textPrimary),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TypeAheadField<SearchSuggestion>(
                controller: _controller,
                focusNode: _focusNode,
                debounceDuration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(maxHeight: 380),
                suggestionsCallback: (pattern) async {
                  return ref.read(searchSuggestionsProvider(pattern));
                },
                itemBuilder: (context, suggestion) {
                  Widget leading;
                  if (suggestion.type == SearchSuggestionType.service &&
                      suggestion.data is ServiceModel) {
                    final s = suggestion.data! as ServiceModel;
                    leading = Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : s.bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(s.image, width: 24, height: 24),
                      ),
                    );
                  } else if (suggestion.type == SearchSuggestionType.category &&
                      suggestion.data is SearchQuickItem) {
                    final item = suggestion.data! as SearchQuickItem;
                    leading = Icon(item.icon, size: 18, color: textSecondary);
                  } else {
                    final fallback = switch (suggestion.type) {
                      SearchSuggestionType.recent => Iconsax.clock,
                      SearchSuggestionType.category => Iconsax.category,
                      SearchSuggestionType.service => Iconsax.element_4,
                    };
                    leading = Icon(fallback, size: 18, color: textSecondary);
                  }

                  return ListTile(
                    dense: true,
                    leading: leading,
                    title: Text(
                      suggestion.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    subtitle: suggestion.subtitle == null
                        ? null
                        : Text(
                            suggestion.subtitle!,
                            style: AppTextStyles.caption.copyWith(
                              color: textSecondary,
                            ),
                          ),
                  );
                },
                onSelected: (suggestion) {
                  _controller.text = suggestion.title;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                  _commitQuery(suggestion.title);

                  // For now, we keep the user on this screen. Next step is to
                  // route to a destination based on suggestion.type/data.
                },
                builder: (context, controller, focusNode) {
                  return Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.body.copyWith(color: textPrimary),
                      onSubmitted: _commitQuery,
                      decoration: InputDecoration(
                        hintText: 'Find services, food, & places',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: textSecondary,
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal,
                          size: 18,
                          color: textSecondary,
                        ),
                        suffixIcon: controller.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  controller.clear();
                                  setState(() {});
                                  _focusNode.requestFocus();
                                },
                                icon: Icon(
                                  Iconsax.close_circle,
                                  color: textSecondary,
                                ),
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  );
                },
                decorationBuilder: (context, child) {
                  return Material(
                    color: surface,
                    elevation: 6,
                    borderRadius: BorderRadius.circular(14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: child,
                    ),
                  );
                },
                emptyBuilder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'No matches yet.',
                      style: AppTextStyles.body.copyWith(color: textSecondary),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: _controller.text.trim().isEmpty
                      ? _SearchLanding(
                          isDark: isDark,
                          recent: recent,
                          quickItems: quickItems,
                          onTapRecent: (q) {
                            _controller.text = q;
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );
                            _commitQuery(q);
                          },
                          onDeleteRecent: (q) => ref
                              .read(recentSearchesProvider.notifier)
                              .remove(q),
                          onClearRecent: () =>
                              ref.read(recentSearchesProvider.notifier).clear(),
                          onTapQuickItem: (item) {
                            _controller.text = item.title;
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );
                            _commitQuery(item.title);
                          },
                        )
                      : _SearchResults(isDark: isDark, query: _controller.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchLanding extends StatelessWidget {
  final bool isDark;
  final List<String> recent;
  final List<SearchQuickItem> quickItems;
  final ValueChanged<String> onTapRecent;
  final ValueChanged<String> onDeleteRecent;
  final VoidCallback onClearRecent;
  final ValueChanged<SearchQuickItem> onTapQuickItem;

  const _SearchLanding({
    required this.isDark,
    required this.recent,
    required this.quickItems,
    required this.onTapRecent,
    required this.onDeleteRecent,
    required this.onClearRecent,
    required this.onTapQuickItem,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final chipBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: AppTextStyles.h4.copyWith(color: textPrimary),
              ),
              TextButton(
                onPressed: onClearRecent,
                child: Text(
                  'Clear',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final q in recent)
                InputChip(
                  label: Text(
                    q,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                  ),
                  backgroundColor: chipBg,
                  deleteIcon: Icon(
                    Iconsax.close_circle,
                    size: 18,
                    color: textSecondary,
                  ),
                  onPressed: () => onTapRecent(q),
                  onDeleted: () => onDeleteRecent(q),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
        ],

        Text('Explore', style: AppTextStyles.h4.copyWith(color: textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in quickItems)
              ActionChip(
                avatar: Icon(item.icon, size: 16, color: textSecondary),
                label: Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
                ),
                backgroundColor: chipBg,
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                onPressed: () => onTapQuickItem(item),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final bool isDark;
  final String query;

  const _SearchResults({required this.isDark, required this.query});

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final matches = ServicesData.services
        .where((s) => s.name.toLowerCase().contains(q))
        .toList(growable: false);

    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No services match “$query”.',
          style: AppTextStyles.body.copyWith(color: textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = matches[index];
        return _ServiceResultTile(
          isDark: isDark,
          service: service,
          onTap: () => openServiceScreen(context, service.name),
        );
      },
    );
  }
}

class _ServiceResultTile extends StatelessWidget {
  final bool isDark;
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceResultTile({
    required this.isDark,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : service.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(service.image, width: 24, height: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Service',
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3, size: 18, color: textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
