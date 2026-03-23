import 'package:flutter/material.dart';

class ServiceModel {
  final String name;
  final String image;
  final Color bgColor;

  const ServiceModel({
    required this.name,
    required this.image,
    required this.bgColor,
  });
}

class ServicesData {
  static const List<ServiceModel> services = [
    ServiceModel(
      name: 'ZeRide',
      image: 'assets/images/Zeride.png',
      bgColor: Color(0xFFE3F2FD),
    ),
    ServiceModel(
      name: 'ZeCar',
      image: 'assets/images/Zercar.png',
      bgColor: Color(0xFFE3F2FD),
    ),
    ServiceModel(
      name: 'ZeFood',
      image: 'assets/images/Zeefood.png',
      bgColor: Color(0xFFE3F2FD),
    ),
    ServiceModel(
      name: 'ZeSend',
      image: 'assets/images/Zesend.png',
      bgColor: Color(0xFFE3F2FD),
    ),
    ServiceModel(
      name: 'ZeMart',
      image: 'assets/images/zEMART.png',
      bgColor: Color(0xFFE3F2FD),
    ),
    ServiceModel(
      name: 'ZePay',
      image: 'assets/images/ZEPAY.png',
      bgColor: Color(0xFFE3F2FD),
    ),
    ServiceModel(
      name: 'ZeTransit',
      image: 'assets/images/ZETRASNIT.png',
      bgColor: Color(0xFFE3F2FD),
    ),
    ServiceModel(
      name: 'More',
      image: 'assets/images/MORE.png',
      bgColor: Color(0xFFE3F2FD),
    ),
  ];
}
