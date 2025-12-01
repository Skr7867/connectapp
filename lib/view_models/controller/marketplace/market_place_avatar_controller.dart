import 'package:get/get.dart';
import '../../../models/MarketPlaceAvatar/market_place_avatar_model.dart';
import '../../../repository/MarketPlace/market_place_avatar_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class MarketPlaceAvatarController extends GetxController {
  final MarketPlaceAvatarRepository _repository = MarketPlaceAvatarRepository();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var errorMessage = "".obs;

  // Store both original list and filtered list for avatars
  var allAvatars = <Avatars>[].obs;
  var avatars = <Avatars>[].obs;

  // Store both original list and filtered list for collections
  var allCollections = <Collections>[].obs;
  var collections = <Collections>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMarketPlaceAvatars();
  }

  Future<void> fetchMarketPlaceAvatars() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      String? token = await _userPreferences.getToken();

      if (token == null) {
        errorMessage.value = 'No token found. Please log in.';

        return;
      }

      final marketPlaceAvatarModel =
          await _repository.myMarketPlaceAvatar(token);

      // Handle avatars
      if (marketPlaceAvatarModel.marketplace?.avatars != null &&
          marketPlaceAvatarModel.marketplace!.avatars!.isNotEmpty) {
        allAvatars.value = marketPlaceAvatarModel.marketplace!.avatars!;
        avatars.value = allAvatars; // initialize with all avatars
      } else {
        allAvatars.clear();
        avatars.clear();
      }

      // Handle collections
      if (marketPlaceAvatarModel.marketplace?.collections != null &&
          marketPlaceAvatarModel.marketplace!.collections!.isNotEmpty) {
        allCollections.value = marketPlaceAvatarModel.marketplace!.collections!;
        collections.value = allCollections; // initialize with all collections
      } else {
        allCollections.clear();
        collections.clear();
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch marketplace data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void filterAvatars(String query) {
    if (query.isEmpty) {
      avatars.value = allAvatars; // reset to original list
      collections.value = allCollections; // reset to original list
    } else {
      // Filter avatars
      avatars.value = allAvatars
          .where((a) =>
              (a.name ?? "").toLowerCase().contains(query.toLowerCase()) ||
              (a.description ?? "").toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Filter collections
      collections.value = allCollections
          .where((c) =>
              (c.name ?? "").toLowerCase().contains(query.toLowerCase()) ||
              (c.description ?? "")
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (c.creator?.fullName ?? "")
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (c.creator?.username ?? "")
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    }
  }
}
