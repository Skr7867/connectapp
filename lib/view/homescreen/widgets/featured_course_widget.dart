import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/courseprogress/course_progress_controller.dart';
import 'package:connectapp/view_models/controller/enrolledcourse/enrolled_course_controller.dart';
import 'package:connectapp/view_models/controller/enrollincourse/enroll_in_course_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../data/response/status.dart';
import '../../../res/assets/image_assets.dart';
import '../../../res/color/app_colors.dart';

class FeaturedCourseWidget extends StatelessWidget {
  const FeaturedCourseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final enrolledCourseController = Get.put(EnrolledCourseController());
    final courseProgressController = Get.put(CourseProgressController());
    Get.put(CourseEnrollmentController);
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(bottom: 10),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Obx(() {
        switch (enrolledCourseController.rxRequestStatus.value) {
          case Status.LOADING:
            return const Center(child: CircularProgressIndicator());
          case Status.ERROR:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    enrolledCourseController.error.value.isEmpty
                        ? 'An error occurred'
                        : enrolledCourseController.error.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: enrolledCourseController.refreshApi,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          case Status.COMPLETED:
            final courses =
                enrolledCourseController.enrolledCourses.value.enrolledCourses;
            if (courses == null || courses.isEmpty) {
              return const Center(
                child: Text(
                  'No enrolled courses found.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            for (var course in courses) {
              if (course.id != null) {
                courseProgressController.fetchCourseProgress(course.id!);
              }
            }

            final inProgressCourses = courses
                .asMap()
                .entries
                .where((entry) {
                  final course = entry.value;
                  final progress =
                      courseProgressController.courseProgressMap[course.id];
                  final percentage =
                      progress?.percentageCompleted?.toDouble() ?? 0.0;
                  return percentage > 0 && percentage < 100;
                })
                .map((entry) => entry.value)
                .toSet()
                .toList();

            if (inProgressCourses.isEmpty) {
              return const Center(
                child: Text(
                  'No in-progress courses found.',
                  style: TextStyle(
                      fontSize: 16, fontFamily: AppFonts.opensansRegular),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: inProgressCourses.map((course) {
                  final progress =
                      courseProgressController.courseProgressMap[course.id];
                  final percentageCompleted =
                      progress?.percentageCompleted?.toDouble() ?? 0.0;

                  return Center(
                    child: Container(
                      // height: 400,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      width: 340,
                      padding: const EdgeInsets.only(
                          top: 6, left: 6, right: 6, bottom: 40),
                      decoration: BoxDecoration(
                        color: AppColors.textfieldColor,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                    bottom: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    course.thumbnail ?? '',
                                    fit: BoxFit.cover,
                                    height: screenHeight * 0.15,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      ImageAssets.pythonIcon,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: screenHeight * 0.15,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  course.title ?? 'Course',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.helveticaMedium,
                                    fontSize: 16,
                                    color: AppColors.blackColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 16, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Recently",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontFamily: AppFonts.helveticaMedium,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.play_arrow,
                                              size: 14, color: Colors.green),
                                          SizedBox(width: 2),
                                          Text(
                                            "In Progress",
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.helveticaMedium,
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  course.description ?? 'No description',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontFamily: AppFonts.helveticaMedium,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                // Progress Bar
                                GFProgressBar(
                                  lineHeight: 6,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  percentage: percentageCompleted / 100,
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  progressBarColor: AppColors.greenColor,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${progress?.lessonsCompleted ?? 0}/${progress?.totalLessons ?? 0} Lesson${(progress?.totalLessons ?? 0) == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 10,
                                        fontFamily: AppFonts.helveticaMedium,
                                      ),
                                    ),
                                    Text(
                                      '${progress?.percentageCompleted ?? 0}% Complete',
                                      style: const TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 10,
                                        fontFamily: AppFonts.helveticaMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Bottom Button
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black,
                            ),
                            child: TextButton(
                              onPressed: () {
                                Get.toNamed(
                                  RouteName.courseVideoScreen,
                                  arguments: course,
                                );
                              },
                              child: const Text(
                                "Continue learning",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.helveticaMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
        }
      }),
    );
  }
}
