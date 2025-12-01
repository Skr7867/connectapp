import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:connectapp/models/SearchCourseModel/search_course_model.dart';
import '../../../repository/SearchCourse/search_course_repository.dart';
import '../userPreferences/user_preferences_screen.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class SearchCourseController extends GetxController {
  final SearchCourseRepository _searchCourseRepository =
      SearchCourseRepository();
  final UserPreferencesViewmodel _userPreferencesViewmodel =
      UserPreferencesViewmodel();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  // Observable variables
  var searchCourseModel = SearchCourseModel().obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _userPreferencesViewmodel.init();
  }

  // Method to update search query with debouncing
  void updateSearchQuery(String query) {
    _debouncer.run(() {
      searchQuery.value = query;
      if (query.isNotEmpty) {
        searchCourses();
      } else {
        searchCourseModel.value = SearchCourseModel();
        errorMessage.value = '';
      }
    });
  }

  // Method to perform course search
  Future<void> searchCourses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch token from UserPreferencesViewmodel
      final token = await _userPreferencesViewmodel.getToken();

      if (token == null) {
        errorMessage.value = 'User not authenticated. Please log in.';
        isLoading.value = false;
        return;
      }

      // Construct the API URL with the current search query
      String updatedApiUrl =
          '${ApiUrls.baseUrl}/connect/v1/api/user/search-courses?q=${Uri.encodeQueryComponent(searchQuery.value)}';

      // Call the repository with the dynamic URL
      final response =
          await _searchCourseRepository.searchCourse(updatedApiUrl, token);

      // Update the observable model with the response
      searchCourseModel.value = response;
    } catch (e) {
      // Log error details
      log('Error fetching courses: $e');
      if (e is Map<String, dynamic> && e.containsKey('response')) {
        final response = e['response'];
        // developer.log('Response Code: ${response['statusCode']}');
        // developer.log('Response Body: ${response['body']}');
        errorMessage.value =
            response['body']['message'] ?? 'Failed to fetch courses';
      } else {
        errorMessage.value = 'Failed to fetch courses: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }
}

// Debouncer class to prevent rapid API calls
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
