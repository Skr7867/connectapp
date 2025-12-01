import 'package:get/get.dart';

import '../../../repository/DeleteCollection/delete_collection_repository.dart';
import '../../../utils/utils.dart';
import '../userPreferences/user_preferences_screen.dart';

class DeleteAvatarsCollectionController extends GetxController {
  final DeleteCollectionRepository _deleteAvatarRepository =
      DeleteCollectionRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<bool> deleteAvatarCollection(String collectionId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get token
      final token = await _prefs.getToken();
      if (token == null) {
        errorMessage.value = 'Unauthorized: No token found';
        Utils.snackBar(errorMessage.value, 'Error');
        return false;
      }

      //Call repo
      final response =
          await _deleteAvatarRepository.deleteCollection(collectionId, token);

      if (response != null && response['success'] == true) {
        Utils.snackBar('Colleciton deleted successfully!', 'Success');
        return true;
      } else {
        errorMessage.value =
            response?['message'] ?? 'Failed to delete avatar: Unknown error';
        Utils.snackBar(errorMessage.value, 'Success');
        return false;
      }
    } catch (e) {
      errorMessage.value = '$e';
      Utils.snackBar(errorMessage.value, 'Info');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
