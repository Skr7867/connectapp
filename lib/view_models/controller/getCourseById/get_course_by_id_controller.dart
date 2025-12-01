import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/CourseGetById/course_get_by_id_Model.dart';
import '../../../repository/GetCourseById/get_course_by_id_repository.dart';

class GetCourseByIdController extends GetxController {
  final _api = GetCourseByIdRepository();
  final userPreferences = UserPreferencesViewmodel();
  final isSharing = false.obs;

  // Rx variables
  var rxRequestStatus = Status.LOADING.obs;
  var courseData = Rxn<CourseGetByIdModel>();
  var error = ''.obs;

  /// Fetch course details by ID
  Future<void> fetchCourseById(String courseId) async {
    rxRequestStatus.value = Status.LOADING;

    try {
      final token = await userPreferences.getToken();

      final courseResponse = await _api.getCourseByid(token!, courseId);

      if (courseResponse.sId != null) {
        courseData.value = courseResponse;
        rxRequestStatus.value = Status.COMPLETED;
        // log("Course fetched successfully: ${courseResponse.title}");
      } else {
        error.value = "Course not found";
        rxRequestStatus.value = Status.ERROR;
        // log("Error: Course not found for ID $courseId", level: 1000);
      }
    } catch (e) {
      error.value = e.toString();
      rxRequestStatus.value = Status.ERROR;
    }
  }
}
