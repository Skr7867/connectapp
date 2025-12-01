import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/listitem/list_item.dart';

class RecentAcitivityWidget extends StatelessWidget {
  const RecentAcitivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    return Center(
      child: Container(
        height: orientation == Orientation.portrait
            ? screenHeight * 0.37
            : screenHeight * 0.68,
        width: screenWidth * 0.93,
        decoration: BoxDecoration(
          color: AppColors.textfieldColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(recentLeadingIcon.length, (index) {
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      margin: EdgeInsets.all(4),
                      height: orientation == Orientation.portrait
                          ? screenHeight * 0.07
                          : screenHeight * 0.09,
                      width: orientation == Orientation.portrait
                          ? screenWidth * 0.12
                          : screenWidth * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: achievementColor[index].withOpacity(0.2),
                      ),
                      child: Center(
                        child: Icon(
                          recentLeadingIcon[index],
                          color: achievementColor[index],
                        ),
                      ),
                    ),
                    title: Text(
                      recentTitle[index],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                    subtitle: Text(
                      recentSubTitle[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.greyColor,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ),
                  if (index != recentLeadingIcon.length - 1)
                    Divider(
                      color: Colors.white24,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
