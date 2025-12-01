import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/CREATORPANEL/FetchCreatorSpace/fetch_creator_space_model.dart';
import '../../../res/api_urls/api_urls.dart';

class FetchCreatorSpaceRepository {
  final _apiService = NetworkApiServices();

  Future<FetchCreatorSpaceModel> creatorSpace(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.fetchCreatorSpaceApi, token: token);
    return FetchCreatorSpaceModel.fromJson(response);
  }
}
