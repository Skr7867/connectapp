import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../res/color/app_colors.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();

    bool? savedTheme = storage.read('isDarkMode');
    if (savedTheme != null) {
      isDarkMode.value = savedTheme;
    }
  }

  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: AppColors.whiteColor,
        primaryColor: AppColors.blueShade,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.blackColor),
          bodyMedium: TextStyle(color: AppColors.blackColor),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.blueShade,
          foregroundColor: AppColors.blackColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.whiteColor,
          ),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        primaryColor: AppColors.loginContainerColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.whiteColor),
          bodyMedium: TextStyle(color: AppColors.whiteColor),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.loginContainerColor,
          foregroundColor: AppColors.whiteColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.whiteColor,
          ),
        ),
      );

  // Method to switch the theme
  void switchTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? darkTheme : lightTheme);
    // Save the theme preference
    storage.write('isDarkMode', isDarkMode.value);
  }

  // Method to get the current theme
  ThemeData get currentTheme => isDarkMode.value ? darkTheme : lightTheme;
}
