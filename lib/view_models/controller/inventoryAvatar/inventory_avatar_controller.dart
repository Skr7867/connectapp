import 'package:get/get.dart';
import 'package:connectapp/models/InventoryAvatar/inventory_avatar_model.dart';
import 'package:connectapp/repository/InventoryAvatar/inventory_avatar_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class InventoryAvatarController extends GetxController {
  final _api = InventoryAvatarRepository();
  final _prefs = UserPreferencesViewmodel();

  final RxList<String> selectedAvatars = <String>[].obs;

  var isLoading = false.obs;
  var inventoryAvatarModel = Rxn<InventoryAvatarModel>();

  Future<void> fetchInventoryAvatars() async {
    try {
      isLoading.value = true;

      final token = await _prefs.getToken();
      if (token == null) {
        isLoading.value = false;
        return;
      }

      final response = await _api.inventoryAvatar(token);
      inventoryAvatarModel.value = response;
    } finally {
      isLoading.value = false;
    }
  }
}
