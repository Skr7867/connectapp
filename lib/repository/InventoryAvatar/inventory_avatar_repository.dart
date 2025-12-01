import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/InventoryAvatar/inventory_avatar_model.dart';
import '../../res/api_urls/api_urls.dart';

class InventoryAvatarRepository {
  final _apiService = NetworkApiServices();

  Future<InventoryAvatarModel> inventoryAvatar(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.inventoryAvatarApi, token: token);
    return InventoryAvatarModel.fromJson(response);
  }
}
