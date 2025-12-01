import 'package:flutter/material.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/listitem/list_item.dart';

class UpcomingEventWidget extends StatelessWidget {
  const UpcomingEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: Container(
        height: orientation == Orientation.portrait
            ? screenHeight * 0.27
            : screenHeight * 0.38,
        width: screenWidth * 0.93,
        decoration: BoxDecoration(
          color: AppColors.textfieldColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, int index) {
            return Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: screenHeight * 0.03),
                ListTile(
                  leading: Container(
                    margin: EdgeInsets.all(4),
                    height: orientation == Orientation.portrait
                        ? screenHeight * 0.09
                        : screenHeight * 0.13,
                    width: screenWidth * 0.12,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.courseButtonColor),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Apr',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                          ),
                          Text(
                            '29',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.opensansRegular,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventTitle[index],
                        style: TextStyle(
                            fontSize: 17,
                            color: AppColors.whiteColor,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      Text(
                        eventSubtitle[index],
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.whiteColor,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      // if (index == 0) {
                      //   Get.toNamed(RouteName.quizScreen);
                      // }
                    },
                    icon: Icon(Icons.arrow_forward_ios_outlined,
                        color: AppColors.whiteColor),
                  ),
                ),
                if (index != recentLeadingIcon.length - 2)
                  Divider(
                    color: Colors.white24,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
