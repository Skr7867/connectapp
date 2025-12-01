import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/TopCreatorCourses/top_creator_courses_model.dart';
import '../../res/api_urls/api_urls.dart';

class TopCreatorCoursesRepository {
  final _apiService = NetworkApiServices();

  Future<TopCreatorCoursesModel> topCourses(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.topCreatorCourses, token: token);
    return TopCreatorCoursesModel.fromJson(response);
  }
}
