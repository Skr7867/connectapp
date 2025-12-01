import 'package:get/get.dart';
import '../../../repository/EditCollection/edit_collection_repository.dart';
import '../../../utils/utils.dart';

class EditAvatarsCollectionController extends GetxController {
  final EditCollectionRepository _editAvatarCollectionRepository =
      EditCollectionRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Method to update avatar
  Future<bool> editCollection({
    required String collectionId,
    required String name,
    required String description,
    required int coins,
    required bool isPublished,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> payload = {
        'name': name,
        'description': description,
        'coins': coins,
        'isPublished': isPublished
      };

      final response = await _editAvatarCollectionRepository.editCollection(
          collectionId, payload);

      if (response != null && response['success'] == true) {
        Utils.snackBar("Collection updated successfully!", "Success");
        return true;
      } else {
        errorMessage.value = response?['message'] ??
            "Failed to update collection: Unknown error";
        Utils.snackBar(errorMessage.value, 'Success');
        return false;
      }
    } catch (e) {
      errorMessage.value = "Failed to update avatar collection: $e";
      Utils.snackBar(errorMessage.value, "Error");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
