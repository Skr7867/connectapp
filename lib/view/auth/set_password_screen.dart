import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/UserLogin/user_login_model.dart';
import '../../res/constant/myconst.dart';
import '../../view_models/controller/login/login_controller.dart';
import '../../view_models/controller/signup/signup_controller.dart';

// ignore: must_be_immutable
class SetPasswordScreen extends StatelessWidget {
  SetPasswordScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  final _signupVm = Get.find<SignupController>();
  final _loginVm = Get.find<LoginController>();
  GoogleSignIn signIn = GoogleSignIn(scopes: [
    'email',
    'profile',
  ], serverClientId: Myconst.clientId);

  void googleSignIn() async {
    try {
      await signIn.signOut();
      final account = await signIn.signIn();
      if (account == null) {
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        Get.snackbar(
          "Error",
          "Failed to retrieve Google ID Token.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await _loginVm.verifyGoogleToken(idToken);

      if (response != null && response['success'] == true) {
        // Convert to LoginResponseModel
        final loginResponse = LoginResponseModel.fromJson({
          'message': response['message'] ?? 'Login successful',
          'token': response['token'],
          'user': response['user'],
        });

        // Handle full login logic
        await _loginVm.handleSuccessfulLogin(loginResponse);
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Google login failed on server.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Google Sign-In failed. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsivePadding.symmetricPadding(context, horizontal: 6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      ImageAssets.lockIcon,
                      height: 200,
                      width: 200,
                    ),
                  ),
                  Text(
                    'Set Password',
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaBold,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Create a secure password for your account',
                    style: TextStyle(
                        fontFamily: AppFonts.helveticaBold,
                        fontSize: 14,
                        color: AppColors.greyColor),
                  ),
                  SizedBox(height: 40),
                  CustomTextField(
                    controller: _signupVm.passwordController.value,
                    isPassword: true,
                    borderRadius: 17,
                    prefixIcon: Icons.lock,
                    hintText: 'Create Password',
                    fillColor: AppColors.textfieldColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!RegExp(r'^(?=.*[!@#\$&*~])').hasMatch(value)) {
                        return 'Password must contain at least 1 special character';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _signupVm.confirmPasswordController.value,
                    isPassword: true,
                    borderRadius: 17,
                    prefixIcon: Icons.lock,
                    hintText: 'Confirm Password',
                    fillColor: AppColors.textfieldColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != _signupVm.passwordController.value.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your password should contain minimum eight alphanumerical charecters and at least one special charecter',
                    style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: 14,
                        color: AppColors.greyColor),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Obx(
                      () => RoundButton(
                        loading: _signupVm.isLoading.value,
                        width: screenWidth * 0.9,
                        buttonColor: AppColors.blackColor,
                        title: 'create_account'.tr,
                        onPress: () {
                          if (_formKey.currentState!.validate()) {
                            // Collect everything
                            final signupData = {
                              "name": _signupVm.tempName.value,
                              "email": _signupVm.tempEmail.value,
                              "username": _signupVm.tempUsername.value,
                              "password": _signupVm
                                  .passwordController.value.text
                                  .trim(),
                            };

                            _signupVm.registerUser(signupData);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      '━━━━━━ Or continue with ━━━━━━',
                      style: TextStyle(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          googleSignIn();
                        },
                        child: CircleAvatar(
                          radius: 22,
                          child: Image.asset(
                            ImageAssets.google,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                          backgroundColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          radius: 22,
                          child: Image.asset(ImageAssets.xIcon)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
