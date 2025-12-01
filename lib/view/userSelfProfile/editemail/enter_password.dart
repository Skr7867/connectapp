import 'dart:developer';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/controller/editprofilecontroller/editemail/enter_current_password_controller.dart';
import '../../../view_models/controller/editprofilecontroller/editemail/validate_new_email_controller.dart';
import '../../../view_models/controller/editprofilecontroller/editemail/verify_email_password_controller.dart';

class EnterPassword extends StatelessWidget {
  const EnterPassword({super.key});

  // Email validation regex
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // OTP validation (assuming 6-digit OTP)
  bool isValidOtp(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final EnterCurrentPasswordController passwordController =
        Get.put(EnterCurrentPasswordController());
    final ValidateEmailController emailController =
        Get.put(ValidateEmailController());
    final VerifyOtpEmailController otpController =
        Get.put(VerifyOtpEmailController());

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Update Email',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Padding(
            padding: ResponsivePadding.symmetricPadding(context, horizontal: 3),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: ResponsivePadding.symmetricPadding(context,
                      horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      Center(
                        child: Text(
                          'Update Email Address',
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Verify your identity to change your email',
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      // Current Password Field
                      Text(
                        'Current Password',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      Obx(() => SizedBox(
                            height: 50,
                            child: TextFormField(
                              cursorColor:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              cursorHeight: 18,
                              controller: passwordController
                                  .currentPasswordController.value,
                              decoration: InputDecoration(
                                hintText: 'Enter Your Current Password',
                                hintStyle: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: AppColors.greyColor),
                                ),
                                suffixIcon: passwordController.isLoading.value
                                    ? Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          final password = passwordController
                                              .currentPasswordController
                                              .value
                                              .text;
                                          if (password.isEmpty) {
                                            // passwordController.errorMessage.value =
                                            //     'Password cannot be empty';
                                            Get.snackbar('Error',
                                                'Password cannot be empty',
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                                snackPosition:
                                                    SnackPosition.TOP);
                                            return;
                                          }
                                          passwordController
                                              .verifyCurrentPassword(password);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 14),
                                          child: Text(
                                            'Verify',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: passwordController
                                                      .isPasswordVerified.value
                                                  ? Colors.green
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontFamily: AppFonts.opensansRegular),
                              obscureText: true,
                              keyboardType: TextInputType.text,
                            ),
                          )),
                      Obx(() => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              passwordController.errorMessage.value,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontFamily: AppFonts.opensansRegular),
                            ),
                          )),
                      SizedBox(height: 10),
                      // New Email Field
                      Text(
                        'New Email Address',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      Obx(() => SizedBox(
                            height: 50,
                            child: TextFormField(
                              cursorColor:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              cursorHeight: 18,
                              controller:
                                  emailController.newEmailController.value,
                              decoration: InputDecoration(
                                hintText: 'Enter Your New Email Address',
                                hintStyle: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: AppColors.greyColor),
                                ),
                                suffixIcon: emailController.isLoading.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          final email = emailController
                                              .newEmailController.value.text;
                                          if (!isValidEmail(email)) {
                                            // emailController.errorMessage.value =
                                            //     'Invalid email formasdfghjk,t';
                                            Get.snackbar(
                                                'Error', 'Invalid email format',
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                                snackPosition:
                                                    SnackPosition.TOP);
                                            return;
                                          }
                                          emailController
                                              .validateNewEmail(email);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 14),
                                          child: Text(
                                            'Verify',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: emailController
                                                      .isEmailValidated.value
                                                  ? Colors.green
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontFamily: AppFonts.opensansRegular),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          )),
                      Obx(() => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              emailController.errorMessage.value,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          )),
                      SizedBox(height: 10),
                      // OTP Field
                      Padding(
                        padding:
                            ResponsivePadding.customPadding(context, right: 55),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enter OTP',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: emailController.isEmailValidated.value
                            //       ? () {
                            //           final email = emailController
                            //               .newEmailController.value.text;
                            //           if (isValidEmail(email)) {
                            //             emailController.validateNewEmail(
                            //                 email); // Assuming this resends OTP
                            //             Get.snackbar('OTP Resent',
                            //                 'A new OTP has been sent to $email',
                            //                 backgroundColor: Colors.green,
                            //                 colorText: Colors.white,
                            //                 snackPosition: SnackPosition.TOP);
                            //           }
                            //         }
                            //       : null,
                            //   child: Text(
                            //     'Resend OTP',
                            //     style: TextStyle(
                            //       fontSize: 10,
                            //       fontFamily: AppFonts.opensansRegular,
                            //       color: emailController.isEmailValidated.value
                            //           ? AppColors.buttonColor
                            //           : Colors.grey,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Obx(() => SizedBox(
                            height: 50,
                            child: TextFormField(
                              cursorColor: AppColors.blackColor,
                              cursorHeight: 18,
                              controller: otpController.otpController.value,
                              // enabled: emailController.isEmailValidated.value,
                              decoration: InputDecoration(
                                hintText: 'Enter OTP sent to your mail',
                                hintStyle: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: AppColors.greyColor),
                                ),
                                suffixIcon: otpController.isLoading.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          final otp = otpController
                                              .otpController.value.text;
                                          if (!isValidOtp(otp)) {
                                            Get.snackbar('Error',
                                                'OTP must be a 6-digit number',
                                                backgroundColor: Colors.red,
                                                colorText: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                                snackPosition:
                                                    SnackPosition.TOP);
                                            return;
                                          }
                                          log('OTP Verify button tapped with OTP: $otp');
                                          otpController.verifyOtpEmail(
                                            otp,
                                            emailController
                                                .newEmailController.value.text,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 14),
                                          child: Text(
                                            'Verify',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: otpController
                                                      .isOtpVerified.value
                                                  ? Colors.green
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontFamily: AppFonts.opensansRegular),
                              keyboardType: TextInputType.number,
                            ),
                          )),
                      Obx(() => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              otpController.errorMessage.value,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          )),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blackColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          onPressed: () {
                            Get.snackbar(
                                'Success', 'Email updated successfully!',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP);
                            Get.back();
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
