import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../res/custom_widgets/custome_appbar.dart';
import '../../res/custom_widgets/custome_textfield.dart';
import '../../res/custom_widgets/responsive_padding.dart';
import '../../res/fonts/app_fonts.dart';
import '../../view_models/controller/editprofilecontroller/edit_profile_controller.dart';
import '../../view_models/controller/userName/user_name_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});
  final EditProfileController _editProfileController =
      Get.put(EditProfileController());
  final _userName = Get.put(UserNameController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // Sync UserNameController with userProfileController's username
    _userName.username.value =
        _editProfileController.userNameController.value.text;

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'edit_profile'.tr,
      ),
      body: Container(
        height: screenHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          padding: ResponsivePadding.customPadding(context,
              top: 2, left: 3, right: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                'display_name'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              CustomTextField(
                controller: _editProfileController.nameController.value,
                hintText: 'edit_name'.tr,
                hintTextColor: Theme.of(context).textTheme.bodyLarge?.color,
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'email'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              SizedBox(
                height: 50,
                child: TextFormField(
                  controller: _editProfileController.emailController.value,
                  decoration: InputDecoration(
                    labelText: _editProfileController
                            .emailController.value.text.isEmpty
                        ? 'Email'
                        : null,
                    labelStyle: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: AppColors.greyColor),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteName.updatEmailPassword);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 17),
                        child: Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: AppFonts.opensansRegular),
                  keyboardType: TextInputType.emailAddress,
                  enabled: true,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'user_name'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              CustomTextField(
                controller: _editProfileController.userNameController.value,
                onChanged: _userName.updateUsername,
                hintText: 'enter_username'.tr,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_]*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_username'.tr;
                  }
                  if (_userName.isUsernameAvailable.value == false) {
                    return 'username_taken'.tr;
                  }
                  if (value.length < 3) {
                    return 'username_too_short'.tr;
                  }
                  return null;
                },
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              SizedBox(height: screenHeight * 0.01),
              Obx(() {
                if (_userName.isCheckingUsername.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      height: 10,
                      width: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  );
                }
                final isAvailable = _userName.isUsernameAvailable.value;
                if (isAvailable == null) {
                  return Padding(
                    padding:
                        ResponsivePadding.customPadding(context, right: 30),
                    child: Text(
                      'enter_at_least_3_characters'.tr,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: ResponsivePadding.customPadding(context, right: 66),
                  child: Text(
                    isAvailable ? 'username_available'.tr : 'UserName taken',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                );
              }),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'bio'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              CustomTextField(
                controller: _editProfileController.bioController.value,
                hintText: 'Bio Link is not available',
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'instagram'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              CustomTextField(
                controller: _editProfileController.instagramController.value,
                hintText: 'Instagram Link is not available',
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'twitter'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              CustomTextField(
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                controller: _editProfileController.twitterController.value,
                hintText: 'Twitter Link is not available',
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'linkedin'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              CustomTextField(
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                controller: _editProfileController.linkedinController.value,
                hintText: 'LinkedIn Link is not available',
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'website'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              CustomTextField(
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                controller: _editProfileController.websiteController.value,
                hintText: 'Website Link is not available',
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 30),
              Center(
                child: Obx(() => RoundButton(
                      buttonColor: AppColors.blackColor,
                      title: 'update'.tr,
                      loading: _editProfileController.isLoading.value,
                      onPress: _editProfileController.updateProfile,
                    )),
              ),
              SizedBox(height: screenHeight * 0.07),
            ],
          ),
        ),
      ),
    );
  }
}
