import 'dart:developer';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view_models/CREATORPANEL/CreateCourseSection/create_course_section_controller.dart';
import '../../../view_models/CREATORPANEL/GetAllCreatorCourseSection/get_all_creator_course_section_controller.dart';

void showAddSectionDialog({
  required BuildContext context,
  required String courseId,
  required TextEditingController titleController,
  required CreateCourseSectionController createController,
  required GetAllCreatorCourseSectionController courseController,
  required double screenWidth,
  required double screenHeight,
  bool onSuccessNavigateBack =
      false, // Optional: navigate back to previous screen
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.textfieldColor,
      title: Text(
        'Add New Section',
        style: TextStyle(
          color: AppColors.whiteColor,
          fontFamily: AppFonts.opensansRegular,
        ),
      ),
      content: CustomTextField(
        fontSize: 10,
        controller: titleController,
        textColor: AppColors.whiteColor,
        fillColor: AppColors.loginContainerColor,
        hintText: 'Enter Title',
      ),
      actions: [
        TextButton(
          onPressed: () {
            log("Cancel button pressed");
            Get.back();
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: AppColors.redColor,
            ),
          ),
        ),
        Obx(() => ElevatedButton(
              onPressed: createController.isCreating.value
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      log("Attempting to create section with title: $title");
                      final success = await createController
                          .createCourseSection(courseId, title);
                      log("Create Section Success: $success");
                      titleController.clear();
                      log("Closing dialog");
                      Get.back(); // Close dialog
                      if (success) {
                        courseController.refreshApi(); // Refresh sections
                        if (onSuccessNavigateBack) {
                          log("Navigating back to previous screen");
                          Get.back(); // Navigate back to CourseManagementScreen
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.whiteColor,
                minimumSize: Size(screenWidth * 0.3, screenHeight * 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  fontSize: 14,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                createController.isCreating.value ? 'Creating...' : 'Add',
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
            )),
      ],
    ),
  );
}
