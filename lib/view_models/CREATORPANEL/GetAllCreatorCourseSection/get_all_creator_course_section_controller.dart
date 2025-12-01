import 'dart:developer';
import 'package:connectapp/models/CREATORPANEL/CreatorCoursesSection/get_all_creator_course_section_model.dart';
import 'package:connectapp/repository/CREATORPANEL/CreatorCourseSection/get_all_creator_course_section_repository.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class GetAllCreatorCourseSectionController extends GetxController {
  final _api = GetAllCreatorCourseSectionRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final creatorCourseSection =
      Rx<GetAllCreatorCourseSectionModel?>(null); // Single object
  final error = ''.obs;
  final String courseId;

  GetAllCreatorCourseSectionController({required this.courseId});

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setCourseSection(GetAllCreatorCourseSectionModel value) =>
      creatorCourseSection.value = value;

  @override
  void onInit() {
    super.onInit();
    creatorCourseSectionApi();
  }

  Future<void> creatorCourseSectionApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        log("Token missing. Cannot fetch course sections.");
        return;
      }

      log("TOKEN: ${loginData.token}");

      final value = await _api.creatorCourseSections(loginData.token, courseId);

      setRxRequestStatus(Status.COMPLETED);
      setCourseSection(value);
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
        log("Token missing. Cannot fetch course sections.");
        return;
      }

      log("Refresh TOKEN: ${loginData.token}");

      final value = await _api.creatorCourseSections(loginData.token, courseId);
      log("API Response: $value");
      setRxRequestStatus(Status.COMPLETED);
      setCourseSection(value);
    } catch (error, stackTrace) {
      log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
