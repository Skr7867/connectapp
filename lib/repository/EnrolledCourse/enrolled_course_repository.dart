import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/EnrolledCourses/enrolled_courses_model.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class EnrolledCourseRepository {
  final _apiService = NetworkApiServices();

  Future<EnrolledCoursesModel> enrolledCourses(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.enrolledCoursesApi, token: token);
    return EnrolledCoursesModel.fromJson(response);
  }
}
