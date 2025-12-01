import 'package:get/get.dart';

class Selectlanguagecontroller extends GetxController {
  final List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
  ];

  final RxString selectedLanguage = 'English'.obs;

  void setSelectedLanguage(String value) {
    selectedLanguage.value = value;
  }
}
