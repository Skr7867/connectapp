import 'dart:developer';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/assets/image_assets.dart';
import '../../res/routes/routes_name.dart';
import '../../utils/utils.dart';
import '../../view_models/controller/forgetpassword/otp_verification_controller.dart';
import '../forgetpassword/step_indicator.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final verifyOtpController = Get.put(OtpVerificationController());
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final String? email = args?['email'];
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 7),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.07),
                Center(
                  child: Image.asset(
                    ImageAssets.lockIcon,
                    height: 200,
                    width: 200,
                  ),
                ),
                Text(
                  'Verify Your Identity',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                Text(
                  'Enter the 6-digit OTP sent to your email',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                  maxLength: 6,
                  prefixIcon: Icons.verified_user_sharp,
                  controller: verifyOtpController.otpController.value,
                  fillColor: AppColors.textfieldColor,
                  borderRadius: 10,
                  hintText: '                0 0 0    0 0 0',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please Enter the OTP';
                    }
                    if (!RegExp(r'^\d{4,6}$').hasMatch(value.trim())) {
                      return 'Please Enter a Valid OTP (4-6 digits)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.05),
                Obx(
                  () => RoundButton(
                      width: screenWidth * 0.9,
                      buttonColor: AppColors.blackColor,
                      title: 'verify_otp'.tr,
                      loading: verifyOtpController.isLoading.value,
                      onPress: () async {
                        final otp =
                            verifyOtpController.otpController.value.text.trim();
                        log('OTP entered: $otp');
                        log('Email from arguments: $email');

                        if (otp.isNotEmpty) {
                          final success = await verifyOtpController
                              .verifyOtp(otp, email: email);

                          if (success) {
                            await Future.delayed(Duration(milliseconds: 300));
                            Get.toNamed(
                              RouteName.createNewPassword,
                              arguments: {
                                'email': email ?? '',
                                'otp': otp,
                              },
                            );
                          }
                        } else {
                          Utils.snackBar('Please enter valid OTP', 'Info');
                        }
                      }),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: AppFonts.opensansRegular,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
                SizedBox(height: screenHeight * 0.3),
                StepIndicator(currentStep: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
