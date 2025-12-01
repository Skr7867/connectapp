import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/CREATORPANEL/DeleteLession/delete_lession_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import '../../../data/response/status.dart';
import '../../../view_models/CREATORPANEL/CreateCourseSection/create_course_section_controller.dart';
import '../../../view_models/CREATORPANEL/DeleteCourseSection/delete_course_section_controller.dart';
import '../../../view_models/CREATORPANEL/EditCourse/edit_course_section_controller.dart';
import '../../../view_models/CREATORPANEL/EditCourse/edit_lession_controller.dart';
import '../../../view_models/CREATORPANEL/GetAllCreatorCourseSection/get_all_creator_course_section_controller.dart';

class CreateCourseSectionScreen extends StatelessWidget {
  const CreateCourseSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String courseId = args['courseId']?.toString() ?? '';

    final courseController =
        Get.put(GetAllCreatorCourseSectionController(courseId: courseId));
    final deleteController = Get.put(DeleteCourseSectionController());
    final createController = Get.put(CreateCourseSectionController());
    final editController = Get.put(EditCourseSectionController());

    Get.put(EditLessionController());
    final isNavigating = false.obs;
    final deleteLessionController = Get.put(DeleteLessionController());

    // Function to show Add Section Dialog
    void showAddSectionDialog() {
      final TextEditingController titleController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.textfieldColor,
          title: Text(
            'Add New Section',
            style: TextStyle(
              color: AppColors.blackColor,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          content: CustomTextField(
            fontSize: 10,
            controller: titleController,
            textColor: AppColors.blackColor,
            hintText: 'Enter Title',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: AppColors.redColor,
                ),
              ),
            ),
            Obx(() => ElevatedButton(
                  onPressed: createController.isCreating.value
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final success = await createController
                              .createCourseSection(courseId, title);
                          if (success) {
                            titleController.clear();
                            Get.back();

                            await courseController.refreshApi();
                            courseController.creatorCourseSection.refresh();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    foregroundColor: AppColors.whiteColor,
                    minimumSize: Size(screenWidth * 0.3, screenHeight * 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 14,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    createController.isCreating.value ? 'Creating...' : 'Add',
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                )),
          ],
        ),
      );
    }

    // Function to show Edit Section Dialog
    void showEditSectionDialog(String sectionId, String currentTitle) {
      final TextEditingController titleController =
          TextEditingController(text: currentTitle);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          clipBehavior: Clip.antiAlias,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: AppColors.blueShade,
          title: Text(
            'Edit Section',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          content: CustomTextField(
            fontSize: 10,
            controller: titleController,
            textColor: Theme.of(context).textTheme.bodyLarge?.color,
            hintText: 'Enter Course Title',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: AppColors.redColor,
                ),
              ),
            ),
            Obx(() => ElevatedButton(
                  onPressed: editController.isUpdating.value
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final success = await editController
                              .updateCourseSection(courseId, sectionId, title);
                          if (success) {
                            titleController.clear();
                            Get.back();

                            await courseController.refreshApi();
                            courseController.creatorCourseSection.refresh();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    foregroundColor: AppColors.whiteColor,
                    minimumSize: Size(screenWidth * 0.3, screenHeight * 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 14,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    editController.isUpdating.value ? 'Updating...' : 'Update',
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                )),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'Create Your Course Section',
      ),
      body: Obx(() {
        switch (courseController.rxRequestStatus.value) {
          case Status.LOADING:
            return const Center(child: CircularProgressIndicator());
          case Status.ERROR:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    courseController.error.value,
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 16,
                      color: AppColors.redColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundButton(
                    buttonColor: AppColors.blackColor,
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.3,
                    title: 'Retry',
                    onPress: () async {
                      await courseController.refreshApi();
                    },
                  ),
                ],
              ),
            );
          case Status.COMPLETED:
            final course = courseController.creatorCourseSection.value;
            if (course == null) {
              return Center(
                  child: Text(
                'No course data found',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ));
            }

            return SingleChildScrollView(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.greyColor.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          course.title ?? 'Course Title',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 15,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        subtitle: Text(
                          'Manage Your Course Content and Structure',
                          style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 10,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        trailing: RoundButton(
                          height: screenHeight * 0.04,
                          width: screenWidth * 0.25,
                          fontSize: 10,
                          buttonColor: AppColors.blueColor,
                          title: 'Add Section',
                          onPress: showAddSectionDialog,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.greyColor.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Course Content',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                          ),
                          Divider(
                            color: AppColors.greyColor.withOpacity(0.4),
                          ),
                          if (course.sections != null &&
                              course.sections!.isNotEmpty)
                            Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: course.sections!.length,
                                  itemBuilder: (context, index) {
                                    final section = course.sections![index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.greyColor
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                            dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                          tilePadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                          collapsedIconColor:
                                              AppColors.redColor,
                                          maintainState: false,
                                          iconColor: AppColors.redColor,
                                          title: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    AppColors.blueColor,
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  section.title ??
                                                      'Section Title',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    fontFamily: AppFonts
                                                        .opensansRegular,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  if (section.sId == null) {
                                                    Get.snackbar('Error',
                                                        'Section ID is missing.');
                                                    return;
                                                  }
                                                  showEditSectionDialog(
                                                      section.sId!,
                                                      section.title ?? '');
                                                },
                                                icon: Icon(Icons.edit,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                    size: 18),
                                              ),
                                              Obx(() {
                                                return deleteController
                                                        .isDeleting.value
                                                    ? const SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.red,
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : IconButton(
                                                        onPressed: () async {
                                                          if (section.sId ==
                                                              null) {
                                                            Get.snackbar(
                                                                'Error',
                                                                'Section ID is missing.');
                                                            return;
                                                          }
                                                          final success =
                                                              await deleteController
                                                                  .deleteCourseSection(
                                                            courseId,
                                                            section.sId!,
                                                          );
                                                          if (success) {
                                                            await courseController
                                                                .refreshApi();
                                                            courseController
                                                                .creatorCourseSection
                                                                .refresh();
                                                          }
                                                        },
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                            size: 18),
                                                      );
                                              }),
                                            ],
                                          ),
                                          children: [
                                            ...?section.lessons
                                                ?.asMap()
                                                .entries
                                                .map(
                                              (entry) {
                                                final lessonIndex =
                                                    entry.key + 1;
                                                final lesson = entry.value;
                                                return Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColors
                                                            .greyColor
                                                            .withOpacity(0.4)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            AppColors.blueColor,
                                                        child: Text(
                                                          '${index + 1}.$lessonIndex',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              lesson.title ??
                                                                  'Lesson Title',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            if (lesson.description !=
                                                                    null &&
                                                                lesson
                                                                    .description!
                                                                    .isNotEmpty)
                                                              Text(
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                lesson
                                                                    .description!,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: AppColors
                                                                        .textColor),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.edit,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.color,
                                                            size: 16),
                                                        onPressed: () {
                                                          if (section.sId ==
                                                                  null ||
                                                              lesson.sId ==
                                                                  null) {
                                                            Get.snackbar(
                                                                'Error',
                                                                'Section or Lesson ID is missing.');
                                                            return;
                                                          }
                                                          Get.toNamed(
                                                            RouteName
                                                                .addLessionScreen,
                                                            arguments: {
                                                              'courseId':
                                                                  courseId,
                                                              'sectionId':
                                                                  section.sId,
                                                              'lessonId':
                                                                  lesson.sId,
                                                              'title': lesson
                                                                      .title ??
                                                                  '',
                                                              'description':
                                                                  lesson.description ??
                                                                      '',
                                                              'contentType':
                                                                  lesson.contentType ??
                                                                      'Text',
                                                              'textContent':
                                                                  lesson.textContent ??
                                                                      '',
                                                            },
                                                          )?.then((_) {
                                                            log('Calling refreshApi after editing lesson');
                                                            courseController
                                                                .refreshApi();
                                                            courseController
                                                                .creatorCourseSection
                                                                .refresh();
                                                          });
                                                        },
                                                      ),
                                                      Obx(() {
                                                        final isDeletingThis =
                                                            deleteLessionController
                                                                    .deletingLessonId
                                                                    .value ==
                                                                lesson.sId;

                                                        return isDeletingThis
                                                            ? const SizedBox(
                                                                height: 18,
                                                                width: 18,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Colors
                                                                      .red,
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                              )
                                                            : IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (section
                                                                          .sId ==
                                                                      null) {
                                                                    Get.snackbar(
                                                                        'Error',
                                                                        'Section ID is missing.');
                                                                    return;
                                                                  }
                                                                  final success =
                                                                      await deleteLessionController
                                                                          .deleteLession(
                                                                    courseId,
                                                                    section
                                                                        .sId!,
                                                                    lesson.sId
                                                                        .toString(),
                                                                  );
                                                                  if (success) {
                                                                    log('Calling refreshApi after deleting lesson');
                                                                    await courseController
                                                                        .refreshApi();
                                                                    courseController
                                                                        .creatorCourseSection
                                                                        .refresh();
                                                                  }
                                                                },
                                                                icon: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: AppColors
                                                                        .redColor,
                                                                    size: 18),
                                                              );
                                                      }),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, bottom: 10),
                                              child: Obx(() => TextButton.icon(
                                                    onPressed: isNavigating
                                                            .value
                                                        ? null
                                                        : () {
                                                            if (course.sId ==
                                                                    null ||
                                                                section.sId ==
                                                                    null) {
                                                              Get.snackbar(
                                                                  'Error',
                                                                  'Invalid course or section ID');
                                                              return;
                                                            }
                                                            isNavigating.value =
                                                                true;
                                                            Get.toNamed(
                                                              RouteName
                                                                  .addLessionScreen,
                                                              arguments: {
                                                                'courseId':
                                                                    course.sId,
                                                                'sectionId':
                                                                    section.sId,
                                                              },
                                                            )?.then((_) {
                                                              isNavigating
                                                                      .value =
                                                                  false;
                                                              log('Calling refreshApi after adding lesson');
                                                              courseController
                                                                  .refreshApi();
                                                              courseController
                                                                  .creatorCourseSection
                                                                  .refresh();
                                                            });
                                                          },
                                                    icon: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: AppColors
                                                            .blueColor),
                                                    label: Text(
                                                      'Add New Lesson',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: AppFonts
                                                            .opensansRegular,
                                                        color:
                                                            AppColors.blueColor,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          else
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'No sections available.',
                                style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
      }),
    );
  }
}
