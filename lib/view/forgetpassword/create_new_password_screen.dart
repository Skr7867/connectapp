import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/assets/image_assets.dart';
import '../../res/color/app_colors.dart';
import '../../res/component/round_button.dart';
import '../../res/custom_widgets/custome_textfield.dart';
import '../../res/custom_widgets/responsive_padding.dart';
import '../../res/fonts/app_fonts.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/forgetpassword/reset_password_controller.dart';
import 'step_indicator.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  CreateNewPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final resetPasswordController = Get.put(ResetPasswordController());
    final Map<String, String>? args = Get.arguments as Map<String, String>?;
    final String? email = args?['email'];
    final String? otp = args?['otp'];
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
                  SizedBox(height: screenHeight * 0.07),
                  Center(
                    child: Image.asset(
                      ImageAssets.lockIcon,
                      height: 200,
                      width: 200,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'create_new_password'.tr,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'set_up_password'.tr,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  CustomTextField(
                    prefixIcon: Icons.lock,
                    controller:
                        resetPasswordController.passwordController.value,
                    fillColor: AppColors.textfieldColor,
                    isPassword: true,
                    borderRadius: 10,
                    hintText: 'enter_new_password'.tr,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    prefixIcon: Icons.lock,
                    controller:
                        resetPasswordController.confirmPasswordController.value,
                    fillColor: AppColors.textfieldColor,
                    isPassword: true,
                    borderRadius: 10,
                    hintText: 'Enter your confirm Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value !=
                          resetPasswordController
                              .passwordController.value.text) {
                        return 'Passwords do not match'; // ✅ Correct comparison
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Obx(
                    () => RoundButton(
                      width: screenWidth * 0.9,
                      buttonColor: AppColors.blackColor,
                      title: 'Reset Password',
                      loading: resetPasswordController.isLoading.value,
                      onPress: () {
                        // Validate both fields first
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        final password = resetPasswordController
                            .passwordController.value.text
                            .trim();

                        if (email == null || otp == null) {
                          Get.snackbar(
                            'Error',
                            'Email or OTP missing',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                          );
                          return;
                        }

                        resetPasswordController
                            .resetPassword(email, otp, password)
                            .then((success) {
                          if (success) {
                            Get.offAllNamed(RouteName.loginScreen);
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.15),
                  StepIndicator(currentStep: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
