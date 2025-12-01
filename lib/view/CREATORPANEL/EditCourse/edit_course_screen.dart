import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view/CREATORPANEL/EditCourse/edit_language_dropdown.dart';
import 'package:connectapp/view_models/CREATORPANEL/EditCourse/edit_course_controller.dart';
import 'package:connectapp/view_models/CREATORPANEL/ImagePicker/image_picker_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ImagePicker/image_picker_widget.dart';

class EditCourseScreen extends StatelessWidget {
  const EditCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditCourseController());
    final imagePickerController = Get.put(ImagePickerController());
    final course = Get.arguments;

    // Initialize controllers with course data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeCourse(course);
      if (course.thumbnail != null) {
        imagePickerController.pickedImage(course.thumbnail!);
      }
    });

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'Edit Your Course ',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 2),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleField(context, controller),
                _buildDescriptionField(context, controller),
                _buildImagePicker(context, controller),
                _buildLanguageDropdown(context, controller),
                _buildTagsField(context, controller),
                _buildXpFields(context, controller),
                _buildPublishSwitch(context, controller),
                _buildSaveButton(context, controller, screenWidth),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(
      BuildContext context, EditCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title*',
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          textColor: AppColors.textColor,
          controller: controller.titleController,
          hintText: 'Enter Course Title',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescriptionField(
      BuildContext context, EditCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description*',
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: controller.descriptionController,
          maxLength: 1000,
          hintText: 'Enter Course Description',
          textColor: AppColors.textColor,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImagePicker(
      BuildContext context, EditCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Image',
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 4),
        CoverImagePicker(
          onImageSelected: (file) {
            controller.setThumbnail(file);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLanguageDropdown(
      BuildContext context, EditCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Language*',
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 4),
        EditLanguageDropdown(editCourseController: controller),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTagsField(
      BuildContext context, EditCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (comma,separated)',
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: controller.tagsController,
          hintText: 'e.g., Programming, JavaScript',
          textColor: AppColors.textColor,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildXpFields(BuildContext context, EditCourseController controller) {
    return Column(
      children: [
        _buildXpField(context, 'XP on start', controller.xpOnStartController),
        _buildXpField(context, 'XP on Lesson complete',
            controller.xpOnLessonCompletionController),
        _buildXpField(context, 'XP on Course Completion',
            controller.xpOnCompletionController),
        _buildXpField(context, 'XP per Perfect Quiz',
            controller.xpPerPerfectQuizController),
        _buildXpField(context, 'Coins', controller.coinsController),
      ],
    );
  }

  Widget _buildXpField(
      BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: controller,
          hintText: '0',
          textColor: AppColors.textColor,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPublishSwitch(
      BuildContext context, EditCourseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Text(
            'Publish Course',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.opensansRegular,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => Switch(
              value: controller.isPublished.value,
              onChanged: (val) => controller.isPublished.value = val,
              activeColor: AppColors.greenColor,
            ),
          ),
          const Spacer(),
          Obx(() => Text(
                controller.isPublished.value ? 'Published' : 'Draft',
                style: TextStyle(
                  color: controller.isPublished.value
                      ? AppColors.greenColor
                      : AppColors.redColor,
                  fontFamily: AppFonts.opensansRegular,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, EditCourseController controller,
      double screenWidth) {
    return Center(
      child: Obx(
        () => RoundButton(
          loading: controller.isLoading.value,
          width: screenWidth * 0.95,
          buttonColor: AppColors.blueColor,
          title: 'Save Changes',
          onPress: () {
            if (_validateFields(controller)) {
              controller.updateCourse();
            }
          },
        ),
      ),
    );
  }

  bool _validateFields(EditCourseController controller) {
    if (controller.titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a title',
          backgroundColor: AppColors.redColor, colorText: Colors.white);
      return false;
    }
    if (controller.descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a description',
          backgroundColor: AppColors.redColor, colorText: Colors.white);
      return false;
    }
    if (controller.selectedLanguage.value.isEmpty) {
      Get.snackbar('Error', 'Please select a language',
          backgroundColor: AppColors.redColor, colorText: Colors.white);
      return false;
    }
    return true;
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shadowColor: AppColors.loginContainerColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Editing Help',
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• All fields marked with * are required',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
            const SizedBox(height: 8),
            Text('• Use comma to separate multiple tags',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
            const SizedBox(height: 8),
            Text('• XP values must be whole numbers',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.blueShade)),
          )
        ],
      ),
    );
  }

  TextStyle textStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.opensansRegular,
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );
}
