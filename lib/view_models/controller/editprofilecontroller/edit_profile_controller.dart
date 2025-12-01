import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/UserLogin/user_login_model.dart';
import '../../../repository/UpdateProfile/update_profile_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../../../utils/utils.dart';
import '../userPreferences/user_preferences_screen.dart';
import '../profile/user_profile_controller.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController().obs;
  final emailController = TextEditingController().obs;
  final userNameController = TextEditingController().obs;
  final bioController = TextEditingController().obs;
  final instagramController = TextEditingController().obs;
  final twitterController = TextEditingController().obs;
  final linkedinController = TextEditingController().obs;
  final websiteController = TextEditingController().obs;

  var isLoading = false.obs;

  final UpdateProfileRepository _updateProfileRepository =
      UpdateProfileRepository();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  final UserProfileController userProfileController =
      Get.find<UserProfileController>();

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers with user data
    if (userProfileController.rxRequestStatus.value == Status.COMPLETED) {
      final user = userProfileController.userList.value;
      nameController.value.text = user.fullName ?? '';
      userNameController.value.text = user.username ?? '';
      bioController.value.text = user.bio ?? '';
      emailController.value.text = user.email ?? '';
      instagramController.value.text = user.socialLinks?.instagram ?? '';
      twitterController.value.text = user.socialLinks?.twitter ?? '';
      linkedinController.value.text = user.socialLinks?.linkedin ?? '';
      websiteController.value.text = user.socialLinks?.website ?? '';
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      final LoginResponseModel? userData = await _userPreferences.getUser();

      if (userData == null || userData.token.isEmpty) {
        Utils.snackBar(
          'Authentication Error',
          'No valid authentication token found. Please log in again.',
        );
        Get.offAllNamed(RouteName.loginScreen);
        return;
      }

      // Prepare the data to send to the backend
      final updateData = {
        'fullName': nameController.value.text.trim(),
        'username': userNameController.value.text.trim(),
        'bio': bioController.value.text.trim(),
        'email': emailController.value.text.trim(),
        'socialLinks': {
          'instagram': instagramController.value.text.trim(),
          'twitter': twitterController.value.text.trim(),
          'linkedin': linkedinController.value.text.trim(),
          'website': websiteController.value.text.trim(),
        },
      };

      final response = await _updateProfileRepository.updateProfile(
        updateData,
        userData.token,
      );

      if (response != null && response['success'] == true) {
        Utils.snackBar(
          response['message'] ?? 'Your changes have been saved successfully',
          'Success',
        );

        // Refresh user profile data
        userProfileController.userList();

        Get.offNamed(RouteName.profileScreen);
      } else {
        Utils.snackBar(
          response?['message'] ?? 'Failed to update profile',
          'Error',
        );
      }
    } catch (e) {
      Utils.snackBar(
        e,
        'Info',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.value.dispose();
    emailController.value.dispose();
    userNameController.value.dispose();
    bioController.value.dispose();
    instagramController.value.dispose();
    twitterController.value.dispose();
    linkedinController.value.dispose();
    websiteController.value.dispose();
    super.onClose();
  }
}
