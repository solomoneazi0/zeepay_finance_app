import 'package:flutter/material.dart';
import 'package:zepay_app/screens/zecar_screen/zecar_trip_planning_screen.dart';
import 'package:zepay_app/screens/zesend_screen/zesend_screen.dart';

void openServiceScreen(BuildContext context, String serviceName) {
  switch (serviceName.toLowerCase()) {
    case 'zesend':
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ZeSendScreen()));
      break;
    case 'zecar':
    case 'zeride':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ZecarTripPlanningScreen(),
        ),
      );
      break;
    default:
      // Keep silent for services not wired yet.
      break;
  }
}
