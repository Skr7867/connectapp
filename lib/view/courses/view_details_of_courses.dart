import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/view_models/controller/GetCourseById/get_course_by_id_controller.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/response/status.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/enrolinNewCourse/enroll_in_new_course_controller.dart';

class ViewDetailsOfCourses extends StatelessWidget {
  const ViewDetailsOfCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final courseId = Get.arguments as String;
    final controller = Get.put(GetCourseByIdController());

    // fetch data when screen opens
    controller.fetchCourseById(courseId);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Course Details',
        // automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAllNamed(RouteName.bottomNavbar);
            }
          },
        ),
        actions: [
          Row(
            children: [
              Obx(() {
                final isSharing = controller.isSharing.value;
                return IconButton(
                  icon: isSharing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        )
                      : const Icon(Icons.share),
                  onPressed: isSharing
                      ? null
                      : () async {
                          final courseId = controller.courseData.value?.sId;

                          if (courseId == null || courseId.isEmpty) {
                            Get.snackbar(
                              'Info',
                              'Course not published',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          controller.isSharing.value = true;

                          try {
                            final deepLink =
                                'https://connectapp.cc/course-details/$courseId';

                            const playStoreLink =
                                'https://play.google.com/store/apps/details?id=app.connectapp.com';

                            final message = '''
🎓 Check out this course on ConnectApp!

$deepLink
If you don't have the app, download it here:
$playStoreLink
''';

                            await Share.share(
                              message.trim(),
                              subject: 'Share Course',
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Sharing Failed',
                              'Something went wrong while sharing!',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          } finally {
                            // Give a short delay to avoid flicker
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            controller.isSharing.value = false;
                          }
                        },
                );
              }),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // Loading state
          if (controller.rxRequestStatus.value == Status.LOADING) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).textTheme.bodyLarge?.color));
          }

          // Error state
          if (controller.rxRequestStatus.value == Status.ERROR) {
            return Center(child: Text(controller.error.value));
          }

          // Empty state
          if (controller.courseData.value == null) {
            return Center(
              child: Text(
                "No Course Data Found",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            );
          }

          final course = controller.courseData.value!;

          return Column(
            children: [
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ProfileSection(
                        title: course.title ?? "Untitled Course",
                        description:
                            course.description ?? "No description available",
                      ),
                      const SizedBox(height: 30),

                      // Course Sections
                      if (course.sections != null &&
                          course.sections!.isNotEmpty)
                        ...course.sections!.map(
                          (section) => Padding(
                            padding: const EdgeInsets.only(bottom: 25),
                            child: CourseSection(
                              sectionTitle: section.title ?? "Untitled Section",
                              duration:
                                  "${section.lessons?.length ?? 0} Lessons",
                              lessons: (section.lessons ?? [])
                                  .asMap()
                                  .entries
                                  .map((entry) => LessonItem(
                                        number: (entry.key + 1).toString(),
                                        title: entry.value.title ??
                                            "Untitled Lesson",
                                        duration:
                                            entry.value.updatedAt ?? "N/A",
                                        isLocked: false,
                                      ))
                                  .toList(),
                            ),
                          ),
                        )
                      else
                        Text(
                          "No sections found",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 50, top: 4),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: GetBuilder<EnrollCourseController>(
            init: EnrollCourseController(),
            builder: (enrollController) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: enrollController.isEnrolled.value
                      ? Colors.grey // 👈 disabled look
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: enrollController.isEnrolled.value
                    ? null
                    : () async {
                        await enrollController.enrollCourse(courseId);

                        if (enrollController.rxRequestStatus.value ==
                            Status.COMPLETED) {
                          Utils.snackBar(
                            enrollController.successMessage.value,
                            "Success",
                          );
                        } else if (enrollController.rxRequestStatus.value ==
                            Status.ERROR) {
                          Utils.snackBar(
                              enrollController.errorMessage.value, "Info");
                        }
                      },
                child: Obx(() {
                  if (enrollController.rxRequestStatus.value ==
                      Status.LOADING) {
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  // Change text based on enrolled status
                  return Text(
                    enrollController.isEnrolled.value
                        ? "Already Enrolled"
                        : 'Enroll For ${controller.courseData.value?.coins.toString()} coins',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.opensansRegular,
                      color: Colors.white,
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final String description;

  const ProfileSection({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          textAlign: TextAlign.start,
          title,
          style: TextStyle(
              fontSize: 24,
              fontFamily: AppFonts.opensansRegular,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class CourseSection extends StatelessWidget {
  final String sectionTitle;
  final String duration;
  final List<LessonItem> lessons;

  const CourseSection({
    super.key,
    required this.sectionTitle,
    required this.duration,
    required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sectionTitle,
                  style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),

        // Lessons
        ...lessons,
      ],
    );
  }
}

class LessonItem extends StatelessWidget {
  final String number;
  final String title;
  final String duration;
  final bool isLocked;

  const LessonItem({
    super.key,
    required this.number,
    required this.title,
    required this.duration,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Lesson Number
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Lesson Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.opensansRegular,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 3),
                Text(
                  duration,
                  style: TextStyle(fontSize: 12, color: AppColors.textColor),
                ),
              ],
            ),
          ),

          // Icon (Play or Lock)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey[300] : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isLocked
                  ? Icon(
                      Icons.lock,
                      size: 16,
                      color: Colors.grey[600],
                    )
                  : const Icon(
                      Icons.play_arrow,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
