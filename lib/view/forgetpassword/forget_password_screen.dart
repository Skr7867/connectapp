import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../res/component/round_button.dart';
import '../../res/custom_widgets/custome_textfield.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/forgetpassword/otp_response_controller.dart';
import 'step_indicator.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final otpResponseController = Get.put(OtpResponseController());
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.06),
                  Center(
                    child: Image.asset(
                      ImageAssets.lockIcon,
                      height: 200,
                      width: 200,
                    ),
                  ),
                  Text(
                    'Reset Password',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Enter your email to receive a verification code ',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                        fontFamily: AppFonts.opensansRegular),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  CustomTextField(
                    prefixIcon: Icons.email,
                    controller: otpResponseController.emailController.value,
                    borderRadius: 10,
                    fillColor: AppColors.textfieldColor,
                    hintText: 'enter_email'.tr,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please Enter Your Email Address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Please Enter a Valid Email Address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Obx(
                    () => RoundButton(
                      buttonColor: AppColors.blackColor,
                      width: screenWidth * 0.95,
                      height: screenHeight * 0.06,
                      title: 'continue'.tr,
                      loading: otpResponseController.isLoading.value,
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          final email = otpResponseController
                              .emailController.value.text
                              .trim();
                          if (email.isNotEmpty) {
                            otpResponseController
                                .sendOtp(email)
                                .then((success) {
                              if (success) {
                                Get.toNamed(RouteName.otpVerification,
                                    arguments: {'email': email});
                              }
                            });
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please Enter a Valid Email Address',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.3),
                  StepIndicator(currentStep: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
