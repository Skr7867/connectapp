import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/CREATORPANEL/EditCourse/edit_course_controller.dart';
import 'package:connectapp/view_models/CREATORPANEL/SelectLanguage/selectLanguageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditLanguageDropdown extends StatelessWidget {
  final EditCourseController editCourseController;
  const EditLanguageDropdown({super.key, required this.editCourseController});

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
              dropdownColor: Theme.of(context).textTheme.bodyLarge?.color,
              iconEnabledColor: AppColors.whiteColor,
              underline: Container(),
              style: TextStyle(
                  color: AppColors.greyColor,
                  fontFamily: AppFonts.opensansRegular,
                  fontWeight: FontWeight.bold),
              items: selectLangController.languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectLangController.setSelectedLanguage(value);
                  editCourseController.selectedLanguage;
                }
              },
            );
          }),
        ),
      ],
    );
  }
}
