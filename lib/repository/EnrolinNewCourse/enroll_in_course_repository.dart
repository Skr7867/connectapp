import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class EnrollInCourseRepository {
  final _apiService = NetworkApiServices();

  /// Enroll user in a course
  Future<dynamic> enrollInCourse(String courseId, String token,
      {Map<String, dynamic>? data}) async {
    final url = "${ApiUrls.enrollInNewCourseApi}/$courseId";

    return await _apiService.postApi(
      data ?? {}, // in case API doesn’t require body, send empty {}
      url,
      token: token,
    );
  }
}
