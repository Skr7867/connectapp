import 'package:get/get.dart';
import 'package:connectapp/utils/utils.dart';
import '../../../repository/AddToMarket/add_to_market_repository.dart';

class MarketplaceAvatarController extends GetxController {
  final AddToMarketRepository _repository = AddToMarketRepository();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<bool> setAvatarOnMarketplace({
    required String avatarId,
    required int price,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final payload = {
        'price': price,
      };

      final response = await _repository.addToMarketPlace(avatarId, payload);

      if (response != null && response['success'] == true) {
        Utils.snackBar(
          "Avatar listed on marketplace!",
          "Success",
        );
        return true;
      } else {
        errorMessage.value =
            response?['message'] ?? "Failed to add avatar to marketplace";
        Utils.snackBar(
          errorMessage.value,
          "Success",
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = "$e";
      Utils.snackBar(
        errorMessage.value,
        "Info",
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
