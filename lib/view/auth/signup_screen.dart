import 'dart:developer';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/constant/myconst.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/signup/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/UserLogin/user_login_model.dart';
import '../../res/assets/image_assets.dart';
import '../../res/custom_widgets/custome_textfield.dart';
import '../../utils/utils.dart';
import '../../view_models/controller/login/login_controller.dart';
import '../../view_models/controller/userName/user_name_controller.dart';

// ignore: must_be_immutable
class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});
  final _signupVm = Get.put(SignupController());
  final _userName = Get.put(UserNameController());
  final _loginVm = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();
  final RxBool isTermsAccepted = false.obs;

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
    // Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 6),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.06),
                    Center(
                      child: Image.asset(
                        ImageAssets.signinImg,
                        height: 140,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    Text(
                      'create_account'.tr,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.helveticaBold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular,
                              color: AppColors.greyColor),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(RouteName.loginScreen);
                          },
                          child: Text(
                            '  Sign in',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.helveticaBold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Column(
                      children: [
                        CustomTextField(
                          prefixIcon: Icons.person,
                          controller: _signupVm.nameController.value,
                          borderRadius: 17,
                          fillColor: AppColors.textfieldColor,
                          hintText: 'enter_name'.tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          prefixIcon: Icons.email,
                          controller: _signupVm.emailController.value,
                          borderRadius: 17,
                          fillColor: AppColors.textfieldColor,
                          hintText: 'enter_email'.tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter_email'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          prefixIcon: Icons.alternate_email,
                          controller: TextEditingController()
                            ..text = _userName.username.value,
                          onChanged: _userName.updateUsername,
                          borderRadius: 17,
                          fillColor: AppColors.textfieldColor,
                          hintText: 'enter_username'.tr,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[a-zA-Z0-9_]*$')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter_username'.tr;
                            }
                            if (_userName.isUsernameAvailable.value == false) {
                              return 'username_taken'.tr;
                            }
                            if (value.length < 3) {
                              return 'username_too_short'.tr;
                            }
                            return null;
                          },
                          suffixIcon: Obx(() {
                            if (_userName.isCheckingUsername.value) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            final isAvailable =
                                _userName.isUsernameAvailable.value;
                            if (isAvailable == null) {
                              return const SizedBox.shrink();
                            }

                            return Icon(
                              isAvailable ? Icons.check_circle : Icons.cancel,
                              color: isAvailable ? Colors.green : Colors.red,
                            );
                          }),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Obx(
                          () => Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  activeColor: AppColors.textColor,
                                  value: isTermsAccepted.value,
                                  onChanged: (value) {
                                    isTermsAccepted.value = value ?? false;
                                  },
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: "I  accept  and agree  to all the ",
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: AppFonts.opensansRegular,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Terms  and \nConditions.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                              fontFamily:
                                                  AppFonts.opensansRegular),
                                        ),
                                      ]),
                                ),
                              ]),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Obx(
                          () => RoundButton(
                            loading: _signupVm.isLoading.value,
                            buttonColor: AppColors.blackColor,
                            width: screenWidth * 0.9,
                            height: 41,
                            textColor: AppColors.whiteColor,
                            title: 'create'.tr,
                            onPress: () {
                              if (_formKey.currentState!.validate()) {
                                if (!isTermsAccepted.value) {
                                  Utils.snackBar(
                                      'You must accept Terms & Conditions to continue',
                                      'Info');
                                  return;
                                }

                                _signupVm.tempName.value =
                                    _signupVm.nameController.value.text.trim();
                                _signupVm.tempEmail.value =
                                    _signupVm.emailController.value.text.trim();
                                _signupVm.tempUsername.value =
                                    _userName.username.value.trim();

                                Get.toNamed(RouteName.setPasswordScreen);
                              }
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          '━━━━━━ Or continue with ━━━━━━',
                          style: TextStyle(
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                        SizedBox(height: screenHeight * 0.03),
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
                            // const SizedBox(width: 12),
                            // CircleAvatar(
                            //     backgroundColor: Theme.of(context)
                            //         .textTheme
                            //         .bodyLarge
                            //         ?.color,
                            //     radius: 22,
                            //     child: Image.asset(ImageAssets.xIcon)),
                          ],
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
