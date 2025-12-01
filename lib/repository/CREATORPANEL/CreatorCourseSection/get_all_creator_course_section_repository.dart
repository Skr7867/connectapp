import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/CREATORPANEL/CreatorCoursesSection/get_all_creator_course_section_model.dart';
import '../../../res/api_urls/api_urls.dart';

class GetAllCreatorCourseSectionRepository {
  final _apiService = NetworkApiServices();

  Future<GetAllCreatorCourseSectionModel> creatorCourseSections(
      String token, String courseId) async {
    // Append courseId to the API URL
    final url = "${ApiUrls.getCourseSectionApi}/$courseId";
    dynamic response = await _apiService.getApi(url, token: token);
    return GetAllCreatorCourseSectionModel.fromJson(response);
  }
}
