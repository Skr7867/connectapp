import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class DeleteCommentRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> deleteComment(String commentId, String token) async {
    final url = "${ApiUrls.deleteAvatarsCommentApi}/$commentId";
    return await _apiService.deleteApi(url, token: token);
  }
}
