import 'package:connectapp/data/network/network_api_services.dart';

import 'package:connectapp/res/api_urls/api_urls.dart';

import '../../models/MyAllClips/my_all_clips_model.dart';

class MyClipsRepository {
  final _apiService = NetworkApiServices();

  Future<MyAllClipsModel> myAllClips(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.myClipsApi, token: token);
    return MyAllClipsModel.fromJson(response);
  }
}
