import 'dart:developer';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../view_models/controller/2FA/two_fa_controller.dart';
import '../../view_models/controller/language/language_controller.dart';
import '../../view_models/controller/signup/signup_controller.dart';
import '../../view_models/controller/themeController/theme_controller.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';
import 'log_out_dialog_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _chatNotifications = true;
  bool _courseUpdates = true;
  String appVersion = "";
  final TwoFAController twoFAController = Get.put(TwoFAController());
  final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
  String token = '';

  @override
  void initState() {
    super.initState();
    _initialize();
    loadAppVersion();
  }

  Future<void> _initialize() async {
    final user = await userPreferences.getUser();
    if (user != null) {
      setState(() {
        token = user.token;
      });
      await twoFAController.is2FAEnabled(token);
    } else {
      log('No valid user token found');
      Get.snackbar(
        'Info',
        'Session expired. Please log in again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        isDismissible: true,
      );
    }
  }

  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "${info.version}+${info.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'setting'.tr,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle(Icons.settings, "general".tr),
                SizedBox(height: screenHeight * 0.01),
                generalSettings(),
                SizedBox(height: 20),
                sectionTitle(Icons.wallet, "membership".tr),
                SizedBox(height: screenHeight * 0.01),
                membershipTile(),
                const SizedBox(height: 20),
                // sectionTitle(Icons.notifications_rounded, "notification".tr),
                // SizedBox(height: screenHeight * 0.01),
                // notificationSettings(),
                sectionTitle(
                    PhosphorIconsFill.shieldCheck, 'privacy_security'.tr),
                SizedBox(height: screenHeight * 0.01),
                privacySecuritySettings(),
                const SizedBox(height: 20),
                sectionTitle(PhosphorIconsFill.lifebuoy, 'help_support'.tr),
                SizedBox(height: screenHeight * 0.01),
                helpSupportSection(),
                const SizedBox(height: 20),
                sectionTitle(Icons.info_outline, 'about_us'.tr),
                SizedBox(height: screenHeight * 0.01),
                aboutUsSection(),
                const SizedBox(height: 20),
                sectionTitle(Icons.redeem_outlined, 'Refferal'),
                const SizedBox(height: 10),
                refferalSection(),
                const SizedBox(height: 24),
                logoutButton(),
                const SizedBox(height: 54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ],
    );
  }

  Widget generalSettings() {
    final ThemeController themeController = Get.find<ThemeController>();
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyColor.withOpacity(0.4))),
      child: Column(
        children: [
          _buildSettingTile(
            icon: PhosphorIconsRegular.translate,
            title: 'language'.tr,
            value: Get.find<LanguageController>().currentLanguage,
            onTap: () {
              Get.toNamed(RouteName.languageScreen);
            },
            showDivider: true,
          ),
          _buildSettingTile(
            icon: PhosphorIconsRegular.palette,
            title: 'appearences'.tr,
            value: themeController.isDarkMode.value
                ? 'dark_mode'.tr
                : 'light_mode'.tr,
            onTap: () {
              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'select_theme'.tr,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(
                          PhosphorIconsRegular.moon,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        title: Text(
                          'dark_mode'.tr,
                          style: TextStyle(
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                        onTap: () {
                          if (!themeController.isDarkMode.value) {
                            themeController.switchTheme();
                          }
                          Get.back();
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          PhosphorIconsRegular.sun,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        title: Text(
                          'light_mode'.tr,
                          style: TextStyle(
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                        onTap: () {
                          if (themeController.isDarkMode.value) {
                            themeController.switchTheme();
                          }
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
                isScrollControlled: true,
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // Widget notificationSettings() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Column(
  //       children: [
  //         // _buildNotificationSwitchTile(
  //         //   icon: PhosphorIconsRegular.bellSimple,
  //         //   title: 'push_notification'.tr,
  //         //   value: _pushNotifications,
  //         //   onChanged: (val) => setState(() => _pushNotifications = val),
  //         // ),
  //         // _buildDivider(),
  //         _buildNotificationSwitchTile(
  //           icon: PhosphorIconsRegular.envelope,
  //           title: 'email_notification'.tr,
  //           value: _emailNotifications,
  //           onChanged: (val) => setState(() => _emailNotifications = val),
  //         ),
  //         _buildDivider(),
  //         _buildNotificationSwitchTile(
  //           icon: PhosphorIconsRegular.chatCircle,
  //           title: 'chat_notification'.tr,
  //           value: _chatNotifications,
  //           onChanged: (val) => setState(() => _chatNotifications = val),
  //         ),
  //         _buildDivider(),
  //         _buildNotificationSwitchTile(
  //           icon: PhosphorIconsRegular.bookOpen,
  //           title: 'course_update'.tr,
  //           value: _courseUpdates,
  //           onChanged: (val) => setState(() => _courseUpdates = val),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget privacySecuritySettings() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
      ),
      child: Obx(() => _build2FaNavigationtile(
            icon: PhosphorIconsRegular.password,
            title: twoFAController.isSetupComplete.value
                ? '2fa_disable'.tr
                : '2fa_enable'.tr,
            onTap: () {
              if (token.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Session expired. Please log in again.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  isDismissible: true,
                );
                Get.offNamed(RouteName.loginScreen);
                return;
              }
              if (twoFAController.isSetupComplete.value) {
                Get.toNamed(RouteName.disableTwoFa);
              } else {
                Get.toNamed(RouteName.twoFactorSetupScreen);
              }
            },
          )),
    );
  }

  Widget membershipTile() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.card_membership,
            title: 'membership'.tr,
            onTap: () {
              Get.toNamed(RouteName.membershipPlan);
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: PhosphorIconsRegular.coins,
            title: 'coins'.tr,
            onTap: () {
              Get.toNamed(RouteName.buyCoinsScreen);
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: PhosphorIconsRegular.wallet,
            title: 'wallet'.tr,
            onTap: () {
              Get.toNamed(RouteName.walletScreen);
            },
          ),
        ],
      ),
    );
  }

  Widget helpSupportSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: PhosphorIconsRegular.article,
            title: 'privacy_policy'.tr,
            onTap: () {
              Get.toNamed(RouteName.privacyPolicy);
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: PhosphorIconsRegular.fileText,
            title: 'terms_of_service'.tr,
            onTap: () {
              Get.toNamed(RouteName.termsAndCondition);
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: PhosphorIconsRegular.chatTeardrop,
            title: 'contact_us'.tr,
            onTap: () {
              Get.toNamed(RouteName.contactUsScreen);
            },
          ),
          // _buildDivider(),
          // _buildNavigationTile(
          //   icon: PhosphorIconsRegular.warning,
          //   title: 'report_an_issue'.tr,
          //   onTap: () {
          //     Get.toNamed(RouteName.reportAndIssue);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget aboutUsSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildSettingTile(
        icon: PhosphorIconsRegular.info,
        title: 'App Version',
        value: appVersion.isNotEmpty ? appVersion : "Loading...",
        onTap: () {},
        showDivider: false,
      ),
    );
  }

  Widget refferalSection() {
    final signupController = Get.put(SignupController());
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildSettingTile(
        icon: PhosphorIconsRegular.info,
        title: 'refer'.tr,
        value: '',
        onTap: () {
          signupController.shareReferralLink();
        },
        showDivider: false,
      ),
    );
  }

  Widget logoutButton() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: RoundButton(
        buttonColor: AppColors.redColor,
        width: screenWidth * 0.96,
        title: "logout".tr,
        onPress: () {
          showLogoutDialog(context);
        },
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.blueColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                        fontFamily: AppFonts.opensansRegular),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: AppFonts.opensansRegular),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (showDivider) _buildDivider(),
      ],
    );
  }

  Widget _buildNotificationSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.blueColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.greenColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.blueColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontFamily: AppFonts.opensansRegular),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _build2FaNavigationtile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.blueColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontFamily: AppFonts.opensansRegular),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.greyColor.withOpacity(0.4),
      indent: 16,
      endIndent: 16,
      thickness: 0.6,
    );
  }
}
