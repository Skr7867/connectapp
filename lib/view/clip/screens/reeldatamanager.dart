// import 'dart:convert';
// import 'dart:developer';
// import 'package:connectapp/models/UserLogin/user_login_model.dart';
// import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import '../../../res/api_urls/api_urls.dart';

// class ReelsDataManager extends GetxController {
//   static ReelsDataManager get instance => Get.find<ReelsDataManager>();

//   final RxList<dynamic> clips = <dynamic>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxBool isInitialized = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxInt currentPage = 1.obs;
//   final RxBool hasNextPage = false.obs;

//   // Make these reactive and add loading state for upload details
//   final RxString savedClipId = ''.obs;
//   final RxString savedUploadUrl = ''.obs;
//   final RxBool isUploadDetailsLoading = false.obs;
//   final RxString uploadDetailsError = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Start background initialization
//     _initializeInBackground();
//   }

//   Future<void> _initializeInBackground() async {
//     if (isInitialized.value) return;

//     try {
//       isLoading.value = true;

//       // Fetch both concurrently
//       await Future.wait([
//         _fetchClips(page: 1, isRefresh: true),
//         getUploadDetails(), // Ensure upload details are loaded
//       ]);

//       isInitialized.value = true;
//     } catch (e) {
//       errorMessage.value = 'Failed to load clips: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> getUploadDetails() async {
//     if (isUploadDetailsLoading.value) return;

//     try {
//       isUploadDetailsLoading.value = true;
//       uploadDetailsError.value = '';

//       final UserPreferencesViewmodel userPreferences =
//           UserPreferencesViewmodel();
//       LoginResponseModel? userData = await userPreferences.getUser();
//       final token = userData!.token;

//       final response = await http.post(
//         Uri.parse(
//             '${ApiUrls.baseUrl}/connect/v1/api/social/clip/generate-presigned-url'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         savedClipId.value = data['clipId'] ?? '';
//         savedUploadUrl.value = data['uploadUrl'] ?? '';
//         // log('Presigned URL fetched: ${savedUploadUrl.value}');
//         // log('Clip ID: ${savedClipId.value}');
//       } else {
//         throw Exception('Failed to get upload details: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error getting upload details: $e');
//       uploadDetailsError.value = 'Failed to get upload details: $e';
//       // Reset values on error
//       savedClipId.value = '';
//       savedUploadUrl.value = '';
//     } finally {
//       isUploadDetailsLoading.value = false;
//     }
//   }

//   // Method to refresh upload details on demand
//   Future<void> refreshUploadDetails() async {
//     await getUploadDetails();
//   }

//   // Getter to check if upload details are ready
//   bool get areUploadDetailsReady {
//     return savedClipId.value.isNotEmpty && savedUploadUrl.value.isNotEmpty;
//   }

//   Future<void> _fetchClips({int page = 1, bool isRefresh = false}) async {
//     try {
//       final UserPreferencesViewmodel userPreferences =
//           UserPreferencesViewmodel();
//       LoginResponseModel? userData = await userPreferences.getUser();
//       final token = userData!.token;

//       final response = await http.get(
//         Uri.parse(
//             '${ApiUrls.baseUrl}/connect/v1/api/social/clip/get-all-clips?page=$page&limit=5'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (isRefresh) {
//           clips.assignAll(data['clips'] ?? []);
//         } else {
//           clips.addAll(data['clips'] ?? []);
//         }

//         final pagination = data['pagination'];
//         if (pagination != null) {
//           currentPage.value = pagination['currentPage'] ?? 1;
//           hasNextPage.value = pagination['hasNextPage'] ?? false;
//         }
//       } else {
//         throw Exception('Failed to fetch clips: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error fetching clips: $e');
//       rethrow;
//     }
//   }

//   Future<void> loadMoreClips() async {
//     if (isLoading.value || !hasNextPage.value) return;

//     isLoading.value = true;
//     try {
//       await _fetchClips(page: currentPage.value + 1);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> refreshClips() async {
//     isLoading.value = true;
//     errorMessage.value = '';

//     try {
//       await _fetchClips(page: 1, isRefresh: true);
//       isInitialized.value = true;
//     } catch (e) {
//       errorMessage.value = 'Failed to refresh clips: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Method to update follow status
//   void updateClipFollowStatus(
//       String userId, bool isFollowing, int followerCount) {
//     for (int i = 0; i < clips.length; i++) {
//       if (clips[i]['userId']['_id'] == userId) {
//         clips[i]['isFollowing'] = isFollowing;
//         clips[i]['userId']['followerCount'] = followerCount;
//         clips.refresh(); // Trigger reactivity
//       }
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:connectapp/models/UserLogin/user_login_model.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../res/api_urls/api_urls.dart';

class ReelsDataManager extends GetxController {
  static ReelsDataManager get instance => Get.find<ReelsDataManager>();

  final RxList<dynamic> clips = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNextPage = false.obs;
  final RxBool isLoadingMore = false.obs; // New flag for pagination loading

  // Make these reactive and add loading state for upload details
  final RxString savedClipId = ''.obs;
  final RxString savedUploadUrl = ''.obs;
  final RxBool isUploadDetailsLoading = false.obs;
  final RxString uploadDetailsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Start background initialization
    _initializeInBackground();
  }

  Future<void> _initializeInBackground() async {
    if (isInitialized.value) return;

    try {
      isLoading.value = true;

      // Fetch both concurrently
      await Future.wait([
        _fetchClips(page: 1, isRefresh: true),
        getUploadDetails(), // Ensure upload details are loaded
      ]);

      isInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Failed to load clips: $e';
      log('Initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUploadDetails() async {
    if (isUploadDetailsLoading.value) return;

    try {
      isUploadDetailsLoading.value = true;
      uploadDetailsError.value = '';

      final UserPreferencesViewmodel userPreferences =
          UserPreferencesViewmodel();
      LoginResponseModel? userData = await userPreferences.getUser();
      final token = userData!.token;

      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/clip/generate-presigned-url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        savedClipId.value = data['clipId'] ?? '';
        savedUploadUrl.value = data['uploadUrl'] ?? '';
      } else {
        throw Exception('Failed to get upload details: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting upload details: $e');
      uploadDetailsError.value = 'Failed to get upload details: $e';
      savedClipId.value = '';
      savedUploadUrl.value = '';
    } finally {
      isUploadDetailsLoading.value = false;
    }
  }

  Future<void> refreshUploadDetails() async {
    await getUploadDetails();
  }

  bool get areUploadDetailsReady {
    return savedClipId.value.isNotEmpty && savedUploadUrl.value.isNotEmpty;
  }

  Future<void> _fetchClips({int page = 1, bool isRefresh = false}) async {
    try {
      log('Fetching clips: page=$page, isRefresh=$isRefresh');

      final UserPreferencesViewmodel userPreferences =
          UserPreferencesViewmodel();
      LoginResponseModel? userData = await userPreferences.getUser();
      final token = userData!.token;

      final response = await http.get(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/clip/get-all-clips?page=$page&limit=5'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newClips = data['clips'] ?? [];

        log('Received ${newClips.length} clips from page $page');

        if (isRefresh) {
          clips.assignAll(newClips);
          log('Clips refreshed. Total clips: ${clips.length}');
        } else {
          // Avoid duplicates when loading more
          final existingIds = clips.map((c) => c['_id']).toSet();
          final uniqueNewClips =
              newClips.where((c) => !existingIds.contains(c['_id'])).toList();
          clips.addAll(uniqueNewClips);
          log('Added ${uniqueNewClips.length} new clips. Total clips: ${clips.length}');
        }

        final pagination = data['pagination'];
        if (pagination != null) {
          currentPage.value = pagination['currentPage'] ?? 1;
          hasNextPage.value = pagination['hasNextPage'] ?? false;
          log('Pagination: page=${currentPage.value}, hasNext=${hasNextPage.value}');
        }
      } else {
        throw Exception('Failed to fetch clips: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching clips: $e');
      rethrow;
    }
  }

  Future<void> loadMoreClips() async {
    // Prevent multiple simultaneous loads
    if (isLoadingMore.value || !hasNextPage.value) {
      log('Skipping loadMoreClips: isLoadingMore=${isLoadingMore.value}, hasNextPage=${hasNextPage.value}');
      return;
    }

    isLoadingMore.value = true;
    log('Loading more clips from page ${currentPage.value + 1}');

    try {
      await _fetchClips(page: currentPage.value + 1);
    } catch (e) {
      log('Error loading more clips: $e');
      // Don't show error to user for pagination failures, just log it
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshClips() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _fetchClips(page: 1, isRefresh: true);
      isInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Failed to refresh clips: $e';
      log('Error refreshing clips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateClipFollowStatus(
      String userId, bool isFollowing, int followerCount) {
    for (int i = 0; i < clips.length; i++) {
      if (clips[i]['userId']['_id'] == userId) {
        clips[i]['isFollowing'] = isFollowing;
        clips[i]['userId']['followerCount'] = followerCount;
        clips.refresh();
      }
    }
  }

  // Add method to clear clips (useful for logout/cleanup)
  void clearClips() {
    clips.clear();
    currentPage.value = 1;
    hasNextPage.value = false;
    isInitialized.value = false;
  }
}
