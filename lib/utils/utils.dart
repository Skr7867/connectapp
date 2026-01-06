import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../res/color/app_colors.dart';

class Utils {
  static void fieldFocusChanged(
      BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.blackColor,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static toastMessageCenter(String message) {
    Fluttertoast.showToast(
      textColor: AppColors.whiteColor,
      msg: message,
      backgroundColor: AppColors.greyColor,
      gravity: ToastGravity.CENTER,
    );
  }

  static void snackBar(dynamic message, String title) {
    String displayMessage;
    if (message is String) {
      displayMessage = message;
    } else if (message is Map) {
      displayMessage = message['text']?.toString() ?? message.toString();
    } else {
      displayMessage = message?.toString() ?? 'Unknown error';
    }

    Get.snackbar(
      title,
      displayMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: title == 'Success' ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }
}
