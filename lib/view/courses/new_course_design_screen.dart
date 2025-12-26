import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/topCreatorCourses/top_creator_courses_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import '../../data/response/status.dart';
import '../../res/assets/image_assets.dart';
import '../../res/fonts/app_fonts.dart';
import '../../view_models/controller/courseprogress/course_progress_controller.dart';
import '../../view_models/controller/enrolledcourse/enrolled_course_controller.dart';
import '../../view_models/controller/enrollincourse/enroll_in_course_controller.dart';
import '../../view_models/controller/popularCourses/popular_courses_controller.dart';
import '../../view_models/controller/searchCourses/search_courses_controller.dart';
import '../../view_models/controller/topReview/top_review_controller.dart';

class NewCourseDesignScreen extends StatelessWidget {
  const NewCourseDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final enrolledCourseController = Get.put(EnrolledCourseController());
    final courseProgressController = Get.put(CourseProgressController());
    final popularCoursesController = Get.put(PopularCoursesController());
    final topReviewController = Get.put(TopReviewController());
    final searchCourseController = Get.put(SearchCourseController());
    final topCreatorCoursesController = Get.put(TopCreatorCoursesController());
    Get.put(CourseEnrollmentController);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    String getInitials(String? name) {
      if (name == null || name.trim().isEmpty) return "?";

      List<String> parts = name.trim().split(" ");
      if (parts.length == 1) {
        // Single name → first 2 letters
        return parts[0]
            .substring(0, parts[0].length >= 2 ? 2 : 1)
            .toUpperCase();
      }

      // First two words → first letter of each
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Courses',
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // Search Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.greyColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        cursorColor:
                            Theme.of(context).textTheme.bodyLarge?.color,
                        cursorHeight: 25,
                        onChanged: (value) {
                          searchCourseController.updateSearchQuery(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Search courses by name...",
                          hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: AppFonts.opensansRegular,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Results Section
              Obx(() {
                if (searchCourseController.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (searchCourseController.errorMessage.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        searchCourseController.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (searchCourseController.searchQuery.isNotEmpty) {
                  if (searchCourseController.searchCourseModel.value.data ==
                          null ||
                      searchCourseController
                          .searchCourseModel.value.data!.isEmpty) {
                    // Display "No courses available" message
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: SizedBox(
                          height: screenHeight * 0.7,
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
                                  Icons.search_off,
                                  color: Colors.blue[400],
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No courses available with this keyword',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different keyword',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final courses =
                      searchCourseController.searchCourseModel.value.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Search Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 340,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  right: index < courses.length - 1 ? 16 : 0),
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    RouteName.viewDetailsOfCourses,
                                    arguments: course.id,
                                  );
                                },
                                child: Container(
                                  width: screenWidth * 0.55,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          AppColors.greyColor.withOpacity(0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(12)),
                                            child: Image.network(
                                              course.thumbnail ?? '',
                                              fit: BoxFit.cover,
                                              height: screenHeight * 0.17,
                                              width: double.infinity,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                ImageAssets.pythonIcon,
                                                fit: BoxFit.cover,
                                                height: screenHeight * 0.17,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                          if (course.isPaid == false)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF00D9A3),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  'Free',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course.title ?? 'Course',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                course.description ??
                                                    'No description',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                  fontSize: 12,
                                                  color: AppColors.textColor,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    (course.ratings
                                                                ?.avgRating ??
                                                            0)
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontFamily: AppFonts
                                                          .opensansRegular,
                                                      color: Colors.orange,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '(${(course.ratings?.totalReviews ?? 0)})',
                                                    style: TextStyle(
                                                      fontFamily: AppFonts
                                                          .opensansRegular,
                                                      color:
                                                          AppColors.textColor,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              Center(
                                                child: RoundButton(
                                                  width: screenWidth * 0.9,
                                                  height: 30,
                                                  buttonColor:
                                                      AppColors.blueColor,
                                                  title: 'View Details',
                                                  onPress: () {
                                                    Get.toNamed(
                                                      RouteName
                                                          .viewDetailsOfCourses,
                                                      arguments: course.id,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // My Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My progress',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(RouteName.enrolledCourses);
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.opensansRegular,
                            color: AppColors.blueColor),
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Progress Courses List
              SizedBox(
                height: 350,
                child: Obx(() {
                  switch (enrolledCourseController.rxRequestStatus.value) {
                    case Status.LOADING:
                      return const Center(child: CircularProgressIndicator());
                    case Status.ERROR:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text(
                            //   enrolledCourseController.error.value.isEmpty
                            //       ? 'An error occurred'
                            //       : enrolledCourseController.error.value,
                            //   style: const TextStyle(color: Colors.red),
                            // ),

                            Text(
                              'Failed to load courses',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: AppFonts.opensansRegular),
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
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

                      for (var course in courses) {
                        if (course.id != null) {
                          courseProgressController
                              .fetchCourseProgress(course.id!);
                        }
                      }

                      final displayCourses = courses.take(2).toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayCourses.length,
                        itemBuilder: (context, index) {
                          final course = displayCourses[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                right:
                                    index < displayCourses.length - 1 ? 16 : 0),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteName.courseVideoScreen,
                                    arguments: course);
                              },
                              child: Container(
                                width: screenWidth * 0.55,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.greyColor.withOpacity(0.4),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.network(
                                        course.thumbnail ?? '',
                                        fit: BoxFit.cover,
                                        height: screenHeight * 0.17,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          ImageAssets.pythonIcon,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: screenHeight * 0.12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              course.title ?? 'Course',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              course.description ??
                                                  'No description',
                                              style: TextStyle(
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                  fontSize: 12,
                                                  color: AppColors.textColor),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.play_circle_outline,
                                                  size: 14,
                                                  color: AppColors.textColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${course.totalLessons ?? 0} Lessons',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: AppFonts
                                                        .opensansRegular,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  Icons.folder_outlined,
                                                  size: 14,
                                                  color: AppColors.textColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${course.sections?.length ?? 0} Sections',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: AppFonts
                                                        .opensansRegular,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.orange,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  (course.ratings?.avgRating ??
                                                          0)
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: AppFonts
                                                        .opensansRegular,
                                                    color: Colors.orange,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '(${(course.ratings?.totalReviews ?? 0)})',
                                                  style: TextStyle(
                                                    fontFamily: AppFonts
                                                        .opensansRegular,
                                                    color: AppColors.textColor,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Obx(() {
                                              final progress =
                                                  courseProgressController
                                                          .courseProgressMap[
                                                      course.id];
                                              if (progress == null) {
                                                return const SizedBox(
                                                  height: 20,
                                                  child: Center(
                                                    child: SizedBox(
                                                      height: 16,
                                                      width: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              final percentageCompleted =
                                                  progress.percentageCompleted
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
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color,
                                                          fontSize: 12,
                                                          fontFamily: AppFonts
                                                              .opensansRegular,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${progress.percentageCompleted ?? 0}%',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .greenColor,
                                                          fontSize: 12,
                                                          fontFamily: AppFonts
                                                              .opensansRegular,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  GFProgressBar(
                                                    lineHeight: 8,
                                                    percentage:
                                                        percentageCompleted /
                                                            100,
                                                    backgroundColor: AppColors
                                                        .textfieldColor,
                                                    progressBarColor:
                                                        AppColors.greenColor,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${progress.lessonsCompleted ?? 0}/${progress.totalLessons ?? 0} Lessons Completed',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize: 11,
                                                          fontFamily: AppFonts
                                                              .opensansRegular,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Center(
                                                    child: RoundButton(
                                                        width:
                                                            screenWidth * 0.9,
                                                        height: 30,
                                                        buttonColor:
                                                            AppColors.blueColor,
                                                        title: 'Continue',
                                                        onPress: () {
                                                          Get.toNamed(
                                                              RouteName
                                                                  .courseVideoScreen,
                                                              arguments:
                                                                  course);
                                                        }),
                                                  )
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
                            ),
                          );
                        },
                      );
                  }
                }),
              ),
              const SizedBox(height: 24),

              // Popular Courses Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Courses',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(RouteName.popularCoursesScreen);
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.opensansRegular,
                            color: AppColors.blueColor),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 340,
                child: Obx(() {
                  if (popularCoursesController.isLoading.value &&
                      popularCoursesController.popularCourses.isEmpty) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ));
                  }

                  if (popularCoursesController.errorMessage.isNotEmpty) {
                    return Center(
                        child:
                            Text(popularCoursesController.errorMessage.value));
                  }

                  final displayCourses =
                      popularCoursesController.popularCourses.take(2).toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayCourses.length,
                    itemBuilder: (context, index) {
                      final course = displayCourses[index];
                      return Padding(
                        padding: EdgeInsets.only(
                            right: index < displayCourses.length - 1 ? 16 : 0),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              RouteName.viewDetailsOfCourses,
                              arguments: course.courseId,
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.55,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.greyColor.withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.network(
                                        course.thumbnail ?? '',
                                        fit: BoxFit.cover,
                                        height: screenHeight * 0.17,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            height: screenHeight * 0.17,
                                            width: double.infinity,
                                            color: Colors.grey[800],
                                            child: Image.asset(
                                              ImageAssets.pythonIcon,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          height: screenHeight * 0.17,
                                          width: double.infinity,
                                          color: Colors.grey[800],
                                          child: Image.asset(
                                            ImageAssets.pythonIcon,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (course.coins == 0)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00D9A3),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Free',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.title ?? 'Course',
                                          style: TextStyle(
                                            fontFamily:
                                                AppFonts.opensansRegular,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          course.description ??
                                              'No description',
                                          style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              fontSize: 12,
                                              color: AppColors.textColor),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              (course.ratings?.avgRating ?? 0)
                                                  .toString(),
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: Colors.orange,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${(course.ratings?.totalReviews ?? 0)})',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: AppColors.textColor,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons.people,
                                              color: AppColors.textColor,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${course.enrolledCount ?? 0}',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: AppColors.textColor,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Center(
                                          child: RoundButton(
                                              width: screenWidth * 0.9,
                                              height: 30,
                                              buttonColor: AppColors.blueColor,
                                              title: 'View Details',
                                              onPress: () {
                                                Get.toNamed(
                                                    RouteName
                                                        .viewDetailsOfCourses,
                                                    arguments: course.courseId);
                                              }),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: 15),
              // Creator's Choice Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Creator's Choice",
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Each week, discover handpicked courses from one of our top creators — fresh, personal, and inspiring.",
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.greyColor.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greyColor.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Meet Your Creator",
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipOval(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.tealAccent,
                                  child: topCreatorCoursesController
                                              .coursesData
                                              .value
                                              ?.data
                                              ?.creator
                                              ?.avatar
                                              ?.imageUrl !=
                                          null
                                      ? Image.network(
                                          topCreatorCoursesController
                                              .coursesData
                                              .value!
                                              .data!
                                              .creator!
                                              .avatar!
                                              .imageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child; // Image loaded
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                                strokeWidth: 2,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.person,
                                                color: Colors.purple[700]);
                                          },
                                        )
                                      : Icon(Icons.person,
                                          color: Colors.purple[700]), // No URL
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topCreatorCoursesController.coursesData
                                              .value?.data?.creator?.fullName ??
                                          'No name',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppFonts.opensansRegular,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color),
                                    ),
                                    Text(
                                      'Expert ● ${topCreatorCoursesController.coursesData.value?.data?.courseCount ?? 'Not Available'} Courses',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppFonts.opensansRegular,
                                          color: AppColors.textColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "This creator made a big impact this week explore their top courses and learn from the best",
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFonts.opensansRegular,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Creator Courses',
                          style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   'See All',
                        //   style: TextStyle(
                        //       color: Colors.blue,
                        //       fontWeight: FontWeight.bold,
                        //       fontFamily: AppFonts.opensansRegular),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 340,
                      child: Obx(() {
                        // Show loader while fetching data
                        if (topCreatorCoursesController.isLoading.value &&
                            (topCreatorCoursesController.coursesData.value?.data
                                    ?.courses?.isEmpty ??
                                true)) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        // Show error message if any
                        if (topCreatorCoursesController
                            .errorMessage.isNotEmpty) {
                          return Center(
                            child: Text(
                              'Failed to load course',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.redColor),
                            ),
                          );
                        }

                        final courses = topCreatorCoursesController
                                .coursesData.value?.data?.courses ??
                            [];

                        if (courses.isEmpty) {
                          return Center(
                              child: Text(
                            'No courses available',
                            style: TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ));
                        }

                        // Display horizontal list of courses
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];

                            return Padding(
                              padding: EdgeInsets.only(
                                  right: index < courses.length - 1 ? 16 : 0),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to course details
                                  Get.toNamed(
                                    RouteName.viewDetailsOfCourses,
                                    arguments: course.sId,
                                  );
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                        child: course.thumbnail != null
                                            ? Image.network(
                                                course.thumbnail!,
                                                fit: BoxFit.cover,
                                                height: 130,
                                                width: double.infinity,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    height: 130,
                                                    width: double.infinity,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    height: 130,
                                                    width: double.infinity,
                                                    color: Colors.grey[300],
                                                    child: const Icon(Icons
                                                        .image_not_supported),
                                                  );
                                                },
                                              )
                                            : Container(
                                                height: 130,
                                                width: double.infinity,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                    Icons.image_not_supported),
                                              ),
                                      ),
                                      // Course info
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course.title ?? 'No title',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: AppFonts
                                                        .opensansRegular,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                course.description ??
                                                    'No description',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: AppFonts
                                                        .opensansRegular,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Spacer(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    course.coins == 0
                                                        ? 'Free'
                                                        : '${course.coins} Coins',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.green,
                                                      fontFamily: AppFonts
                                                          .opensansRegular,
                                                    ),
                                                  ),
                                                  Icon(Icons.arrow_forward_ios,
                                                      size: 16,
                                                      color: Colors.grey[600]),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Real People. Real Knowledge section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real People. Real Knowledge.',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every course starts with a story — and someone who\'s lived it.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Features list
              FeatureItem(
                icon: Icons.scatter_plot,
                iconColor: Colors.orange,
                title: 'Unique Topics',
                subtitle: 'Fresh courses on topics all in one place',
              ),
              FeatureItem(
                icon: Icons.people,
                iconColor: Colors.blue,
                title: 'Real Connections',
                subtitle: 'Chat, collaborate, and follow learners.',
              ),
              FeatureItem(
                icon: Icons.card_giftcard,
                iconColor: Colors.red,
                title: 'Token Access',
                subtitle: 'Rewarding access for completing courses.',
              ),
              FeatureItem(
                icon: Icons.library_books,
                iconColor: Colors.pink,
                title: 'Curated Content',
                subtitle: 'Only the best from verified experts.',
              ),
              FeatureItem(
                icon: Icons.school,
                iconColor: Colors.cyan,
                title: 'Interactive Learning',
                subtitle: 'Ask questions and get feedback.',
              ),
              FeatureItem(
                icon: Icons.rocket_launch,
                iconColor: Colors.orange,
                title: 'Career Growth',
                subtitle: 'Skills that help your career.',
              ),

              const SizedBox(height: 32),

              // Community review section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What Our Community says',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every course makes an impact - here\'s what that looks like.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textColor,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (topReviewController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (topReviewController.errorMessage.isNotEmpty) {
                        return Center(
                            child:
                                Text(topReviewController.errorMessage.value));
                      }

                      if (topReviewController.topReviews.isEmpty) {
                        return Center(
                            child: Text(
                          "No reviews found",
                          style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topReviewController.topReviews.length,
                        itemBuilder: (context, index) {
                          final review = topReviewController.topReviews[index];
                          return InkWell(
                            onTap: () {
                              Get.toNamed(RouteName.clipProfieScreen,
                                  arguments: review.user!.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.greyColor.withOpacity(0.4),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade300,

                                    // If avatar exists → use CachedNetworkImage
                                    backgroundImage:
                                        (review.user?.avatar != null &&
                                                review.user!.avatar!.isNotEmpty)
                                            ? CachedNetworkImageProvider(
                                                review.user!.avatar!)
                                            : null,

                                    child: (review.user?.avatar == null ||
                                            review.user!.avatar!.isEmpty)
                                        ? Text(
                                            getInitials(review.user?.name),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.user?.name ?? "Unknown User",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color),
                                        ),
                                        Text(
                                          review.course?.title ??
                                              "No Course Title",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textColor,
                                            fontFamily:
                                                AppFonts.opensansRegular,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          (review.comment?.isNotEmpty ?? false)
                                              ? review.comment!
                                              : "No Comment",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textColor,
                                            fontFamily:
                                                AppFonts.opensansRegular,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Row(
                                              children: List.generate(
                                                5,
                                                (starIndex) => Icon(
                                                  starIndex <
                                                          (review.rating ?? 0)
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${review.rating ?? 0}/5",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                  color: AppColors.redColor),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat('d MMM yyyy h:mm a')
                                              .format(
                                            DateTime.parse(
                                                review.createdAt.toString()),
                                          ),
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: AppColors.textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const FilterChip({super.key, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textColor,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final String description;
  final String rating;
  final int enrolledCount;
  final bool isFree;

  const CourseCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.description,
    required this.rating,
    required this.enrolledCount,
    required this.isFree,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  thumbnail,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                      ),
                      child: Image.asset(
                        'assets/images/java.png',
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                      ),
                      child: Image.asset(
                        'assets/images/java.png',
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              if (isFree)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D9A3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Free',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 11,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.people,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        enrolledCount.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
