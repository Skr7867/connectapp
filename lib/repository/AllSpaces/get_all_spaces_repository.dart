import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/AllSpaces/get_all_spaces_model.dart';

import '../../res/api_urls/api_urls.dart';

class GetAllSpacesRepository {
  final _apiService = NetworkApiServices();

  Future<GetAllSpacesModel> allSpaces(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.allSpacesApi, token: token);
    return GetAllSpacesModel.fromJson(response);
  }
}
