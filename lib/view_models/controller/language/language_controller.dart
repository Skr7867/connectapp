import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var selectedIndex = RxInt(-1); // -1 means no selection initially
  var currentLocale =
      Rx<Locale>(const Locale('en', 'US')); // Make locale reactive
  var titleText = <String>[].obs;
  var securityTitle = <String>[].obs;
  var securitySubTitle = <String>[].obs;
  var helpCenterTitle = <String>[].obs;

  // Issue-related variables and methods
  var selectedIssue = RxnString();
  List<String> issues = [
    "issue1".tr,
    "issue2".tr,
    "issue3".tr,
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  // Language selection method
  void selectLanguage(int index) async {
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;

    Locale newLocale;
    if (index == 0) {
      newLocale = const Locale('en', 'US');
    } else if (index == 1) {
      newLocale = const Locale('hi', 'IN');
    } else {
      newLocale = const Locale('ur', 'PK');
    }

    // Update the reactive locale
    currentLocale.value = newLocale;
    Get.updateLocale(newLocale);

    // Save the selected language
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    await prefs.setString('country_code', newLocale.countryCode ?? '');

    // Update UI text
    _updateTitleText();
    _updateSecurityText();
    _updateHelpCenterText();
  }

  // Load saved language settings from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    String? countryCode = prefs.getString('country_code');

    if (languageCode != null && countryCode != null) {
      Locale savedLocale = Locale(languageCode, countryCode);
      currentLocale.value = savedLocale;
      Get.updateLocale(savedLocale);
      selectedIndex.value = _getIndexFromLocale(savedLocale);
    }

    _updateTitleText();
    _updateSecurityText();
    _updateHelpCenterText();
  }

  // Update titles for UI
  void _updateTitleText() {
    titleText.assignAll([
      'edit_profile'.tr,
      'notification'.tr,
      'payment'.tr,
      'security'.tr,
      'language'.tr,
      'help_center'.tr,
      'logout'.tr,
    ]);
  }

  // Update security-related texts
  void _updateSecurityText() {
    securityTitle.assignAll([
      "overview".tr,
      "encryption".tr,
      "data_protection".tr,
      "secure_payment".tr,
      "privacy_policy".tr,
      "Security_Updates".tr,
    ]);

    securitySubTitle.assignAll([
      "overview_subtitle".tr,
      "encryption_subtitle".tr,
      "protection_subtitle".tr,
      "secure_payment_subtitle".tr,
      "privacy_subtitle".tr,
      "security_subtitle".tr,
    ]);
  }

  // Update Help Center texts
  void _updateHelpCenterText() {
    helpCenterTitle.assignAll([
      "how to Guides".tr,
      "Contact Information".tr,
      "Feedback Form".tr,
      "Terms of Service and Privacy Policy".tr,
      "Security Information".tr,
      "App Updates".tr,
      "Community Forums or Support Groups".tr,
      "Accessibility Information".tr,
    ]);
  }

  // Set selected issue
  void setSelectedIssue(String? issue) {
    selectedIssue.value = issue;
  }

  // Get index based on locale
  int _getIndexFromLocale(Locale locale) {
    if (locale.languageCode == 'en' && locale.countryCode == 'US') {
      return 0;
    } else if (locale.languageCode == 'hi' && locale.countryCode == 'IN') {
      return 1;
    } else {
      return -1;
    }
  }

  // Get the current language name for display
  String get currentLanguage {
    switch (selectedIndex.value) {
      case 0:
        return 'english'.tr;
      case 1:
        return 'hindi'.tr;
      case 2:
        return 'urdu'.tr;
      default:
        return 'english'.tr;
    }
  }
}
