// ignore_for_file: deprecated_member_use

import 'package:connectapp/res/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../data/response/status.dart';
import '../../../../res/fonts/app_fonts.dart';
import '../../../../view_models/CREATORPANEL/CreatorProfile/creator_profile_controller.dart';

class CreatorCourseProgressWidget extends StatelessWidget {
  const CreatorCourseProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // Orientation orientation = MediaQuery.of(context).orientation;
    final CreatorProfileController profileController =
        Get.put(CreatorProfileController());

    return Obx(() {
      if (profileController.rxRequestStatus.value == Status.LOADING) {
        return const Center(child: CircularProgressIndicator());
      } else if (profileController.rxRequestStatus.value == Status.ERROR) {
        return Center(child: Text(profileController.error.value));
      }

      final stats = profileController.creatorList.value.stats;
      return Column(
        children: [
          Wrap(
            spacing: screenWidth * 0.02,
            runSpacing: 17,
            children: [
              _badge(
                  "Total Courses",
                  context,
                  stats?.totalCourses.toString() ?? '0',
                  icon: PhosphorIconsFill.bookOpenText,
                  'Your Total Courses'),
              _badge(
                  "Total Enrolled",
                  context,
                  stats?.totalEnrolledUsers.toString() ?? '0',
                  icon: PhosphorIconsFill.users,
                  'Your Total Enrolled Courses'),
              _badge(
                  "Total Groups",
                  context,
                  stats?.totalGroups.toString() ?? '0',
                  icon: PhosphorIconsFill.chartLine,
                  'Your Total Groups'),
              _badge(
                "Average Rating",
                context,
                profileController.creatorList.value.stats?.averageRating
                        .toString() ??
                    '0',
                icon: PhosphorIconsFill.star,
                "Your Ratings",
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _badge(
      String label, BuildContext context, String value, String subtitile,
      {required IconData icon}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
      width: orientation == Orientation.portrait
          ? screenWidth * 0.38
          : screenWidth * 0.2,
      height: orientation == Orientation.portrait
          ? screenHeight * 0.23
          : screenHeight * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFamily: AppFonts.opensansRegular,
            ),
            textAlign: TextAlign.center,
          ),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              icon,
              color: AppColors.blueColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: AppFonts.opensansRegular,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitile,
            style: TextStyle(
              color: AppColors.greyColor,
              fontSize: 12,
              fontFamily: AppFonts.opensansRegular,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
