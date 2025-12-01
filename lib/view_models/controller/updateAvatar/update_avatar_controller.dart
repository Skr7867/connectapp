import 'package:get/get.dart';
import '../../../repository/UpdateAvatar/update_avatar_repository.dart';
import '../../../utils/utils.dart';

class UpdateAvatarController extends GetxController {
  final UpdateAvatarRepository _updateAvatarRepository =
      UpdateAvatarRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Method to update avatar
  Future<bool> updateAvatar({
    required String avatarId,
    required String name,
    required String description,
    required int coins,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> payload = {
        'name': name,
        'description': description,
        'coins': coins,
      };

      final response =
          await _updateAvatarRepository.updateAvatar(avatarId, payload);

      if (response != null && response['success'] == true) {
        Utils.snackBar("Avatar updated successfully!", "Success");
        return true;
      } else {
        errorMessage.value =
            response?['message'] ?? "Failed to update avatar: Unknown error";
        Utils.snackBar(errorMessage.value, 'Success');
        return false;
      }
    } catch (e) {
      errorMessage.value = "Failed to update avatar: $e";
      Utils.snackBar(errorMessage.value, "Error");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
