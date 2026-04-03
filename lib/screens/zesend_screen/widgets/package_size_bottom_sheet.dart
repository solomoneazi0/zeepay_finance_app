import 'package:flutter/material.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/package_size_option.dart';

/// Slides up from the bottom so the user can pick a package size, then taps Save.
/// Returns the selected [PackageSizeOption.id], or `null` if the sheet is dismissed.
Future<String?> showPackageSizeBottomSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _PackageSizeBottomSheetBody(isDark: isDark, surface: surface);
    },
  );
}

class _PackageSizeBottomSheetBody extends StatefulWidget {
  const _PackageSizeBottomSheetBody({
    required this.isDark,
    required this.surface,
  });

  final bool isDark;
  final Color surface;

  @override
  State<_PackageSizeBottomSheetBody> createState() =>
      _PackageSizeBottomSheetBodyState();
}

class _PackageSizeBottomSheetBodyState
    extends State<_PackageSizeBottomSheetBody> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = PackageSizeOption.standard.first.id;
  }

  List<Widget> _sizeOptionTiles(Color textPrimary, Color border) {
    final options = PackageSizeOption.standard;
    final tiles = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      final opt = options[i];
      tiles.add(
        InkWell(
          onTap: () => setState(() => _selectedId = opt.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    opt.label,
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: textPrimary,
                    ),
                  ),
                ),
                Radio<String>(
                  value: opt.id,
                  groupValue: _selectedId,
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedId = v);
                  },
                ),
              ],
            ),
          ),
        ),
      );
      if (i < options.length - 1) {
        tiles.add(Divider(height: 1, color: border, indent: 20, endIndent: 20));
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Theme(
        data: Theme.of(context).copyWith(
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return border;
            }),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's your package size?",
                    style: AppTextStyles.h3.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This helps the driver prepare & handle your packages better.',
                    style: AppTextStyles.body.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._sizeOptionTiles(textPrimary, border),
            const SizedBox(height: 8),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop<String>(_selectedId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
