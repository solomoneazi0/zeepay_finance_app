import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// One selectable package type (e.g. on ZeSend delivery details).
@immutable
class PackageCategory {
  const PackageCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Id for the "Others" option (requires a free-text description on delivery details).
  static const String kOthersId = 'others';

  /// Package-type options for the ZeSend delivery-details package grid.
  static const List<PackageCategory> zesendDelivery = [
    PackageCategory(id: 'food', label: 'Food', icon: Iconsax.cake),
    PackageCategory(id: 'books', label: 'Books', icon: Iconsax.book),
    PackageCategory(
      id: 'document',
      label: 'Document',
      icon: Iconsax.document_text,
    ),
    PackageCategory(
      id: 'cloths',
      label: 'Cloths',
      icon: Icons.checkroom_outlined,
    ),
    PackageCategory(id: 'medicine', label: 'Medicine', icon: Iconsax.hospital),
    PackageCategory(
      id: kOthersId,
      label: 'Others',
      icon: Iconsax.more_circle,
    ),
  ];
}
