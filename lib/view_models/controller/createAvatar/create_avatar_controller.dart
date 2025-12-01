import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import '../../../repository/CreateAvatar/create_avatar_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../userPreferences/user_preferences_screen.dart';

class CreateAvatarController extends GetxController {
  final CreateAvatarRepository _createAvatarRepository =
      CreateAvatarRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<bool> createAvatar({
    required String name,
    String? description,
    required String avatar2dUrl,
    required String avatar3dUrl,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _prefs.getToken();
      if (token == null) {
        errorMessage.value = 'Unauthorized: No token found';
        Utils.snackBar(errorMessage.value, 'Error');
        return false;
      }

      final Map<String, dynamic> payload = {
        'name': name,
        'description': description ?? '',
        'Avatar2dUrl': avatar2dUrl,
        'Avatar3dUrl': avatar3dUrl,
      };

      final response =
          await _createAvatarRepository.createAvatar(payload, token);

      if (response != null && response['success'] == true) {
        return true;
      } else {
        errorMessage.value =
            response?['message'] ?? 'Failed to create avatar: Unknown error';
        Utils.snackBar(
          errorMessage.value,
          'Success',
        );
        Get.toNamed(RouteName.inventoryAvatarScreen);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create avatar: $e';
      Utils.snackBar(
        errorMessage.value,
        'Error',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
