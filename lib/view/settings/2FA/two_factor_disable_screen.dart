import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/2FA/two_fa_controller.dart';
import 'dart:developer';

import '../../../view_models/controller/userPreferences/user_preferences_screen.dart';

class TwoFactorDisableScreen extends StatefulWidget {
  const TwoFactorDisableScreen({super.key});

  @override
  State<TwoFactorDisableScreen> createState() => _TwoFactorDisableScreenState();
}

class _TwoFactorDisableScreenState extends State<TwoFactorDisableScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TwoFAController twoFAController = Get.find<TwoFAController>();
  final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
  String token = '';

  @override
  void initState() {
    super.initState();
    // Fetch token when the screen initializes
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await userPreferences.getUser();
    if (user != null) {
      setState(() {
        token = user.token;
      });
      log('Token retrieved for TwoFactorDisableScreen: ${token.substring(0, 10)}...');
    } else {
      log('No valid user token found');
      Get.snackbar(
        'Error',
        'Session expired. Please log in again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        isDismissible: true,
      );
      Get.offNamed(RouteName.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Disable 2FA',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: screenHeight,
        width: screenWidth,
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsivePadding.symmetricPadding(context,
                horizontal: orientation == Orientation.portrait ? 4 : 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: orientation == Orientation.portrait
                        ? screenHeight * 0.25
                        : screenHeight * 0.13),
                Text(
                  textAlign: TextAlign.center,
                  'Enter your password to disable Two-Factor Authentication.',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: AppFonts.opensansRegular),
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                    borderRadius: 25,
                    fillColor: AppColors.textfieldColor,
                    controller: passwordController,
                    prefixIcon: Icons.key,
                    isPassword: true,
                    hintText: 'Enter your password'),
                SizedBox(
                    height: orientation == Orientation.portrait
                        ? screenHeight * 0.02
                        : screenHeight * 0.03),
                Obx(
                  () => Center(
                    child: SizedBox(
                      width: orientation == Orientation.portrait
                          ? screenWidth * 0.9
                          : screenWidth * 0.7,
                      height: orientation == Orientation.portrait
                          ? screenHeight * 0.06
                          : screenHeight * 0.12,
                      child: ElevatedButton(
                        onPressed: twoFAController.isLoading.value
                            ? null
                            : () async {
                                if (token.isEmpty) {
                                  Utils.snackBar(
                                      'Session expired. Please log in again.',
                                      'Error');
                                  Get.offNamed(RouteName.loginScreen);
                                  return;
                                }
                                await twoFAController.disable2FA(
                                  token,
                                  passwordController.text,
                                );
                                if (!twoFAController.isLoading.value &&
                                    twoFAController
                                        .errorMessage.value.isEmpty) {
                                  Get.back();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: Colors.white,
                        ),
                        child: twoFAController.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Disable 2FA',
                                style: TextStyle(
                                    fontFamily: AppFonts.opensansRegular,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
