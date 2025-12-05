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
    double screenWidth = MediaQuery.of(context).size.width;
    final CreatorProfileController profileController =
        Get.put(CreatorProfileController());

    return Obx(() {
      if (profileController.rxRequestStatus.value == Status.LOADING) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
          ),
        );
      } else if (profileController.rxRequestStatus.value == Status.ERROR) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIconsFill.warningCircle,
                  size: 48, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                profileController.error.value,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
            ],
          ),
        );
      }

      final stats = profileController.creatorList.value.stats;
      return Column(
        children: [
          Wrap(
            spacing: screenWidth * 0.02,
            runSpacing: 16,
            children: [
              _badge(
                "Total Courses",
                context,
                stats?.totalCourses.toString() ?? '0',
                icon: PhosphorIconsFill.bookOpenText,
                'Your Total Courses',
                gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              _badge(
                "Total Enrolled",
                context,
                stats?.totalEnrolledUsers.toString() ?? '0',
                icon: PhosphorIconsFill.users,
                'Your Total Enrolled Courses',
                gradient: const [Color(0xFF43e97b), Color(0xFF38f9d7)],
              ),
              _badge(
                "Total Groups",
                context,
                stats?.totalGroups.toString() ?? '0',
                icon: PhosphorIconsFill.chartLine,
                'Your Total Groups',
                gradient: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
              ),
              _badge(
                "Average Rating",
                context,
                profileController.creatorList.value.stats?.averageRating
                        .toString() ??
                    '0',
                icon: PhosphorIconsFill.star,
                "Your Ratings",
                gradient: const [Color(0xFFfa709a), Color(0xFFfee140)],
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _badge(
    String label,
    BuildContext context,
    String value,
    String subtitile, {
    required IconData icon,
    required List<Color> gradient,
  }) {
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient[0].withOpacity(0.08),
            gradient[1].withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gradient[0].withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: AppFonts.opensansRegular,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              fontFamily: AppFonts.opensansRegular,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitile,
            style: TextStyle(
              color: AppColors.greyColor,
              fontSize: 11,
              fontFamily: AppFonts.opensansRegular,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
