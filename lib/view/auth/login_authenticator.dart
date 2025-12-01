import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/controller/login/two_fa_verify_login_controller.dart';

class LoginAuthenticator extends StatelessWidget {
  const LoginAuthenticator({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final TwoFaVerifyLoginController controller =
        Get.put(TwoFaVerifyLoginController());

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.4,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: ResponsivePadding.symmetricPadding(context,
                      horizontal: 4),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'authenticator_verification'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      Text(
                        'login_code'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: AppFonts.opensansRegular,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: ResponsivePadding.customPadding(context,
                            right: 47, top: 2, bottom: 1),
                        child: Text(
                          'verification_code'.tr,
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      Obx(
                        () => CustomTextField(
                          controller: controller.otpController.value,
                          prefixIcon: Icons.lock,
                          hintText: 'enter_6_digit'.tr,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.07),
                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.whiteColor,
                            minimumSize:
                                Size(screenWidth * 0.9, screenHeight * 0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.verifyOtp,
                          child: Text(
                            controller.isLoading.value
                                ? 'veryfying'.tr
                                : 'verify'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppFonts.opensansRegular,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
