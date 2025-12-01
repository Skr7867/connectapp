import 'package:flutter/material.dart';

class ResponsivePadding {
  static EdgeInsets symmetricPadding(BuildContext context,
      {double horizontal = 0, double vertical = 0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return EdgeInsets.symmetric(
      horizontal: screenWidth * horizontal / 100,
      vertical: screenHeight * vertical / 100,
    );
  }

  static EdgeInsets allPadding(BuildContext context, double percentage) {
    final screenWidth = MediaQuery.of(context).size.width;
    return EdgeInsets.all(screenWidth * percentage / 100);
  }

  static EdgeInsets customPadding(BuildContext context,
      {double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return EdgeInsets.only(
      left: screenWidth * left / 100,
      top: screenHeight * top / 100,
      right: screenWidth * right / 100,
      bottom: screenHeight * bottom / 100,
    );
  }
}
