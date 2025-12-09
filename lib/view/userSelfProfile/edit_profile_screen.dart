import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../res/custom_widgets/custome_appbar.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;

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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: ResponsivePadding.customPadding(context,
              top: 2, left: 3, right: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // Profile Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blackColor,
                            AppColors.greyColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white70,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blackColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 35),

              // Personal Information Card
              _buildSectionCard(
                context,
                title: 'personal_info'.tr.isNotEmpty
                    ? 'personal_info'.tr
                    : 'Personal Information',
                icon: Icons.person_outline,
                children: [
                  _buildModernTextField(
                    context,
                    label: 'display_name'.tr,
                    controller: _editProfileController.nameController.value,
                    hintText: 'edit_name'.tr,
                    icon: Icons.badge_outlined,
                  ),
                  SizedBox(height: 20),
                  _buildEmailField(context),
                  SizedBox(height: 20),
                  _buildUsernameField(context),
                  SizedBox(height: 20),
                  _buildModernTextField(
                    context,
                    label: 'bio'.tr,
                    controller: _editProfileController.bioController.value,
                    hintText: 'Tell us about yourself',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                ],
              ),

              SizedBox(height: 25),

              // Social Links Card
              _buildSectionCard(
                context,
                title: 'social_links'.tr.isNotEmpty
                    ? 'social_links'.tr
                    : 'Social Links',
                icon: Icons.link,
                children: [
                  _buildModernTextField(
                    context,
                    label: 'instagram'.tr,
                    controller:
                        _editProfileController.instagramController.value,
                    hintText: 'instagram.com',
                    icon: Icons.camera_alt_outlined,
                  ),
                  SizedBox(height: 20),
                  _buildModernTextField(
                    context,
                    label: 'twitter'.tr,
                    controller: _editProfileController.twitterController.value,
                    hintText: 'twitter.com',
                    icon: Icons.flutter_dash_outlined,
                  ),
                  SizedBox(height: 20),
                  _buildModernTextField(
                    context,
                    label: 'linkedin'.tr,
                    controller: _editProfileController.linkedinController.value,
                    hintText: 'linkedin.com',
                    icon: Icons.work_outline,
                  ),
                  SizedBox(height: 20),
                  _buildModernTextField(
                    context,
                    label: 'website'.tr,
                    controller: _editProfileController.websiteController.value,
                    hintText: 'https://yourwebsite.com',
                    icon: Icons.language_outlined,
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Update Button
              Center(
                child: Obx(() => Container(
                      width: screenWidth * 0.85,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blackColor,
                            AppColors.blackColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _editProfileController.isLoading.value
                              ? null
                              : _editProfileController.updateProfile,
                          child: Center(
                            child: _editProfileController.isLoading.value
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'update'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.opensansRegular,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    )),
              ),

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontFamily: AppFonts.opensansRegular,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              prefixText: prefixText,
              prefixStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontFamily: AppFonts.opensansRegular,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'email'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _editProfileController.emailController.value,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              // hintText: 'your.email@example.com',
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontFamily: AppFonts.opensansRegular,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  Get.toNamed(RouteName.updatEmailPassword);
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.blackColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppFonts.opensansRegular,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'user_name'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _editProfileController.userNameController.value,
            onChanged: _userName.updateUsername,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_]*$')),
            ],
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'enter_username'.tr,
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontFamily: AppFonts.opensansRegular,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.alternate_email,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        SizedBox(height: 8),
        Obx(() {
          if (_userName.isCheckingUsername.value) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
              child: Row(
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Checking availability...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          final isAvailable = _userName.isUsernameAvailable.value;
          if (isAvailable == null) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    'enter_at_least_3_characters'.tr,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  isAvailable
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 16,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
                SizedBox(width: 6),
                Text(
                  isAvailable ? 'username_available'.tr : 'UserName taken',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
