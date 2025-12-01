import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import '../../models/MarketPlaceAvatar/market_place_avatar_model.dart';
import 'dart:developer';

class MarketPlaceAvatarRepository {
  final _apiService = NetworkApiServices();

  Future<MarketPlaceAvatarModel> myMarketPlaceAvatar(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.marketPlaceAvatarApi, token: token);
    log('Raw API Response: $response'); // Log the raw response
    return MarketPlaceAvatarModel.fromJson(response);
  }
}
