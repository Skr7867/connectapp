import 'package:flutter/material.dart';

class AppColors {
  static const Color blackColor = Color(0xff202020);
  static const Color greyColor = Color(0xff808791);
  static const Color buttonColor = Color(0xFF4834d4);
  static const Color blueShade = Color.fromARGB(255, 120, 131, 146);
  static const Color whiteColor = Color(0xffffffff);
  static const Color loginContainerColor = Color(0xffFAFAFA);
  static const Color textfieldColor = Color(0xffEAEAF0);
  static const Color textColor = Color(0xff79808B);
  static Color greenColor = Colors.green;
  static Color redColor = Colors.red;
  static Color yellowColor = Colors.yellow;
  static Color blueColor = Colors.blue;
  static Color courseButtonColor = Color(0xff4538A7);
  static Color messageboxColor = Color(0xffD0D0D0);

  static const List<Color> gradientColors = [
    Color(0xFF5E65EA),
    Color(0xFF3F7DF4),
  ];
  static const LinearGradient primaryGradient = LinearGradient(
    colors: gradientColors,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient exploreGradient = LinearGradient(
    colors: [
      Color(0xFF6C5CE7),
      Color(0xFF6366F1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientexplore = LinearGradient(
    colors: [
      Color(0xff0f0c29),
      Color(0xFF302b63),
      Color(0xFF24243e),
      Color(0xff0f0c29),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
