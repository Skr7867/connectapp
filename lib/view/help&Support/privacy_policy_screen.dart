import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'privacy_policy'.tr,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 3),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'x_p'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'x_p_desc1'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'x_p_desc2'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'x_p_desc3'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'information1'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'information2'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'information3'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'information4'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'data_storage'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'data_storage1'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'data_storage2'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'data_storage3'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'achievement'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'achievement1'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  textAlign: TextAlign.justify,
                  'achievement2'.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
