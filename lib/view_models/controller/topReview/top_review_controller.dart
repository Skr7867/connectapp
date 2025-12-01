import 'package:get/get.dart';

import '../../../models/TopReview/top_review_model.dart';
import '../../../repository/TopReview/top_review_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class TopReviewController extends GetxController {
  final TopReviewRepository _repository = TopReviewRepository();
  final UserPreferencesViewmodel _userPrefs = UserPreferencesViewmodel();

  // Observables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var topReviews = <Data>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopReviews();
  }

  Future<void> fetchTopReviews() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      topReviews.clear();

      final token = await _userPrefs.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = "No token found. Please login again.";
        return;
      }

      final response = await _repository.topReviews(token);

      if (response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        topReviews.assignAll(response.data!);
      } else {
        errorMessage.value = "No reviews available.";
      }
    } catch (e) {
      errorMessage.value = "Failed to fetch reviews: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
