import 'package:connectapp/data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';
import '../../models/CourseGetById/course_get_by_id_Model.dart';

class GetCourseByIdRepository {
  final _apiService = NetworkApiServices();

  Future<CourseGetByIdModel> getCourseByid(
      String token, String courseId) async {
    final url = '${ApiUrls.getCourseById}/$courseId';
    dynamic response = await _apiService.getApi(url, token: token);
    return CourseGetByIdModel.fromJson(response);
  }
}
