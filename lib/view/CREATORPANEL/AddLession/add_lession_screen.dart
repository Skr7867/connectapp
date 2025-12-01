import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/custom_widgets/custome_appbar.dart';
import '../../../res/custom_widgets/custome_textfield.dart';
import '../../../res/custom_widgets/responsive_padding.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../view_models/CREATORPANEL/ContenTypeController/content_type_controller.dart';
import '../../../view_models/CREATORPANEL/CreateLession/create_lession_controller.dart';
import '../../../view_models/CREATORPANEL/EditCourse/edit_lession_controller.dart';

class AddLessonScreen extends StatefulWidget {
  const AddLessonScreen({super.key});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final ContentTypeController contentTypeController =
      Get.put(ContentTypeController());
  final LessonController lessonController = Get.put(LessonController());
  final EditLessionController editLessionController =
      Get.put(EditLessionController());

  late String courseId;
  late String sectionId;
  String? lessonId;
  bool isEditMode = false;

  // TextEditingControllers for input fields
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController textContentController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    courseId = args['courseId']?.toString() ?? '';
    sectionId = args['sectionId']?.toString() ?? '';
    lessonId = args['lessonId']?.toString();
    isEditMode = lessonId != null;

    // Initialize controllers
    titleController =
        TextEditingController(text: isEditMode ? args['title'] ?? '' : '');
    descriptionController = TextEditingController(
        text: isEditMode ? args['description'] ?? '' : '');
    textContentController = TextEditingController(
        text: isEditMode ? args['textContent'] ?? '' : '');

    if (isEditMode) {
      if (courseId.isEmpty || sectionId.isEmpty || lessonId!.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('Error', 'Missing required IDs for editing lesson');
          Get.back();
        });
      }

      // Set controller values to lessonController for consistency
      lessonController.setTitle(titleController.text);
      lessonController.setDescription(descriptionController.text);
      lessonController.setTextContent(textContentController.text);

      String contentType = args['contentType']?.toString().capitalize ?? 'Text';
      if (['Text', 'Video', 'Quiz'].contains(contentType)) {
        contentTypeController.contentType.value = contentType;
      } else {
        log('Invalid contentType: $contentType, defaulting to Text');
        contentTypeController.contentType.value = 'Text';
      }
    } else {
      contentTypeController.contentType.value = 'Text';
    }

    // Update lessonController when text changes
    titleController
        .addListener(() => lessonController.setTitle(titleController.text));
    descriptionController.addListener(
        () => lessonController.setDescription(descriptionController.text));
    textContentController.addListener(
        () => lessonController.setTextContent(textContentController.text));
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    titleController.dispose();
    descriptionController.dispose();
    textContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditMode ? 'Edit Lesson' : 'Add Lesson',
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 2),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _buildTitleInput(),
                SizedBox(height: 20),
                _buildDescriptionInput(),
                SizedBox(height: 10),
                _buildContentTypeDropdown(),
                SizedBox(height: screenHeight * 0.02),
                Obx(() {
                  switch (contentTypeController.contentType.value) {
                    case 'Text':
                      return _buildTextEditor(
                          isEditMode, Get.arguments?['textContent']);
                    case 'Video':
                      return _buildVideoPicker(context);
                    case 'Quiz':
                      return _buildQuizForm();
                    default:
                      return const SizedBox.shrink();
                  }
                }),
                SizedBox(height: screenHeight * 0.02),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.greyColor.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextFormField(
            controller: titleController,
            cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.textColor,
              fontFamily: AppFonts.opensansRegular,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter Title',
              hintStyle: TextStyle(color: Colors.white),
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.opensansRegular,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.greyColor.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextFormField(
            controller: descriptionController,
            cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
            maxLines: 5,
            style: const TextStyle(
              color: AppColors.textColor,
              fontFamily: AppFonts.opensansRegular,
            ),
            decoration: const InputDecoration(
              hintText: 'Write your description here...',
              hintStyle: TextStyle(
                  color: AppColors.textColor,
                  fontFamily: AppFonts.opensansRegular),
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 7),
        Text(
          'Content Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        Obx(() => DropdownButtonFormField<String>(
              iconEnabledColor: Theme.of(context).textTheme.bodyLarge?.color,
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              value: contentTypeController.contentType.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                ),
              ),
              style: const TextStyle(
                color: AppColors.textColor,
              ),
              items: ['Text', 'Video', 'Quiz']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  contentTypeController.contentType.value = val;
                }
              },
            )),
      ],
    );
  }

  Widget _buildTextEditor(bool isEditMode, String? initialTextContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Text Content', style: TextStyle(color: Colors.white)),
        Container(
          margin: const EdgeInsets.only(top: 6),
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.greyColor.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextFormField(
            controller: textContentController,
            cursorColor: AppColors.whiteColor,
            maxLines: null,
            expands: true,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular),
            decoration: const InputDecoration(
              hintText: 'Enter formatted text...',
              hintStyle: TextStyle(color: AppColors.textColor),
              contentPadding: EdgeInsets.all(8),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPicker(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Video',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                if (lessonController.selectedVideoFile.value == null) {
                  lessonController.pickVideo();
                }
              },
              child: Container(
                height: screenHeight * 0.06,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.video_file,
                      color: AppColors.textColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lessonController.selectedVideoFile.value == null
                            ? 'Choose video file'
                            : lessonController.selectedVideoName.value,
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontFamily: AppFonts.opensansRegular),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lessonController.selectedVideoFile.value != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: lessonController.removeVideo,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildQuizForm() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(contentTypeController.quizQuestions.length,
                (questionIndex) {
              final question =
                  contentTypeController.quizQuestions[questionIndex];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.greyColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Question ${questionIndex + 1}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => contentTypeController
                              .removeQuestion(questionIndex),
                          child: const Text(
                            'remove',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      textColor: Theme.of(context).textTheme.bodyLarge?.color,
                      hintText: 'Enter question',
                      fontSize: 14,
                      onChanged: (val) => question.question.value = val,
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 110,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              textColor:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14,
                              hintText: 'Option ${index + 1}',
                              onChanged: (val) =>
                                  question.options[index].value = val,
                            ),
                            Row(
                              children: [
                                Obx(
                                  () => Checkbox(
                                    value: question.correctAnswer[index].value,
                                    onChanged: (val) => question
                                        .correctAnswer[index]
                                        .value = val ?? false,
                                    activeColor: AppColors.buttonColor,
                                    checkColor: Colors.white,
                                    fillColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return AppColors.buttonColor;
                                        }
                                        return Colors.white;
                                      },
                                    ),
                                  ),
                                ),
                                const Text(
                                  'This option is correct',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.greyColor,
                                      fontFamily: AppFonts.opensansRegular),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: contentTypeController.addQuestion,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blackColor),
                child: const Text(
                  'Add Question',
                  style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildSubmitButton() {
    return Obx(() => Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: lessonController.isLoading.value ||
                    editLessionController.isUpdating.value
                ? null
                : () async {
                    if (isEditMode) {
                      final success = await editLessionController.updateLesson(
                        courseId,
                        sectionId,
                        lessonId!,
                        lessonController.title.value,
                        lessonController.description.value,
                        contentTypeController.contentType.value,
                        lessonController.textContent.value,
                      );
                      if (success) Get.back();
                    } else {
                      await lessonController.createLesson();
                    }
                  },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.blackColor),
            child: Text(
              lessonController.isLoading.value ||
                      editLessionController.isUpdating.value
                  ? 'Processing...'
                  : isEditMode
                      ? 'Update'
                      : 'Create',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular),
            ),
          ),
        ));
  }
}
