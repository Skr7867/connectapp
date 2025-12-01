import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/courseprogress/course_progress_controller.dart';
import 'package:connectapp/view_models/controller/enrolledcourse/enrolled_course_controller.dart';
import 'package:connectapp/view_models/controller/enrollincourse/enroll_in_course_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/response/status.dart';
import '../../models/EnrolledCourses/enrolled_courses_model.dart';
import '../../res/color/app_colors.dart';

class EnrolledCoursesScreen extends StatelessWidget {
  const EnrolledCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final enrolledCourseController = Get.put(EnrolledCourseController());
    final courseProgressController = Get.put(CourseProgressController());
    Get.put(CourseEnrollmentController);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'enrolled_courses'.tr,
        automaticallyImplyLeading: true,
      ),
      body: Container(
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      enrolledCourseController.error.value.isEmpty
                          ? 'An error occurred'
                          : enrolledCourseController.error.value,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: enrolledCourseController.refreshApi,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            case Status.COMPLETED:
              final courses = enrolledCourseController
                  .enrolledCourses.value.enrolledCourses;
              if (courses == null || courses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.school_outlined,
                          color: Colors.blue[400],
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Enrolled Courses',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start learning by enrolling in courses that interest you!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Fetch progress for all courses
              for (var course in courses) {
                if (course.id != null) {
                  courseProgressController.fetchCourseProgress(course.id!);
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blueColor,
                            AppColors.blueColor.withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blueColor.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.greyColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Enrolled Courses',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${courses.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Courses Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 600 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.59,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return GestureDetector(
                          onTap: () {
                            final EnrolledCourses selectedCourse = course;
                            Get.toNamed(
                              RouteName.courseVideoScreen,
                              arguments: selectedCourse,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.greyColor.withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Course Image with Badge
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                      child: SizedBox(
                                        height: screenHeight * 0.12,
                                        width: double.infinity,
                                        child: Image.network(
                                          course.thumbnail ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue[100]!,
                                                  Colors.blue[200]!,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.school,
                                                color: Colors.blue[400],
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: course.isPaid == true
                                              ? Colors.amber[600]
                                              : AppColors.greenColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              course.isPaid == true
                                                  ? Icons.star
                                                  : Icons.check_circle,
                                              color: Colors.white,
                                              size: 10,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              course.isPaid == true
                                                  ? 'Premium'
                                                  : 'Free',
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Course Content
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Course Title
                                        Text(
                                          course.title ?? 'Course',
                                          style: TextStyle(
                                            fontFamily:
                                                AppFonts.opensansRegular,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // Course Description
                                        Text(
                                          course.description ??
                                              'No description',
                                          style: TextStyle(
                                            fontFamily:
                                                AppFonts.opensansRegular,
                                            fontSize: 11,
                                            color: AppColors.textColor,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // Course Stats
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.play_circle_outline,
                                              color: AppColors.textColor,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${course.totalLessons ?? 0}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: AppColors.textColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.folder_outlined,
                                              color: AppColors.textColor,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${course.sections?.length ?? 0}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: AppColors.textColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Rating
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber[600],
                                              size: 12,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              (course.ratings?.avgRating ?? 0)
                                                  .toStringAsFixed(1),
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: Colors.amber[700],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '(${course.ratings?.totalReviews ?? 0})',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: AppColors.textColor,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Spacer(),

                                        // Progress Section
                                        Obx(() {
                                          final progress =
                                              courseProgressController
                                                  .courseProgressMap[course.id];
                                          if (progress == null) {
                                            return SizedBox(
                                              height: 32,
                                              child: Center(
                                                child: SizedBox(
                                                  height: 14,
                                                  width: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: AppColors.blueColor,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          final percentageCompleted = progress
                                                  .percentageCompleted
                                                  ?.toDouble() ??
                                              0.0;
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Progress',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                      fontSize: 10,
                                                      fontFamily: AppFonts
                                                          .opensansRegular,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .greenColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      '${progress.percentageCompleted ?? 0}%',
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .greenColor,
                                                        fontSize: 9,
                                                        fontFamily: AppFonts
                                                            .opensansRegular,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: LinearProgressIndicator(
                                                  value:
                                                      percentageCompleted / 100,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    AppColors.greenColor,
                                                  ),
                                                  minHeight: 6,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${progress.lessonsCompleted ?? 0}/${progress.totalLessons ?? 0} lessons completed',
                                                style: TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: 8,
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
          }
        }),
      ),
    );
  }
}
