import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/TopReview/top_review_model.dart';

import '../../res/api_urls/api_urls.dart';

class TopReviewRepository {
  final _apiService = NetworkApiServices();

  Future<TopReviewModel> topReviews(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.topReviewApi, token: token);
    return TopReviewModel.fromJson(response);
  }
}
