import 'package:connectapp/data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';
import '../../models/GetClipByid/get_clip_by_id_model.dart';

class GetClipByIdRepository {
  final _apiService = NetworkApiServices();

  Future<GetClipbyidModel> getClipByid(String token, String clipId) async {
    final url = '${ApiUrls.getClipsByidApi}/$clipId';
    dynamic response = await _apiService.getApi(url, token: token);
    return GetClipbyidModel.fromJson(response);
  }
}
