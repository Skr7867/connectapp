import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/response/status.dart';
import '../../../view_models/CREATORPANEL/GetAllCreatorCourses/get_all_creater_courses_controller.dart';
import 'dialog_box.dart';

class CreatorCourseScreen extends StatelessWidget {
  const CreatorCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final controller = Get.put(GetAllCreatorCoursesController());

    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: true,
        title: 'My Created Courses',
        actions: [
          Padding(
            padding: ResponsivePadding.customPadding(context, right: 8),
            child: Row(
              children: [
                RoundButton(
                  width: screenWidth * 0.3,
                  height: screenHeight * 0.04,
                  buttonColor: AppColors.blueColor,
                  title: 'New Course',
                  fontSize: 10,
                  onPress: () => Get.toNamed(RouteName.createCourseScreen),
                ),
              ],
            ),
          )
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
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    // ElevatedButton(
                    //   onPressed: () => controller.refreshApi(),
                    //   child: const Text('Retry'),
                    // ),
                    RoundButton(
                      // width: screenWidth * 0.3,
                      height: screenHeight * 0.04,
                      buttonColor: AppColors.greenColor,
                      title: 'Create Your First Course ',
                      fontSize: 10,
                      onPress: () => Get.toNamed(RouteName.createCourseScreen),
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
                      const Text(
                        'No courses found.',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => controller.refreshApi(),
                        child: const Text('Retry'),
                      ),
                      RoundButton(
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.04,
                        buttonColor: AppColors.blueColor,
                        title: 'New Course',
                        fontSize: 10,
                        onPress: () =>
                            Get.toNamed(RouteName.createCourseScreen),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.creatorCourses.length,
                      itemBuilder: (context, int index) {
                        final course = controller.creatorCourses[index];
                        return Container(
                          margin: const EdgeInsets.all(8),
                          width: screenWidth * 0.81,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.greyColor.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.03),
                              ListTile(
                                leading: course.thumbnail != null
                                    ? Image.network(
                                        course.thumbnail!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          ImageAssets.javaIcon,
                                          width: 50,
                                          height: 50,
                                        ),
                                      )
                                    : Image.asset(
                                        ImageAssets.javaIcon,
                                        width: 50,
                                        height: 50,
                                      ),
                                title: Text(
                                  course.title ?? 'No Title',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: AppFonts.opensansRegular,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  course.description ?? 'No Description',
                                  style: TextStyle(
                                    fontFamily: AppFonts.opensansRegular,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: screenWidth * 0.8,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.greyColor.withOpacity(0.4),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.greyColor.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: ResponsivePadding.symmetricPadding(
                                      context,
                                      horizontal: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: screenHeight * 0.02),
                                          Text(
                                            'Status :',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Review :',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Created :',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Action :',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                        ],
                                      ),
                                      SizedBox(width: screenWidth * 0.1),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: screenHeight * 0.02),
                                          Text(
                                            course.isPublished == true
                                                ? 'Published'
                                                : 'Draft',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: course.isPublished == true
                                                  ? AppColors.greenColor
                                                  : AppColors.redColor,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            '${course.totalReviews ?? 0} Reviews',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            DateFormat('dd/MM/yyyy').format(
                                                DateTime.parse(course.createdAt
                                                    .toString())),
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                              color: AppColors.redColor,
                                            ),
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.004),
                                          InkWell(
                                            onTap: () {
                                              showCreateGroupDialog(
                                                  context, course.sId ?? '');
                                            },
                                            child: Text(
                                              'Create Group',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                                color: AppColors.blueColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),
                            ],
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
