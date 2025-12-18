import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/UserLogin/user_login_model.dart';
import '../../../res/custom_widgets/custome_textfield.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/2FA/two_fa_controller.dart';

class AuthenticatorVerificationScreen extends StatefulWidget {
  const AuthenticatorVerificationScreen({super.key});

  @override
  State<AuthenticatorVerificationScreen> createState() =>
      _AuthenticatorVerificationScreenState();
}

class _AuthenticatorVerificationScreenState
    extends State<AuthenticatorVerificationScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final TwoFAController twoFAController = Get.find<TwoFAController>();
  final userPrefs = UserPreferencesViewmodel();

  @override
  void initState() {
    super.initState();
    final String method = Get.arguments != null
        ? Get.arguments['method'] ?? 'authenticator'
        : 'authenticator';
    if (method == 'email' || method == 'sms') {
      userPrefs.getUser().then((user) {
        if (user?.token != null) {
          twoFAController.sendOtp(user!.token, method);
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void onCodeEntered(String value) {
    if (value.length == 6) {
      focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String method = Get.arguments != null
        ? Get.arguments['method'] ?? 'authenticator'
        : 'authenticator';

    return FutureBuilder<LoginResponseModel?>(
      future: userPrefs.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C0F1F),
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2A63FF))),
          );
        }

        final String? token = snapshot.data?.token;

        if (token == null || token.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFF0C0F1F),
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF11152A),
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

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(left: 24, right: 24, top: 250),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$method verification'.capitalizeFirst!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter 6 digit Code $method',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'verification_code'.tr,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) => onCodeEntered(value),
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.lock,
                        hintText: 'enter_6_digit'.tr,
                        maxLength: 6,
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: twoFAController.isLoading.value
                              ? null
                              : () async {
                                  String code = controller.text.trim();
                                  if (code.length != 6 ||
                                      !RegExp(r'^\d{6}$').hasMatch(code)) {
                                    Get.snackbar('Error',
                                        'Please enter a valid 6-digit code',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.red);
                                    return;
                                  }
                                  await twoFAController.verifyOtp(
                                      token, code, method);
                                  // Check 2FA status after verification
                                  // bool is2FAEnabled =
                                  //     await twoFAController.is2FAEnabled(token);
                                  // if (is2FAEnabled) {
                                  //   Get.snackbar('Info',
                                  //       '2FA is enabled for your account',
                                  //       snackPosition: SnackPosition.TOP,
                                  //       backgroundColor: Colors.blue);
                                  // }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blackColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: twoFAController.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text('verify'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppFonts.opensansRegular)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Get.toNamed(RouteName.recoveryCode);
                        },
                        child: Text(
                          "cant_access".tr,
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: AppFonts.opensansRegular),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (twoFAController.isSetupComplete.value)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 40),
                            const SizedBox(height: 8),
                            const Text(
                              'Two-Factor Authentication Enabled',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Get.offNamed(RouteName.profileScreen);
                              },
                              child: const Text(
                                'Return to Profile',
                                style: TextStyle(color: Color(0xFF2A63FF)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
