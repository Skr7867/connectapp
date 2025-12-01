import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';

class StreakExploreScreen extends StatelessWidget {
  const StreakExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Get.put(UserProfileController());
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    // Map abbreviated day names to full names for activeDaysInWeek comparison
    final dayMapping = {
      'Sun': 'Sunday',
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Streak Dashboard',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: Container(
                  height: orientation == Orientation.portrait
                      ? screenHeight * 0.28
                      : screenHeight * 0.42,
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: ResponsivePadding.symmetricPadding(
                          context,
                          horizontal: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  PhosphorIconsFill.fire,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  'Streak',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                ),
                              ],
                            ),
                            Obx(() {
                              final user = userData.userList.value;

                              return Text(
                                '${user.maxStreak ?? 0} This Week',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        height: orientation == Orientation.portrait
                            ? screenHeight * 0.1
                            : screenHeight * 0.19,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, int index) {
                            final days = [
                              'Sun',
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat'
                            ];

                            final fullDayName = dayMapping[days[index]] ?? '';
                            return SizedBox(
                              width: orientation == Orientation.portrait
                                  ? screenWidth * 0.13
                                  : screenWidth * 0.13,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    days[index],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontSize: 14,
                                      fontFamily: AppFonts.opensansRegular,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Obx(() {
                                    final user = userData.userList.value;
                                    final activeDays =
                                        user.activeDaysInWeek ?? [];

                                    return Center(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 7),
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              activeDays.contains(fullDayName)
                                                  ? Colors.deepOrange
                                                  : Colors.grey,
                                        ),
                                        child: const Icon(
                                          PhosphorIconsFill.fire,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(
                        endIndent: 10,
                        indent: 10,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // TopLearnerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
