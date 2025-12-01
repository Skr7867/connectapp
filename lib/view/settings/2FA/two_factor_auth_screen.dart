import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/UserLogin/user_login_model.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/2FA/two_fa_controller.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final TwoFAController controller = Get.put(TwoFAController());
  final userPrefs = UserPreferencesViewmodel();
  String? selectedMethod;
  String step = 'intro';

  @override
  Widget build(BuildContext context) {
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
        final String? userEmail = snapshot.data?.user.email;

        if (token == null || token.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.textfieldColor,
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.textfieldColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error',
                      style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Authentication token is missing. Please log in again.',
                      style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
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
          appBar: CustomAppBar(
            title: 'Account Security',
            automaticallyImplyLeading: true,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'two_factor_authentication'.tr,
                        style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'enhance_security'.tr,
                        style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      renderStepContent(token, userEmail ?? 'user@example.com'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Get.offNamed(RouteName.settingScreen),
                        child: Text(
                          'cancel_setup'.tr,
                          style: TextStyle(
                              color: AppColors.redColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular),
                        ),
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

  void updateStep(String newStep) {
    setState(() {
      step = newStep;
    });
  }

  void handleStartSetup(String token) async {
    if (selectedMethod == null) {
      Get.snackbar('Error', 'Please select a verification method',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red);
      return;
    }

    try {
      await controller.updateTwoFactorSettings(token, selectedMethod!);
      if (selectedMethod == 'authenticator') {
        updateStep('qrcode');
        await controller.fetchQrCode(token);
        Get.toNamed(RouteName.qrCodeScreen);
      } else if (selectedMethod == 'email') {
        updateStep('email-setup');
      } else if (selectedMethod == 'sms') {
        updateStep('verify');
        await controller.sendOtp(token, 'sms');
        Get.toNamed(RouteName.authenticatorVerification,
            arguments: {'method': 'sms', 'token': token});
      }
    } catch (e) {
      // Error snackbar is now handled in updateTwoFactorSettings
    }
  }

  Widget renderStepContent(String token, String userEmail) {
    switch (step) {
      case 'intro':
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.info, color: AppColors.redColor, size: 24),
                  SizedBox(height: 8),
                  Text(
                    'two_factor'.tr,
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'what_is_two_factor'.tr,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontFamily: AppFonts.opensansRegular),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blackColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => updateStep('method-selection'),
                child: Text('proceed_to_setup'.tr,
                    style: TextStyle(
                        fontSize: 16, fontFamily: AppFonts.opensansRegular)),
              ),
            ),
          ],
        );

      case 'method-selection':
        return Column(
          children: [
            Text(
              '2fa_selection'.tr,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'choose_2fa'.tr,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MethodBox(
                  icon: Icons.add,
                  title: 'Authenticator App',
                  subtitle: 'TOTP codes',
                  selected: selectedMethod == 'authenticator',
                  onTap: () {
                    setState(() {
                      selectedMethod = 'authenticator';
                    });
                  },
                ),
                MethodBox(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: 'Email codes',
                  selected: selectedMethod == 'email',
                  onTap: () {
                    setState(() {
                      selectedMethod = 'email';
                    });
                  },
                ),
                MethodBox(
                  icon: Icons.sms,
                  title: 'SMS',
                  subtitle: 'Text message',
                  selected: selectedMethod == 'sms',
                  onTap: () {
                    setState(() {
                      selectedMethod = 'sms';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blackColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () => handleStartSetup(token),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('continue'.tr,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.opensansRegular)),
              ),
            ),
          ],
        );

      case 'email-setup':
        return Column(
          children: [
            Text(
              'email_verification'.tr,
              style: TextStyle(
                color: Colors.white,
                fontFamily: AppFonts.opensansRegular,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'send_code'.tr,
              style: TextStyle(
                color: Colors.grey,
                fontFamily: AppFonts.opensansRegular,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email, color: Color(0xFF2A63FF)),
                      const SizedBox(width: 8),
                      Text(
                        userEmail,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A63FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: controller.isLoading.value || controller.otpSent.value
                  ? null
                  : () {
                      controller.sendOtp(token, 'email');
                      updateStep('verify');
                      Get.toNamed(RouteName.authenticatorVerification,
                          arguments: {'method': 'email', 'token': token});
                    },
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      controller.otpSent.value ? 'OTP Sent' : 'Send OTP',
                      style: const TextStyle(
                          fontSize: 12, fontFamily: AppFonts.opensansRegular),
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => updateStep('method-selection'),
                    child: Text(
                      'back'.tr,
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class MethodBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const MethodBox({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.blackColor : AppColors.blackColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? AppColors.blueColor : Colors.transparent,
                width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
