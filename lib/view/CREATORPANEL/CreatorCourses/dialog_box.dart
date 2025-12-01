import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/CREATORPANEL/CreateCourseGroup/create_course_group_controller.dart';
import '../../../view_models/CREATORPANEL/ImagePicker/image_picker_controller.dart';
import '../ImagePicker/image_picker_widget.dart';
import '../../../data/response/status.dart';

void showCreateGroupDialog(BuildContext context, String courseId) {
  final groupController = Get.put(CreateCourseGroupController());
  final imageController = Get.put(ImagePickerController());

  showDialog(
    context: context,
    builder: (context) {
      double screenHeight = MediaQuery.of(context).size.height;
      // groupController.setGroupName('');

      return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Create Group',
          style: TextStyle(
            fontSize: 15,
            fontFamily: AppFonts.opensansRegular,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Course ID',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                CustomTextField(
                  fontSize: 9,
                  hintText: '',
                  controller: TextEditingController(text: courseId),
                  readOnly: true,
                  textColor: AppColors.textColor,
                ),
                const SizedBox(height: 10),
                Text(
                  'Group Name',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                CustomTextField(
                  hintText: 'Enter group name',
                  hintTextColor: AppColors.textColor,
                  controller: groupController.groupNameController.value,
                ),
                const SizedBox(height: 10),
                Text(
                  'Group Avatar',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                CoverImagePicker(),
                const SizedBox(height: 10),
                if (groupController.rxRequestStatus.value == Status.ERROR)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      groupController.error.value,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                Center(
                  child: groupController.rxRequestStatus.value == Status.LOADING
                      ? CircularProgressIndicator(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )
                      : RoundButton(
                          height: screenHeight * 0.06,
                          width: double.infinity,
                          buttonColor: AppColors.blueColor,
                          title: 'Create Group',
                          onPress: () async {
                            if (groupController
                                .groupNameController.value.text.isEmpty) {
                              Utils.snackBar(
                                'Please enter a group name',
                                'Info',
                              );
                              return;
                            }

                            await groupController.createCourseGroup(
                              courseId,
                              imageController.pickedImage.value,
                            );

                            if (groupController.rxRequestStatus.value ==
                                Status.COMPLETED) {
                              Get.back();
                            }
                          },
                        ),
                ),
              ],
            ),
          );
        }),
      );
    },
  );
}
