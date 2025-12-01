import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/CREATORPANEL/CreateCourse/create_course_controller.dart';
import 'package:connectapp/view_models/CREATORPANEL/ImagePicker/image_picker_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ImagePicker/image_picker_widget.dart';
import '../SelectLanguage/select_language_widget.dart';

class CreateCourseScreen extends StatelessWidget {
  const CreateCourseScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateCourseController());
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Get.put(ImagePickerController());

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'Create Your Course',
      ),
      body: Padding(
        padding: ResponsivePadding.symmetricPadding(context, horizontal: 2),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Title
              Text(
                'Title*',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              CustomTextField(
                controller: controller.titleController,
                hintText: 'Enter Course Title',
                textColor: AppColors.textColor,
              ),
              SizedBox(height: 15),
              // Description
              Text(
                'Description*',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              CustomTextField(
                controller: controller.descriptionController,
                maxLength: 100000000000,
                hintText: 'Enter Course Description',
                textColor: AppColors.textColor,
              ),
              SizedBox(height: 15),
              //*******************************************here is image picker for cover iamge ***************************** */
              Text(
                'Course Image*',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CoverImagePicker(
                onImageSelected: (file) {
                  controller.setThumbnail(file);
                },
              ),

              //*******************************************here is language selector***************************** */

              Text(
                'Select Language*',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold),
              ),
              LanguageDropdown(courseController: controller),
              SizedBox(height: screenHeight * 0.01),

              Text(
                'Tags(comma separated)',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomTextField(
                controller: controller.tagsController,
                hintText: 'e.g., Programming, JavaScript',
                textColor: AppColors.greyColor,
              ),

              // XP fields
              textWithField(
                  context, 'XP on start', controller.xpOnStartController),
              textWithField(context, 'XP on Lesson complete',
                  controller.xpOnLessonCompletionController),
              textWithField(context, 'XP on Course Completion',
                  controller.xpOnCompletionController),
              textWithField(context, 'XP per Perfect Quiz',
                  controller.xpPerPerfectQuizController),
              textWithField(context, 'Coins', controller.coinsController),

              Row(
                children: [
                  Text(
                    'Publish Course',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Obx(
                    () => Switch(
                      activeColor: AppColors.greenColor,
                      value: controller.isPublished.value,
                      onChanged: (val) => controller.isPublished.value = val,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: Obx(
                  () => RoundButton(
                    loading: controller.isLoading.value,
                    width: screenWidth * 0.95,
                    buttonColor: AppColors.blueColor,
                    title: 'Send Course Request',
                    onPress: () {
                      controller.createCourse();
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle textStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.opensansRegular,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  Widget textWithField(
      BuildContext context, String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textStyle(context)),
        CustomTextField(
          keyboardType: TextInputType.number,
          controller: ctrl,
          hintText: '0',
          textColor: AppColors.textColor,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
