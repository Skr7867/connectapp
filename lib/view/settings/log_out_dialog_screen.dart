import 'dart:developer';

import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/routes/routes_name.dart';
import '../../res/color/app_colors.dart';
import '../../res/fonts/app_fonts.dart';
import '../../view_models/controller/logout/log_out_controller.dart';

void showLogoutDialog(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;
  final LogoutController logoutController = Get.put(LogoutController());

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(
        "logout".tr,
        style: TextStyle(
          color: AppColors.blackColor,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.opensansRegular,
        ),
      ),
      content: Text(
        "sure_logout".tr,
        style: TextStyle(
          fontFamily: AppFonts.opensansRegular,
          color: AppColors.blackColor,
        ),
      ),
      actions: [
        // ---- Cancel Button ----
        SizedBox(
          width: screenWidth * 0.2,
          height: screenHeight * 0.05,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueShade,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "no".tr,
              style: TextStyle(
                color: AppColors.whiteColor,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          ),
        ),

        SizedBox(width: screenWidth * 0.01),

        // ---- Confirm Logout Button ----
        Obx(() {
          return SizedBox(
            width: screenWidth * 0.3,
            height: screenHeight * 0.05,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: logoutController.loading.value
                    ? Colors.grey
                    : AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: logoutController.loading.value
                  ? null
                  : () {
                      // async call wrapped in sync function
                      Navigator.of(ctx).pop();
                      _handleLogout(logoutController);
                    },
              child: logoutController.loading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "yes".tr,
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
            ),
          );
        }),
      ],
    ),
  );
}

Future<void> _handleLogout(LogoutController logoutController) async {
  bool success = await logoutController.logout();
  if (success) {
    log('Logout sucessfull');
    Get.offAllNamed(RouteName.loginScreen);
  } else {
    Utils.snackBar(
      "Logout failed, please try again.",
      "Failed",
    );
  }
}
