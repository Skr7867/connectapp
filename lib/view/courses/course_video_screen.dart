import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../models/EnrolledCourses/enrolled_courses_model.dart';
import '../../view_models/controller/coursevideo/course_video_controller.dart';

String stripHtmlTags(String html) {
  if (html.isEmpty) return '';
  return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

class CourseVideoScreen extends StatelessWidget {
  const CourseVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseVideoController controller = Get.put(CourseVideoController());
    final EnrolledCourses course = Get.arguments as EnrolledCourses;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Obx(() => Column(
                        children: [
                          Stack(
                            children: [
                              // Video Player Container
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? screenHeight * 0.35
                                    : screenHeight * 0.95,
                                color: Colors.black,
                                child: controller.isVideoInitialized.value &&
                                        controller
                                                .videoPlayerController.value !=
                                            null
                                    ? AspectRatio(
                                        aspectRatio: controller
                                            .videoPlayerController
                                            .value!
                                            .value
                                            .aspectRatio,
                                        child: GestureDetector(
                                          onTap: controller
                                              .toggleControlsVisibility,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Video Player with GetBuilder for targeted updates
                                              GetBuilder<CourseVideoController>(
                                                id: 'video_player',
                                                builder: (controller) {
                                                  return VideoPlayer(controller
                                                      .videoPlayerController
                                                      .value!);
                                                },
                                              ),

                                              // Loading Indicator when buffering
                                              if (controller
                                                  .videoPlayerController
                                                  .value!
                                                  .value
                                                  .isBuffering)
                                                Container(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 3,
                                                    ),
                                                  ),
                                                ),

                                              // Play/Pause Button (center) with GetBuilder
                                              GetBuilder<CourseVideoController>(
                                                id: 'video_controls',
                                                builder: (controller) {
                                                  if (!controller
                                                      .showControls.value) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Center(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: IconButton(
                                                        iconSize: 64,
                                                        icon: Icon(
                                                          controller
                                                                  .videoPlayerController
                                                                  .value!
                                                                  .value
                                                                  .isPlaying
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: controller
                                                            .togglePlayPause,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              // Bottom Controls: Progress bar & Time with GetBuilder
                                              GetBuilder<CourseVideoController>(
                                                id: 'video_controls',
                                                builder: (controller) {
                                                  if (!controller
                                                          .showControls.value ||
                                                      controller
                                                              .videoPlayerController
                                                              .value ==
                                                          null) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.7),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          ValueListenableBuilder<
                                                              VideoPlayerValue>(
                                                            valueListenable:
                                                                controller
                                                                    .videoPlayerController
                                                                    .value!,
                                                            builder: (context,
                                                                value, child) {
                                                              return Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    controller
                                                                        .formatDuration(
                                                                            value.position),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                  Text(
                                                                    controller
                                                                        .formatDuration(
                                                                            value.duration),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            AppFonts.opensansRegular),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          VideoProgressIndicator(
                                                            controller
                                                                .videoPlayerController
                                                                .value!,
                                                            allowScrubbing:
                                                                true,
                                                            colors:
                                                                const VideoProgressColors(
                                                              playedColor:
                                                                  Colors.red,
                                                              bufferedColor:
                                                                  Colors
                                                                      .white54,
                                                              backgroundColor:
                                                                  Colors
                                                                      .white24,
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              // Orientation Button (top right) with GetBuilder
                                              GetBuilder<CourseVideoController>(
                                                id: 'video_controls',
                                                builder: (controller) {
                                                  if (!controller
                                                      .showControls.value) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.screen_rotation,
                                                          color: Colors.white,
                                                          size: 26,
                                                        ),
                                                        onPressed: controller
                                                            .toggleOrientation,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Image.network(
                                            course.thumbnail ?? "",
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenHeight * 0.35
                                                : screenHeight * 0.7,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              ImageAssets.pythonIcon,
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenHeight * 0.35
                                                  : screenHeight * 0.7,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),

                          // Course Title Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title ?? 'No Title',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.opensansRegular,
                                    height: 1.3,
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.deepPurpleAccent
                                          .withOpacity(0.2),
                                      child: Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        course.creator!.name ??
                                            'Unknown Creator',
                                        style: TextStyle(
                                          fontFamily: AppFonts.opensansRegular,
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            course.ratings!.avgRating!
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.play_circle_outline,
                                              color: Colors.blue, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${course.sections!.fold(0, (sum, section) => sum + section.lessons!.length)} Lessons',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    GetBuilder<CourseVideoController>(
                      builder: (controller) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          labelStyle: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          controller: controller.tabController,
                          isScrollable: false,
                          labelColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          unselectedLabelColor: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.5),
                          indicatorColor: Colors.deepPurpleAccent,
                          indicatorWeight: 3,
                          indicatorPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          tabs: [
                            Tab(
                              text:
                                  'Playlist (${course.sections!.fold(0, (sum, section) => sum + section.lessons!.length)})',
                            ),
                            const Tab(text: 'Description'),
                            const Tab(text: 'Review'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: GetBuilder<CourseVideoController>(
              builder: (controller) => TabBarView(
                controller: controller.tabController,
                children: [
                  // Playlist Tab
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      ...course.sections!.asMap().entries.expand((entry) {
                        final sectionIndex = entry.key;
                        final section = entry.value;
                        return [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              section.title ?? 'No title',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                          ),
                          ...section.lessons!
                              .asMap()
                              .entries
                              .map((lessonEntry) {
                            final lessonIndex = lessonEntry.key;
                            final lesson = lessonEntry.value;
                            final globalIndex = course.sections!
                                    .sublist(0, sectionIndex)
                                    .fold(0,
                                        (sum, s) => sum + s.lessons!.length) +
                                lessonIndex;
                            final isCompleted = controller.courseProgress.value
                                    ?.progress?.completedLessons
                                    ?.any((cl) =>
                                        cl.lessonId == lesson.id &&
                                        cl.isCompleted == true) ??
                                controller.allLessons[globalIndex].isCompleted;

                            return playlistItem(
                              context,
                              lesson,
                              isCompleted!,
                              () => controller.playLesson(lesson, globalIndex),
                              controller.isCourseSubmitted.value || isCompleted
                                  ? null
                                  : (lesson.contentType == 'video'
                                      ? () => controller.submitLesson(lesson)
                                      : () => controller.playLesson(
                                          lesson, globalIndex)),
                            );
                          }),
                        ];
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),

                  // Description Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurpleAccent.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            course.description ?? 'No Description',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 15,
                              height: 1.6,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Review Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurpleAccent.withOpacity(0.1),
                                Colors.blueAccent.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Rate Your Experience',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course.title ?? '',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.7),
                                  fontSize: 14,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 20),
                              Obx(() => Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: InkWell(
                                          onTap: () => controller
                                              .updateRating(index + 1),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              index <
                                                      controller
                                                          .selectedRating.value
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: screenWidth * 0.09,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Share Your Thoughts',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.deepPurpleAccent.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: controller.reviewTextController,
                            maxLines: 5,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Tell us about your experience with this course...',
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withOpacity(0.5),
                                fontFamily: AppFonts.opensansRegular,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            onChanged: controller.updateReviewText,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.deepPurpleAccent,
                                  Colors.purpleAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.deepPurpleAccent.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: controller.isSubmittingReview.value
                                  ? null
                                  : () => controller
                                      .submitReview(course.id.toString()),
                              child: controller.isSubmittingReview.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Submit Review',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget playlistItem(
    BuildContext context,
    lesson,
    bool isCompleted,
    VoidCallback onTap,
    VoidCallback? onAction,
  ) {
    IconData icon;
    Color iconColor;
    switch (lesson.contentType) {
      case 'video':
        icon = Icons.play_circle_filled;
        iconColor = Colors.red;
        break;
      case 'quiz':
        icon = Icons.quiz;
        iconColor = Colors.orange;
        break;
      case 'text':
        icon = Icons.article;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.play_circle_filled;
        iconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        title: Text(
          lesson.title ?? 'No Title Available',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            stripHtmlTags(lesson.textContent ?? 'No description available'),
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.6),
              fontSize: 13,
              fontFamily: AppFonts.opensansRegular,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: isCompleted
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.deepPurpleAccent,
                      Colors.purpleAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onAction,
                  child: Text(
                    lesson.contentType == 'video' ? 'Submit' : 'Open',
                    style: const TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
        onTap: onTap,
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
