import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/CREATORPANEL/SelectLanguage/selectLanguageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/CREATORPANEL/CreateCourse/create_course_controller.dart';

class LanguageDropdown extends StatelessWidget {
  final CreateCourseController courseController;
  const LanguageDropdown({super.key, required this.courseController});

  @override
  Widget build(BuildContext context) {
    final selectLangController = Get.put(Selectlanguagecontroller());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.greyColor.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Obx(() {
            return DropdownButton<String>(
              value: selectLangController.selectedLanguage.value,
              isExpanded: true,
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              iconEnabledColor: AppColors.greyColor,
              underline: Container(),
              style: TextStyle(
                color: AppColors.textColor,
                fontFamily: AppFonts.opensansRegular,
              ),
              items: selectLangController.languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectLangController.setSelectedLanguage(value);
                  courseController.languageController.text = value;
                }
              },
            );
          }),
        ),
      ],
    );
  }
}
