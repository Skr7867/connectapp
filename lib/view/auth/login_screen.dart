import 'dart:developer';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/constant/myconst.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/UserLogin/user_login_model.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _loginVm = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  GoogleSignIn signIn = GoogleSignIn(scopes: [
    'email',
    'profile',
  ], serverClientId: Myconst.googleWebClientId);

  void googleSignIn() async {
    try {
      await signIn.signOut();
      final account = await signIn.signIn();
      if (account == null) {
        log("Google Sign-In cancelled by user.");
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      log("Google ID Token: $idToken");

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
      log("2️⃣ Verify response: $response");
      if (response != null && response['success'] == true) {
        final loginResponse = LoginResponseModel.fromJson({
          'message': response['message'] ?? 'Login successful',
          'token': response['token'],
          'user': response['user'],
        });

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
      log("Google Sign-In error: $e");
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 6),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Center(
                    child: Image.asset(
                      ImageAssets.signupImg,
                      height: 140,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.helveticaMedium,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Row(children: [
                    Text(
                      textAlign: TextAlign.center,
                      'Do not have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                        color: AppColors.greyColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.toNamed(RouteName.signupScreen);
                      },
                      child: Text(
                        textAlign: TextAlign.center,
                        ' Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.helveticaBold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 30),
                  CustomTextField(
                    prefixIcon: Icons.email,
                    controller: _loginVm.emailController.value,
                    borderRadius: 17,
                    fillColor: AppColors.textfieldColor,
                    hintText: 'someone@gmail.com',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_enter_email'.tr;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    prefixIcon: Icons.lock,
                    controller: _loginVm.passwordController.value,
                    borderRadius: 17,
                    fillColor: AppColors.textfieldColor,
                    hintText: 'enter_password'.tr,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_enter_password';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: ResponsivePadding.customPadding(context,
                        top: 0,
                        left: orientation == Orientation.portrait ? 53 : 66),
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(RouteName.forgetPassword);
                      },
                      child: Text(
                        'forget_password'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.helveticaBold,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Obx(
                    () => RoundButton(
                      loading: _loginVm.isLoading.value,
                      buttonColor: AppColors.blackColor,
                      width: screenWidth * 0.95,
                      height: 41,
                      title: 'login_now'.tr,
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          _loginVm.loginUser();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: Text(
                      '━━━━━━ Or continue with ━━━━━━',
                      style: TextStyle(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Obx(() {
                    final isGoogleLoading = _loginVm.isGoogleLoading.value;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: isGoogleLoading
                              ? null
                              : () async {
                                  _loginVm.isGoogleLoading.value = true;

                                  try {
                                    googleSignIn();
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'Something went wrong during Google Sign-In.',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                    );
                                  } finally {
                                    // Delay a bit to make UI smoother
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    _loginVm.isGoogleLoading.value = false;
                                  }
                                },
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: isGoogleLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.blue,
                                    ),
                                  )
                                : Image.asset(ImageAssets.google),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
