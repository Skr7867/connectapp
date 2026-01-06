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
  final RxBool isLoadingMore = false.obs;

  // Upload details - reactive
  final RxString savedClipId = ''.obs;
  final RxString savedUploadUrl = ''.obs;
  final RxBool isUploadDetailsLoading = false.obs;
  final RxString uploadDetailsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeInBackground();
  }

  Future<void> _initializeInBackground() async {
    if (isInitialized.value) return;

    try {
      isLoading.value = true;

      // Fetch clips and upload details concurrently
      await Future.wait([
        _fetchClips(page: 1, isRefresh: true),
        getUploadDetails(),
      ]);

      isInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Failed to load clips: $e';
      log('Initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// **CRITICAL FIX: Always get fresh upload details before each upload**
  Future<void> getUploadDetails({bool force = false}) async {
    // If force is true OR if details are empty, fetch new details
    if (!force && isUploadDetailsLoading.value) return;

    try {
      isUploadDetailsLoading.value = true;
      uploadDetailsError.value = '';

      log('Fetching new upload details...');

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

      log('Upload details response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        savedClipId.value = data['clipId'] ?? '';
        savedUploadUrl.value = data['uploadUrl'] ?? '';

        log('New Clip ID: ${savedClipId.value}');
        log('Upload URL obtained: ${savedUploadUrl.value.isNotEmpty}');

        if (savedClipId.value.isEmpty || savedUploadUrl.value.isEmpty) {
          throw Exception('Invalid upload details received from server');
        }
      } else {
        final errorBody = response.body;
        log('Upload details error response: $errorBody');
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

  /// Refresh upload details - always gets fresh details
  Future<void> refreshUploadDetails() async {
    log('Refreshing upload details (forced)...');
    await getUploadDetails(force: true);
  }

  /// Check if upload details are ready and valid
  bool get areUploadDetailsReady {
    final ready = savedClipId.value.isNotEmpty &&
        savedUploadUrl.value.isNotEmpty &&
        !isUploadDetailsLoading.value;
    log('Upload details ready: $ready (clipId: ${savedClipId.value.isNotEmpty}, url: ${savedUploadUrl.value.isNotEmpty}, loading: ${isUploadDetailsLoading.value})');
    return ready;
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
      log('Clips refreshed successfully');
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

  void clearClips() {
    clips.clear();
    currentPage.value = 1;
    hasNextPage.value = false;
    isInitialized.value = false;
    savedClipId.value = '';
    savedUploadUrl.value = '';
  }
}
