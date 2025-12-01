import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../models/EnrolledCourses/enrolled_courses_model.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/coursevideo/course_video_controller.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  final Map<int, int> _userAnswers = {};
  final RxBool _isSubmitting = false.obs;

  void _handleSubmit(Lesson lesson) {
    if (_selectedOption == null) {
      Utils.snackBar(
        'Please select an option before submitting',
        'Info',
      );
      return;
    }

    _userAnswers[_currentQuestionIndex] = _selectedOption!;

    if (_currentQuestionIndex < (lesson.quiz?.length ?? 0) - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
      });
    } else {
      // Prepare answers for backend
      Map<String, String> answers = {};
      try {
        for (int i = 0; i < (lesson.quiz?.length ?? 0); i++) {
          if (_userAnswers.containsKey(i) &&
              lesson.quiz![i].options!.isNotEmpty &&
              _userAnswers[i]! < lesson.quiz![i].options!.length) {
            answers[i.toString()] = lesson.quiz![i].options![_userAnswers[i]!];
          } else {
            Utils.snackBar(
              'Invalid answer for question ${i + 1}. Please try again.',
              'Info',
            );
            return;
          }
        }
      } catch (e) {
        Utils.snackBar(
          'Failed to process quiz answers. Please try again.',
          'Info',
        );
        return;
      }

      // Submit quiz
      _isSubmitting.value = true;

      try {
        Get.back(result: {
          'total': lesson.quiz?.length ?? 0,
          'answers': answers,
        });
      } catch (e) {
        Utils.snackBar(
          'Failed to submit quiz. Returning to course.',
          'Info',
        );
        Get.offNamed(RouteName.courseVideoScreen, arguments: Get.arguments);
      } finally {
        _isSubmitting.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Lesson lesson = Get.arguments as Lesson;
    final quizQuestions = lesson.quiz ?? [];
    final controller = Get.find<CourseVideoController>();
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (quizQuestions.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          automaticallyImplyLeading: true,
          title: lesson.title ?? 'No Title',
        ),
        body: Center(
          child: Text(
            'No quiz questions available',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
        ),
      );
    }

    final currentQuestion = quizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: lesson.title ?? 'NO Title',
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
            //     name: 'QuizScreen');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      'Quiz submitted successfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ),
                Text(
                  textAlign: TextAlign.start,
                  currentQuestion.question ?? 'No Questions',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${quizQuestions.length}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Options
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...currentQuestion.options!
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: isCompleted
                                ? null
                                : () {
                                    setState(() {
                                      _selectedOption = index;
                                      developer.log('Option selected: $index',
                                          name: 'QuizScreen');
                                    });
                                  },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedOption == index &&
                                          !isCompleted
                                      ? (Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color ??
                                          Colors.purpleAccent)
                                      : AppColors.greyColor.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedOption == index && !isCompleted
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppFonts.opensansRegular,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Button
                Center(
                  child: Obx(() => ElevatedButton(
                        onPressed: isCompleted
                            ? () => Get.back()
                            : _isSubmitting.value
                                ? null
                                : () {
                                    developer.log('ElevatedButton pressed',
                                        name: 'QuizScreen');
                                    _handleSubmit(lesson);
                                  },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted
                              ? AppColors.greyColor
                              : AppColors.courseButtonColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(screenWidth * 0.9, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting.value && !isCompleted
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isCompleted
                                    ? 'Back to Course'
                                    : _currentQuestionIndex <
                                            quizQuestions.length - 1
                                        ? 'Next'
                                        : 'Submit',
                                style: const TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
