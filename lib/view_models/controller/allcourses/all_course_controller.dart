import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/Courses/all_courses_model.dart';
import '../../../repository/Courses/all_courses_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class AllCoursesController extends GetxController {
  final _api = AllCoursesRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final courses = <Course>[].obs;
  final error = ''.obs;

  get searchQuery => null;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setCourses(List<Course> value) => courses.assignAll(value);

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: ${loginData.token}");

      final response = await _api.getAllCourses(loginData.token);
      // log("API Response: ${response.map((course) => course.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setCourses(response);
    } catch (error) {
      // log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshCourses() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("Refresh TOKEN: ${loginData.token}");

      final response = await _api.getAllCourses(loginData.token);
      // log("Refresh API Response: ${response.map((course) => course.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setCourses(response);
    } catch (error) {
      // log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
