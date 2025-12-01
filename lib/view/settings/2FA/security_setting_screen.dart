import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SecuritySettingScreen extends StatelessWidget {
  const SecuritySettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'two_factor_authentication'.tr,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth * 0.85,
              height: screenHeight * 0.57,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'account_security'.tr,
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blackColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'two_factor_authentication'.tr,
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Row(
                        //   children: const [
                        //     Icon(Icons.warning, color: Colors.amber, size: 18),
                        //     SizedBox(width: 8),
                        //     Expanded(
                        //       child: Text(
                        //         'Two-Factor Authentication is Not Enabled',
                        //         style: TextStyle(color: Colors.white),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'enable_2fa'.tr,
                          style: TextStyle(
                              color: Colors.white70,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2C5A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.white70),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  'two_fa'.tr,
                                  style: TextStyle(
                                      fontFamily: AppFonts.opensansRegular,
                                      color: Colors.white70,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  RoundButton(
                      buttonColor: AppColors.blackColor,
                      width: screenWidth * 0.8,
                      title: 'enable'.tr,
                      onPress: () {
                        Get.toNamed(RouteName.twoFactorSetupScreen);
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
