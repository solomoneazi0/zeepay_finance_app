import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/ride_option_model.dart';

/// Choose-a-ride sheet body (shared by [ZecarTripPlanningScreen] and [ZecarRideScreen]).
class ZecarRideSheetColumn extends StatelessWidget {
  const ZecarRideSheetColumn({
    super.key,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.onEditAddresses,
    required this.selectedRideId,
    required this.selected,
    required this.onRideSelected,
    required this.onReserve,
  });

  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final String pickupAddress;
  final String destinationAddress;
  final VoidCallback onEditAddresses;
  final String selectedRideId;
  final RideOption selected;
  final ValueChanged<String> onRideSelected;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Choose a ride',
            style: AppTextStyles.h3.copyWith(color: textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: border),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ZecarRideRouteAddressCard(
            border: border,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
            pickupAddress: pickupAddress,
            destinationAddress: destinationAddress,
            onEditPressed: onEditAddresses,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recommended',
            style: AppTextStyles.caption.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final ride in RideOptionsMock.recommended)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ZecarRideOptionTile(
                    ride: ride,
                    selected: ride.id == selectedRideId,
                    isDark: isDark,
                    onTap: () => onRideSelected(ride.id),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.wallet,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cash',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: textSecondary, size: 22),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomSafe),
          child: FilledButton(
            onPressed: onReserve,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: Text(
              '${selected.reserveVerb} ${selected.name}',
              style: AppTextStyles.button.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ZecarRideRouteAddressCard extends StatelessWidget {
  const ZecarRideRouteAddressCard({
    super.key,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.onEditPressed,
  });

  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final String pickupAddress;
  final String destinationAddress;
  final VoidCallback onEditPressed;

  String _pickupLine() {
    final t = pickupAddress.trim();
    if (t.isEmpty || t.toLowerCase() == 'current location') {
      return 'Current location';
    }
    return t;
  }

  String _destinationLine() {
    final t = destinationAddress.trim();
    if (t.isEmpty) return 'Add destination';
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final dropEmpty = destinationAddress.trim().isEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: textSecondary, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup',
                  style: AppTextStyles.caption.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _pickupLine(),
                  style: AppTextStyles.body.copyWith(color: textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  "You're going to",
                  style: AppTextStyles.caption.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _destinationLine(),
                  style: AppTextStyles.body.copyWith(
                    color: dropEmpty ? textSecondary : textPrimary,
                    fontStyle:
                        dropEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit pickup & destination',
            onPressed: onEditPressed,
            icon: Icon(Iconsax.edit_2, color: textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}

class ZecarRideOptionTile extends StatelessWidget {
  const ZecarRideOptionTile({
    super.key,
    required this.ride,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final RideOption ride;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    const selectBorder = AppColors.primary;

    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? selectBorder : border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Iconsax.car, size: 36, color: textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ride.name,
                            style: AppTextStyles.h4.copyWith(
                              color: textPrimary,
                            ),
                          ),
                        ),
                        if (ride.badgeLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightTextPrimary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 14,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ride.badgeLabel!,
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ride.etaLine,
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ride.priceLabel,
                    style: AppTextStyles.h4.copyWith(color: textPrimary),
                  ),
                  if (ride.strikePriceLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      ride.strikePriceLabel!,
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
