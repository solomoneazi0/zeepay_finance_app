class RideOption {
  const RideOption({
    required this.id,
    required this.name,
    required this.etaLine,
    required this.priceLabel,
    this.strikePriceLabel,
    this.badgeLabel,
    this.reserveVerb = 'Book',
  });

  final String id;
  final String name;
  final String etaLine;
  final String priceLabel;
  final String? strikePriceLabel;
  final String? badgeLabel;
  final String reserveVerb;
}

class RideOptionsMock {
  RideOptionsMock._();

  static const List<RideOption> recommended = [
    RideOption(
      id: 'zeova_x',
      name: 'Zeova X',
      etaLine: 'Pickup tomorrow at 9:41 pm',
      priceLabel: r'$31.99',
      badgeLabel: 'Faster',
      reserveVerb: 'Reserve Comfort',
    ),
    RideOption(
      id: 'zeova_premier',
      name: 'Zeova Premier',
      etaLine: '12:30 pm • 3 min away',
      priceLabel: r'$49.99',
    ),
    RideOption(
      id: 'zeova_xl',
      name: 'Zeova XL',
      etaLine: '12:30 pm • 4 min away',
      priceLabel: r'$39.99',
      strikePriceLabel: r'$45.56',
    ),
  ];
}
