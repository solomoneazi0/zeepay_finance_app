import 'package:flutter/foundation.dart';

/// ZeSend package size for driver handling (bottom sheet on delivery flow).
@immutable
class PackageSizeOption {
  const PackageSizeOption({
    required this.id,
    required this.title,
    required this.maxKg,
  });

  final String id;
  final String title;
  final int maxKg;

  String get label => '$title (Max. ${maxKg}kg)';

  static const List<PackageSizeOption> standard = [
    PackageSizeOption(id: 'small', title: 'Small', maxKg: 5),
    PackageSizeOption(id: 'medium', title: 'Medium', maxKg: 20),
    PackageSizeOption(id: 'large', title: 'Large', maxKg: 100),
  ];
}
