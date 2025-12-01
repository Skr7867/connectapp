import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/response/status.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/component/round_button.dart';
import '../../../res/custom_widgets/responsive_padding.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/CREATORPANEL/DeleteCourse/delete_course_controller.dart';
import '../../../view_models/CREATORPANEL/GetAllCreatorCourses/get_all_creater_courses_controller.dart';
import '../CreatorCourses/dialog_box.dart';

class CourseManagementScreen extends StatelessWidget {
  const CourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final controller = Get.put(GetAllCreatorCoursesController());
    final deleteCourseController = Get.put(DeleteCourseController());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'Course Management',
        centerTitle: false,
        actions: [
          Padding(
            padding: ResponsivePadding.customPadding(context, right: 5),
            child: Row(
              children: [
                RoundButton(
                  width: screenWidth * 0.24,
                  height: screenHeight * 0.04,
                  buttonColor: AppColors.blueColor,
                  title: 'Create Course',
                  fontSize: 11,
                  onPress: () => Get.toNamed(RouteName.createCourseScreen),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Obx(() {
          switch (controller.rxRequestStatus.value) {
            case Status.LOADING:
              return const Center(child: CircularProgressIndicator());
            case Status.ERROR:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.error.value.isEmpty
                          ? 'Failed to load courses'
                          : controller.error.value,
                      style: const TextStyle(
                          color: Colors.red,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                    const SizedBox(height: 10),
                    RoundButton(
                      // width: screenWidth * 0.3,
                      height: screenHeight * 0.04,
                      buttonColor: AppColors.greenColor,
                      title: 'Create Your First Course ',
                      fontSize: 10,
                      onPress: () => Get.toNamed(RouteName.createCourseScreen),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.refreshApi(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case Status.COMPLETED:
              if (controller.creatorCourses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No courses found',
                        style: TextStyle(
                            color: Colors.red,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      const SizedBox(height: 10),
                      // ElevatedButton(
                      //   onPressed: () => controller.refreshApi(),
                      //   child: const Text('Retry'),
                      // ),
                      RoundButton(
                        height: screenHeight * 0.04,
                        buttonColor: AppColors.greenColor,
                        title: 'Create Your First Course ',
                        fontSize: 10,
                        onPress: () =>
                            Get.toNamed(RouteName.createCourseScreen),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.creatorCourses.length,
                      itemBuilder: (context, int index) {
                        final course = controller.creatorCourses[index];
                        final tags = course.tags ?? [];
                        final displayedTags = tags.take(2).toList();
                        final remainingTagsCount =
                            tags.length > 2 ? tags.length - 2 : 0;
                        return Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.greyColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: course.thumbnail != null
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                        ),
                                        child: Image.network(
                                          course.thumbnail!,
                                          height: 240,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            ImageAssets.javaIcon,
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        ImageAssets.javaIcon,
                                        width: 50,
                                        height: 50,
                                      ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat(' d MMM yyyy h:mm a')
                                              .format(DateTime.parse(
                                                  course.createdAt.toString())),
                                          style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color),
                                        ),
                                        SizedBox(width: screenWidth * 0.05),
                                        PopupMenuButton<String>(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          shadowColor: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            size: 20,
                                          ),
                                          offset: Offset(0, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                        fontFamily: AppFonts
                                                            .opensansRegular,
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline,
                                                      size: 18,
                                                      color:
                                                          AppColors.redColor),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        fontFamily: AppFonts
                                                            .opensansRegular,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.redColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'createGroup',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.people_alt_outlined,
                                                    size: 18,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Create Group',
                                                    style: TextStyle(
                                                        fontFamily: AppFonts
                                                            .opensansRegular,
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'share',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.share,
                                                    size: 18,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Share',
                                                    style: TextStyle(
                                                        fontFamily: AppFonts
                                                            .opensansRegular,
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'addsection',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.people_alt_outlined,
                                                    size: 18,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Add Section',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: AppFonts
                                                            .opensansRegular,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (String value) async {
                                            switch (value) {
                                              case 'edit':
                                                final result =
                                                    await Get.toNamed(
                                                  RouteName.editCourseScreen,
                                                  arguments: controller
                                                      .creatorCourses[index],
                                                );

                                                if (result == true) {
                                                  controller.refreshApi();
                                                }

                                                break;
                                              case 'addsection':
                                                Get.toNamed(
                                                    RouteName
                                                        .createCourseSectionScreen,
                                                    arguments: {
                                                      'courseId': course.sId,
                                                    });
                                                break;
                                              case 'delete':
                                                if (course.sId == null) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Course ID is missing.')),
                                                  );
                                                  break;
                                                }

                                                deleteCourseController
                                                    .isDeleting.value = true;

                                                await deleteCourseController
                                                    .deleteCourse(course.sId!);

                                                deleteCourseController
                                                    .isDeleting.value = false;

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Delete selected')),
                                                );
                                                break;

                                              case 'createGroup':
                                                showCreateGroupDialog(
                                                    context, course.sId ?? '');

                                                break;
                                              case 'share':
                                                Utils.toastMessageCenter(
                                                    'It will Work after app deploy on playstor');

                                                break;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      course.title ?? 'No Title',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: AppFonts.opensansRegular,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      textAlign: TextAlign.start,
                                      course.description ?? 'No Description',
                                      style: TextStyle(
                                        fontFamily: AppFonts.opensansRegular,
                                        color: AppColors.textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6),
                                    // Tags
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        ...displayedTags
                                            .map((tag) => _Tag(tag)),
                                        if (remainingTagsCount > 0)
                                          _Tag("+$remainingTagsCount more"),
                                      ],
                                    ),

                                    SizedBox(height: 12),

                                    // Stats
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: "Perfect Quiz: ",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                    fontFamily: AppFonts
                                                        .opensansRegular),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        course.xpPerPerfectQuiz !=
                                                                null
                                                            ? course
                                                                .xpPerPerfectQuiz
                                                                .toString()
                                                            : '0',
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            RichText(
                                              text: TextSpan(
                                                text: "XP Start: ",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                    fontFamily: AppFonts
                                                        .opensansRegular),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        course.xpOnStart != null
                                                            ? course.xpOnStart
                                                                .toString()
                                                            : '0',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 19),
                                        // Right Column
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: "Completion: ",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                    fontFamily: AppFonts
                                                        .opensansRegular),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        course.xpOnCompletion !=
                                                                null
                                                            ? course
                                                                .xpOnCompletion
                                                                .toString()
                                                            : '0',
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            RichText(
                                              text: TextSpan(
                                                text: "XP End: ",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                    fontFamily: AppFonts
                                                        .opensansRegular),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        course.xpOnCompletion !=
                                                                null
                                                            ? course
                                                                .xpOnCompletion
                                                                .toString()
                                                            : '0',
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 16),

                                    // View details button and avatar
                                    Padding(
                                      padding: ResponsivePadding.customPadding(
                                          context,
                                          right: 3),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // RoundButton(
                                          //   fontSize: 13,
                                          //   height: 35,
                                          //   width: 120,
                                          //   buttonColor: AppColors.blueColor,
                                          //   title: 'View Details',
                                          //   onPress: () {},
                                          // ),
                                          SizedBox(width: screenWidth * 0.06),
                                          Text(
                                            course.coins != null
                                                ? course.coins.toString()
                                                : '0',
                                            style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.orangeAccent),
                                          ),
                                          SizedBox(width: 3),
                                          Image.asset(
                                            ImageAssets.coins,
                                            height: 20,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      })
                ],
              );
          }
        }),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: AppFonts.opensansRegular,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
      ),
      backgroundColor: AppColors.blackColor,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide.none,
      ),
    );
  }
}
