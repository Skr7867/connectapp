import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../res/assets/image_assets.dart';
import '../../res/routes/routes_name.dart';

class ForgetPasswordOtpVerification extends StatelessWidget {
  const ForgetPasswordOtpVerification({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 4),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.3),
              Center(
                child: Image.asset(
                  ImageAssets.lockIcon,
                  height: 200,
                  width: 200,
                ),
              ),
              Text(
                'Forget Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                textAlign: TextAlign.center,
                'Enter 6 - Digit OTP sent to your mobile number ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              CustomTextField(
                borderRadius: 25,
                fillColor: AppColors.textfieldColor,
                hintText: 'Verification code ',
              ),
              SizedBox(height: screenHeight * 0.02),
              RoundButton(
                width: screenWidth * 0.9,
                buttonColor: AppColors.courseButtonColor,
                title: 'Verify OTP',
                onPress: () {
                  // if (_formKey.currentState!.validate()) {
                  //   log(_signupVm.emailController.value.text.trim());
                  //   log(_signupVm.passwordController.value.text.trim());
                  //   Utils.toastMessageCenter('User register Sucessfully');
                  //   Get.toNamed(RouteName.loginScreen);
                  // }

                  Get.toNamed(RouteName.createNewPassword);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
