import 'dart:developer';
import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/CREATORPANEL/CreatorCourses/get_all_creator_courses_model.dart';
import '../../../res/api_urls/api_urls.dart';

class GetAllCreatorCoursesRepository {
  final _apiService = NetworkApiServices();

  Future<List<GetAllCreatorCoursesModel>> creatorCourses(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.getAllCreatorCourses, token: token);
    log("API Response: $response");

    if (response is List) {
      return response
          .map((json) => GetAllCreatorCoursesModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Expected a list of courses, but got: $response');
    }
  }
}
