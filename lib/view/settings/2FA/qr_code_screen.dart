import 'dart:convert';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/UserLogin/user_login_model.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/2FA/two_fa_controller.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TwoFAController controller = Get.find<TwoFAController>();
    final userPrefs = UserPreferencesViewmodel();

    return FutureBuilder<LoginResponseModel?>(
      future: userPrefs.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            // backgroundColor: Color(0xFF0C0F1F),
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2A63FF))),
          );
        }

        final String? token = snapshot.data?.token;

        if (token == null || token.isEmpty) {
          return Scaffold(
            // backgroundColor: const Color(0xFF0C0F1F),
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  // color: const Color(0xFF11152A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Authentication token is missing. Please log in again.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A63FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Get.offAllNamed(RouteName.loginScreen);
                        },
                        child: const Text(
                          'Go to Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Fetch QR code
        controller.fetchQrCode(token);

        return Scaffold(
          // backgroundColor: const Color(0xFF0C0F1F),
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'scan_qr'.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'scan_qr_desc'.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (controller.isLoading.value)
                      const CircularProgressIndicator(color: Color(0xFF2A63FF))
                    else if (controller.qrCode.value.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.memory(
                          base64Decode(controller.qrCode.value
                              .replaceFirst('data:image/png;base64,', '')),
                          width: 200,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text(
                            'Failed to load QR code image',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                        ),
                      )
                    else
                      Text(
                        controller.errorMessage.value.isEmpty
                            ? 'Failed to load QR code'
                            : controller.errorMessage.value,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                    const SizedBox(height: 16),
                    if (controller.secretKey.value.isNotEmpty)
                      Column(
                        children: [
                          const Text(
                            'Or enter this secret key manually:',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.secretKey.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A63FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Get.toNamed(
                            RouteName.authenticatorVerification,
                            arguments: {
                              'method': 'authenticator',
                              'token': token
                            },
                          );
                        },
                        child: Text(
                          'next'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
