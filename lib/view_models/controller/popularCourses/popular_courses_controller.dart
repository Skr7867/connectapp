import 'package:get/get.dart';

import '../../../models/PopularCourses/popular_courses_model.dart';
import '../../../repository/PopularCourses/popular_courses_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class PopularCoursesController extends GetxController {
  final PopularCoursesRepository _repository = PopularCoursesRepository();
  final UserPreferencesViewmodel _userPrefs = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var popularCourses = <Data>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var errorMessage = ''.obs;

  String? _token;

  @override
  void onInit() {
    super.onInit();
    _loadTokenAndFetch();
  }

  /// Load token from SharedPreferences and fetch first page
  Future<void> _loadTokenAndFetch() async {
    _token = await _userPrefs.getToken();
    if (_token != null) {
      fetchPopularCourses(1);
    } else {
      errorMessage("No token found. Please login again.");
    }
  }

  /// Fetch courses by page
  Future<void> fetchPopularCourses(int page) async {
    if (_token == null) return;

    try {
      isLoading(true);
      errorMessage('');

      // Pass page as String (repository expects String)
      final response = await _repository.getPopularCourses(_token!, page);

      if (page == 1) {
        popularCourses.assignAll(response.data ?? []);
      } else {
        popularCourses.addAll(response.data ?? []);
      }

      currentPage.value = response.pagination?.currentPage ?? 1;
      totalPages.value = response.pagination?.totalPages ?? 1;
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Load next page if available
  Future<void> loadMore() async {
    if (currentPage.value < totalPages.value) {
      await fetchPopularCourses(currentPage.value + 1);
    }
  }
}
