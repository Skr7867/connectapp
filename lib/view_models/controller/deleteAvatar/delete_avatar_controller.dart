import 'package:get/get.dart';
import 'package:connectapp/utils/utils.dart';
import '../../../repository/DeleteAvatar/delete_avatar_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class DeleteAvatarController extends GetxController {
  final DeleteAvatarRepository _deleteAvatarRepository =
      DeleteAvatarRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<bool> deleteAvatar(String avatarId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // ✅ Get token
      final token = await _prefs.getToken();
      if (token == null) {
        errorMessage.value = 'Unauthorized: No token found';
        Utils.snackBar(errorMessage.value, 'Error');
        return false;
      }

      // ✅ Call repo
      final response =
          await _deleteAvatarRepository.deleteAvatar(avatarId, token);

      if (response != null && response['success'] == true) {
        Utils.snackBar('Avatar deleted successfully!', 'Success');
        return true;
      } else {
        errorMessage.value =
            response?['message'] ?? 'Failed to delete avatar: Unknown error';
        Utils.snackBar(errorMessage.value, 'Success');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete avatar: $e';
      Utils.snackBar(errorMessage.value, 'Error');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
