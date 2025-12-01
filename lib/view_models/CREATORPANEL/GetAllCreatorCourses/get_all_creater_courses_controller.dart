import 'dart:developer';
import 'package:connectapp/models/CREATORPANEL/CreatorCourses/get_all_creator_courses_model.dart';
import 'package:connectapp/repository/CREATORPANEL/GetAllCreatorAllCourses/get_all_creator_courses_repository.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class GetAllCreatorCoursesController extends GetxController {
  final _api = GetAllCreatorCoursesRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final creatorCourses =
      <GetAllCreatorCoursesModel>[].obs; // RxList for courses
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserList(List<GetAllCreatorCoursesModel> value) =>
      creatorCourses.value = value;

  @override
  void onInit() {
    super.onInit();
    creatorCourseApi();
  }

  Future<void> creatorCourseApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        log("Token missing. Cannot fetch courses.");
        return;
      }

      log("TOKEN: ${loginData.token}");

      final value = await _api.creatorCourses(loginData.token);

      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
    } catch (error, stackTrace) {
      log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        log(" Token missing. Cannot fetch courses.");
        return;
      }

      log("Refresh TOKEN: ${loginData.token}");

      final value = await _api.creatorCourses(loginData.token);
      log("API Response: $value");
      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
    } catch (error, stackTrace) {
      log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
