import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/changepassword/change_password_controller.dart';

class ChangePaswordScreen extends StatelessWidget {
  ChangePaswordScreen({super.key});
  final passwordVm = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'change_password'.tr,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Padding(
          padding: ResponsivePadding.customPadding(context, left: 4, right: 4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.2),
                Text(
                  'change_password'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                  controller: passwordVm.oldPasswordController.value,
                  isPassword: true,
                  borderRadius: 25,
                  hintText: 'enter_old_password'.tr,
                  hintTextColor: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: passwordVm.newPasswordController.value,
                  isPassword: true,
                  borderRadius: 25,
                  hintText: 'enter_new_password'.tr,
                  hintTextColor: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                SizedBox(height: screenHeight * 0.08),
                RoundButton(
                  buttonColor: AppColors.courseButtonColor,
                  width: screenWidth * 0.9,
                  title: 'submit'.tr,
                  onPress: () {
                    Get.toNamed(RouteName.settingScreen);
                    Utils.snackBar('password_change'.tr, 'sucess'.tr);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
