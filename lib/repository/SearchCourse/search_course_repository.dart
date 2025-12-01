import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/SearchCourseModel/search_course_model.dart';

class SearchCourseRepository {
  final _apiService = NetworkApiServices();

  Future<SearchCourseModel> searchCourse(String url, String token) async {
    dynamic response = await _apiService.getApi(url, token: token);
    return SearchCourseModel.fromJson(response);
  }
}
