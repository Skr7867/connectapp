import 'dart:developer';

import 'package:get/get.dart';
import '../../../models/TopCreatorCourses/top_creator_courses_model.dart';
import '../../../repository/TopCreatorCourses/top_creator_courses_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class TopCreatorCoursesController extends GetxController {
  final TopCreatorCoursesRepository _repository = TopCreatorCoursesRepository();
  final UserPreferencesViewmodel _userPrefs = UserPreferencesViewmodel();

  // Observables
  var isLoading = false.obs;
  var coursesData = Rxn<TopCreatorCoursesModel>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopCourses();
  }

  Future<void> fetchTopCourses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _userPrefs.getToken();

      if (token == null) {
        errorMessage.value = 'User token not found';
        return;
      }

      final response = await _repository.topCourses(token);

      /// ✅ CHECK SUCCESS
      if (response.success == false) {
        errorMessage.value =
            response.message ?? "No top creator courses available";
        coursesData.value = null;
        return;
      }

      coursesData.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
      log(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
