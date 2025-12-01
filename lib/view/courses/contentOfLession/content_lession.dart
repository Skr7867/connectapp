import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../models/EnrolledCourses/enrolled_courses_model.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/coursevideo/course_video_controller.dart';

class ContentLessonScreen extends StatefulWidget {
  const ContentLessonScreen({super.key});

  @override
  State<ContentLessonScreen> createState() => _ContentLessonScreenState();
}

class _ContentLessonScreenState extends State<ContentLessonScreen> {
  final RxBool _isSubmitting = false.obs;

  void _handleSubmit(Lesson lesson) async {
    // developer.log('Submit button pressed for lesson: ${lesson.id}',
    //     name: 'ContentLessonScreen');
    _isSubmitting.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1)); // simulate processing
      Get.back(result: true);
    } catch (e) {
      developer.log('Error with Get.back(): $e', name: 'ContentLessonScreen');
      Utils.snackBar(
        'Error',
        'Failed to submit content. Returning to course.',
      );
      Get.offNamed(RouteName.courseVideoScreen, arguments: Get.arguments);
      _isSubmitting.value = false; // Only reset loading on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final Lesson lesson = Get.arguments as Lesson;
    final controller = Get.find<CourseVideoController>();
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // developer.log('Building ContentLessonScreen, lessonId: ${lesson.id}',
    //     name: 'ContentLessonScreen');

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: lesson.title ?? 'No Lession Title',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchCourseProgress(controller.course.id);
            },
            tooltip: 'Refresh Progress',
          ),
        ],
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            // Compute isCompleted reactively
            final isCompleted = controller
                    .courseProgress.value?.progress?.completedLessons
                    ?.any((cl) =>
                        cl.lessonId == lesson.id && cl.isCompleted == true) ??
                controller.allLessons
                    .firstWhere((l) => l.id == lesson.id, orElse: () => lesson)
                    .isCompleted;
            // developer.log(
            //     'Lesson ${lesson.id} isCompleted: $isCompleted, progressLessons: ${controller.courseProgress.value?.progress?.completedLessons?.map((cl) => "${cl.lessonId}:${cl.isCompleted}").toList() ?? []}',
            //     name: 'ContentLessonScreen');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textAlign: TextAlign.justify,
                  lesson.title ?? 'No Lession Title',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                if (isCompleted!)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Text(
                      'Content submitted successfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ),
                Expanded(
                  child: isCompleted
                      ? const SizedBox.shrink()
                      : SingleChildScrollView(
                          child: Html(
                            data: lesson.textContent ??
                                '<p>No content available</p>',
                            style: {
                              "body": Style(
                                fontSize: FontSize(16.0),
                                fontFamily: AppFonts.opensansRegular,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                textAlign: TextAlign.start,
                                lineHeight: LineHeight.number(1),
                              ),
                              "h1": Style(
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                                margin: Margins.only(bottom: 1),
                              ),
                              "h3": Style(
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                                margin: Margins.only(bottom: 1),
                              ),
                              "strong": Style(
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                                padding: HtmlPaddings.symmetric(vertical: 1),
                              ),
                              "p": Style(
                                fontFamily: AppFonts.opensansRegular,
                                margin: Margins.only(bottom: 1),
                                padding: HtmlPaddings.symmetric(vertical: 1),
                                textAlign: TextAlign.start,
                              ),
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Obx(() => RoundButton(
                        width: screenWidth * 0.9,
                        buttonColor: isCompleted
                            ? AppColors.greyColor
                            : AppColors.courseButtonColor,
                        title: _isSubmitting.value && !isCompleted
                            ? ''
                            : isCompleted
                                ? 'Back to Course'
                                : 'Submit',
                        loading: _isSubmitting.value && !isCompleted,
                        onPress: isCompleted
                            ? () => Get.back()
                            : () => _handleSubmit(lesson),
                      )),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }
}
