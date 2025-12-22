import 'dart:async';
import 'package:connectapp/models/EnrolledCourses/enrolled_courses_model.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/CourseProgress/course_progress_model.dart';

import '../../../res/api_urls/api_urls.dart';
import '../../../res/routes/routes_name.dart';
import '../profile/user_profile_controller.dart';
import '../userPreferences/user_preferences_screen.dart';

class CourseVideoController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final userData = Get.find<UserProfileController>();
  final EnrolledCourses course = Get.arguments as EnrolledCourses;
  late TabController tabController;
  final Rx<VideoPlayerController?> videoPlayerController =
      Rx<VideoPlayerController?>(null);
  final RxBool isVideoInitialized = false.obs;
  final Rx<Lesson?> currentLesson = Rx<Lesson?>(null);
  final RxInt currentLessonIndex = (-1).obs;
  final RxList<Lesson> allLessons = <Lesson>[].obs;
  final RxBool isLandscape = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCourseSubmitted = false.obs;
  final _prefs = UserPreferencesViewmodel();
  static const String baseUrl = ApiUrls.baseUrl;

  final Rx<CourseProgressModel?> courseProgress =
      Rx<CourseProgressModel?>(null);
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedRating = 0.obs;
  final RxString reviewText = ''.obs;
  final RxBool isSubmittingReview = false.obs;
  final showControls = true.obs;
  Timer? _hideControlsTimer;

  // NEW: Video preloading variables
  final Map<String, VideoPlayerController> _preloadedVideoControllers = {};
  final Map<String, bool> _preloadStatus = {};
  final RxBool _isPreloadingActive = false.obs;

  // TextEditingController for review field to properly clear text
  final reviewTextController = TextEditingController();

  static const String courseSubmissionPath =
      '/connect/v1/api/user/course/complete-course';

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    fetchCourseProgress(course.id);
    initializeLessons();
    checkCourseSubmissionStatus();
    initializeVideoPlayer();

    // NEW: Start preloading videos after initialization
    _startVideoPreloading();
  }

  // NEW: Method to preload all video lessons
  Future<void> _startVideoPreloading() async {
    if (_isPreloadingActive.value) return;

    _isPreloadingActive.value = true;

    // Get all video lessons
    final videoLessons = allLessons
        .where((lesson) =>
            lesson.contentType == 'video' &&
            lesson.videoUrl != null &&
            lesson.videoUrl!.isNotEmpty)
        .toList();

    // Preload videos sequentially to avoid overwhelming the network
    for (var lesson in videoLessons) {
      if (!_preloadStatus.containsKey(lesson.videoUrl!) ||
          _preloadStatus[lesson.videoUrl!] == false) {
        await _preloadVideo(lesson.videoUrl!);
      }
    }

    _isPreloadingActive.value = false;
  }

  // NEW: Preload individual video
  Future<void> _preloadVideo(String videoUrl) async {
    if (_preloadedVideoControllers.containsKey(videoUrl)) return;

    try {
      _preloadStatus[videoUrl] = false;
      final controller = VideoPlayerController.network(videoUrl);

      // Store controller before initialization
      _preloadedVideoControllers[videoUrl] = controller;

      // Initialize in background
      await controller.initialize();

      // Set to beginning and pause
      await controller.seekTo(Duration.zero);
      controller.pause();

      _preloadStatus[videoUrl] = true;
      print('Preloaded video: $videoUrl');
    } catch (e) {
      print('Failed to preload video $videoUrl: $e');
      _preloadedVideoControllers.remove(videoUrl);
      _preloadStatus.remove(videoUrl);
    }
  }

  void updateRating(int rating) {
    selectedRating.value = rating;
  }

  void updateReviewText(String text) {
    reviewText.value = text;
  }

  Future<void> submitReview(String courseId) async {
    if (selectedRating.value == 0) {
      Utils.snackBar(
        'Please select a rating',
        'Info',
      );
      return;
    }
    if (reviewText.value.trim().isEmpty) {
      Utils.snackBar(
        'Please enter a review',
        'Info',
      );
      return;
    }

    try {
      isSubmittingReview.value = true;
      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        Utils.snackBar(
            'Authentication Error', 'Please log in to submit a review');
        Get.offNamed(RouteName.loginScreen);
        return;
      }

      final url = '$baseUrl/connect/v1/api/user/add-course-review/$courseId';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({
          'rating': selectedRating.value,
          'review': reviewText.value,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.snackBar(
          'Review submitted successfully',
          'Success',
        );

        // Clear both the observable and the text controller
        selectedRating.value = 0;
        reviewText.value = '';
        reviewTextController.clear();

        // Force UI update
        update();
      } else if (response.statusCode == 401) {
        Utils.snackBar('Session Expired', 'Please log in again');
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Failed to submit review';
        Utils.snackBar(errorMessage, 'Info');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (errorMessage.contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again later.';
      }
      Utils.snackBar(
        errorMessage,
        'Info',
      );
    } finally {
      isSubmittingReview.value = false;
    }
  }

  void initializeLessons() {
    allLessons.assignAll(
      course.sections
              ?.expand((section) => section.lessons ?? <Lesson>[])
              .toList() ??
          [],
    );

    if (allLessons.isEmpty) {
      Get.snackbar(
        'Info',
        'No lessons available for this course.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    for (int i = 0; i < allLessons.length; i++) {
      if (allLessons[i].contentType == 'video' &&
          allLessons[i].videoUrl != null) {
        currentLesson.value = allLessons[i];
        currentLessonIndex.value = i;
        break;
      }
    }
  }

  Future<void> checkCourseSubmissionStatus() async {
    try {
      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        return;
      }
      final response = await http.get(
        Uri.parse('$baseUrl/connect/v1/api/user/profile'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
        },
      );
      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body);
        final completedCourses = profile['completedCourses'];
        if (completedCourses is List) {
          isCourseSubmitted.value = completedCourses.contains(course.id);
        } else {
          isCourseSubmitted.value =
              courseProgress.value?.progress?.isCompleted ?? false;
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void initializeVideoPlayer() {
    if (currentLesson.value != null && currentLesson.value!.videoUrl != null) {
      final videoUrl = currentLesson.value!.videoUrl!;

      // Show loading state
      isVideoInitialized.value = false;

      // NEW: Check if video is preloaded
      if (_preloadedVideoControllers.containsKey(videoUrl) &&
          _preloadStatus[videoUrl] == true) {
        // Use preloaded controller
        videoPlayerController.value = _preloadedVideoControllers[videoUrl];
        isVideoInitialized.value = true;

        // Add listener for real-time state updates
        videoPlayerController.value?.addListener(_videoPlayerListener);

        // Play immediately if it's a completed lesson
        if (currentLesson.value?.isCompleted == true) {
          videoPlayerController.value?.play();
          _startHideControlsTimer();
        }

        update();
      } else {
        // Fallback to network loading
        videoPlayerController.value = VideoPlayerController.network(videoUrl)
          ..initialize().then((_) {
            isVideoInitialized.value = true;
            // Add listener for real-time state updates
            videoPlayerController.value?.addListener(_videoPlayerListener);
            update();
          }).catchError((error) {
            isVideoInitialized.value = false;
            Get.snackbar(
              'Failed',
              'Failed to load video',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          });
      }
    }
  }

  // Listener to track video player state changes in real-time
  void _videoPlayerListener() {
    // Force UI update when video state changes (play/pause/buffering)
    update();
  }

  void playNextVideo() {
    for (int i = currentLessonIndex.value + 1; i < allLessons.length; i++) {
      if (allLessons[i].contentType == 'video' &&
          allLessons[i].videoUrl != null) {
        currentLesson.value = allLessons[i];
        currentLessonIndex.value = i;
        isVideoInitialized.value = false;

        videoPlayerController.value?.removeListener(_videoPlayerListener);
        // Don't dispose if it's a preloaded controller (we'll reuse it)
        if (!_preloadedVideoControllers
            .containsValue(videoPlayerController.value)) {
          videoPlayerController.value?.dispose();
        }

        final videoUrl = currentLesson.value!.videoUrl!;

        // NEW: Check if next video is preloaded
        if (_preloadedVideoControllers.containsKey(videoUrl) &&
            _preloadStatus[videoUrl] == true) {
          videoPlayerController.value = _preloadedVideoControllers[videoUrl];
          isVideoInitialized.value = true;
          videoPlayerController.value?.addListener(_videoPlayerListener);
          videoPlayerController.value!.play();
          _startHideControlsTimer();
          update();
        } else {
          videoPlayerController.value = VideoPlayerController.network(videoUrl)
            ..initialize().then((_) {
              isVideoInitialized.value = true;
              videoPlayerController.value?.addListener(_videoPlayerListener);
              videoPlayerController.value!.play();
              update();
            }).catchError((error) {
              isVideoInitialized.value = false;
            });
        }
        return;
      }
    }
    videoPlayerController.value?.pause();
  }

  Future<void> markLessonCompleted({Map<String, String>? answers}) async {
    if (isCourseSubmitted.value) {
      Get.snackbar(
        'Info',
        'Course already submitted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        throw Exception('No authentication token found');
      }
      if (currentLesson.value?.id == null) {
        throw Exception('No lesson selected');
      }

      final response = await http.post(
        Uri.parse(
            '$baseUrl/connect/v1/api/user/course/${course.id}/mark-lesson-completed/${currentLesson.value!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({'userAnswer': answers}),
      );

      if (response.statusCode == 200) {
        allLessons.value = allLessons.map((lesson) {
          if (lesson.id == currentLesson.value?.id) {
            return Lesson(
              id: lesson.id,
              title: lesson.title,
              contentType: lesson.contentType,
              videoUrl: lesson.videoUrl,
              textContent: lesson.textContent,
              quiz: lesson.quiz,
              isCompleted: true,
            );
          }
          return lesson;
        }).toList();
        update();
        await Future.delayed(const Duration(milliseconds: 500));
        await fetchCourseProgress(course.id);

        Get.snackbar(
          'Success',
          'Lesson completed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to mark lesson as completed: ${response.body}');
      }
    } catch (err) {
      Get.snackbar(
        'Error',
        err.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitCourse() async {
    if (isCourseSubmitted.value) {
      Get.snackbar(
        'Info',
        'Course already submitted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    if (!allLessons.every((lesson) => lesson.isCompleted!)) {
      Get.snackbar(
        'Info',
        'Please complete all lessons before submitting the course.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl$courseSubmissionPath/${course.id}';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        isCourseSubmitted.value = true;
        userData.userList();
        await fetchCourseProgress(course.id);
        Get.dialog(
          AlertDialog(
            title: const Text('Course Completed!'),
            content: Text('You have completed ${course.title}.'),
            actions: [
              TextButton(
                onPressed: () => Get.offNamed(RouteName.homeScreen),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'Session Expired',
          'Your session has expired. Please log in again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
      } else {
        String errorMessage = 'Failed to submit course.';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Unexpected server response: ${response.body}';
        }
        Get.snackbar(
          'Info',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (err) {
      String errorMessage = err.toString();
      if (errorMessage.contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (errorMessage.contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again later.';
      } else if (errorMessage.contains('FormatException')) {
        errorMessage = 'Unexpected server response. Please contact support.';
      }
      Get.snackbar(
        'Info',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void playLesson(Lesson lesson, int index) async {
    currentLesson.value = lesson;
    currentLessonIndex.value = index;

    if (lesson.contentType == 'video' && lesson.videoUrl != null) {
      final videoUrl = lesson.videoUrl!;

      // Show loading state
      isVideoInitialized.value = false;
      showControls.value = true; // Show controls when switching videos

      // Dispose current controller if it's not a preloaded one
      videoPlayerController.value?.removeListener(_videoPlayerListener);
      if (!_preloadedVideoControllers
          .containsValue(videoPlayerController.value)) {
        videoPlayerController.value?.dispose();
      }

      // NEW: Check if video is preloaded
      if (_preloadedVideoControllers.containsKey(videoUrl) &&
          _preloadStatus[videoUrl] == true) {
        // Use preloaded controller for instant playback
        videoPlayerController.value = _preloadedVideoControllers[videoUrl];
        isVideoInitialized.value = true;

        // Add listener
        videoPlayerController.value?.addListener(_videoPlayerListener);

        // Play immediately
        videoPlayerController.value!.play();
        _startHideControlsTimer();

        update(['video_player', 'video_controls']);
      } else {
        // Fallback to network loading
        videoPlayerController.value = VideoPlayerController.network(videoUrl)
          ..initialize().then((_) {
            isVideoInitialized.value = true;
            videoPlayerController.value?.addListener(_videoPlayerListener);

            // Play after initialization
            videoPlayerController.value!.play();
            _startHideControlsTimer();

            update(['video_player', 'video_controls']);
          }).catchError((error) {
            isVideoInitialized.value = false;
            Get.snackbar(
              'Failed',
              'Failed to load video',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          });
      }
    } else if (lesson.contentType == 'quiz') {
      Get.toNamed(RouteName.quizScreen, arguments: lesson)?.then((result) {
        if (result != null && result is Map<String, dynamic>) {
          final total = result['total'] as int?;
          final answers = result['answers'] as Map<String, String>?;
          if (total != null && answers != null && answers.isNotEmpty) {
            markLessonCompleted(answers: answers);
          } else {
            Get.snackbar(
              'Failed',
              'Failed to process quiz submission. Please try again.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      });
    } else if (lesson.contentType == 'text') {
      Get.toNamed(RouteName.contentLession, arguments: lesson)?.then((result) {
        if (result == true) {
          markLessonCompleted();
        }
      });
    }
  }

  void submitLesson(Lesson lesson) async {
    if (isCourseSubmitted.value || lesson.isCompleted!) {
      Get.snackbar(
        'Info',
        lesson.isCompleted!
            ? 'Lesson already completed.'
            : 'Course already submitted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }
    currentLesson.value = lesson;
    await markLessonCompleted();
  }

  void handleEnroll() async {
    isLoading.value = true;
    if (allLessons.isNotEmpty) {
      playLesson(allLessons[0], 0);
    }
    isLoading.value = false;
  }

  void togglePlayPause() {
    final controller = videoPlayerController.value;
    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
        showControls.value = true;
        _hideControlsTimer?.cancel();
      } else {
        controller.play();
        showControls.value = true;
        _startHideControlsTimer();
      }
      // Force immediate UI update with specific ID for faster response
      update(['video_controls']);
    }
  }

  void toggleControlsVisibility() {
    showControls.value = !showControls.value;

    if (showControls.value &&
        videoPlayerController.value?.value.isPlaying == true) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }

    // Update only controls
    update(['video_controls']);
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (videoPlayerController.value?.value.isPlaying == true) {
        showControls.value = false;
        update(['video_controls']);
      }
    });
  }

  void toggleOrientation() {
    isLandscape.value = !isLandscape.value;
    SystemChrome.setPreferredOrientations([
      isLandscape.value
          ? DeviceOrientation.landscapeRight
          : DeviceOrientation.portraitUp,
    ]);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void onClose() {
    // Dispose all preloaded controllers
    _preloadedVideoControllers.values.forEach((controller) {
      controller.dispose();
    });
    _preloadedVideoControllers.clear();
    _preloadStatus.clear();

    videoPlayerController.value?.removeListener(_videoPlayerListener);
    if (!_preloadedVideoControllers
        .containsValue(videoPlayerController.value)) {
      videoPlayerController.value?.dispose();
    }

    tabController.dispose();
    _hideControlsTimer?.cancel();
    reviewTextController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.onClose();
  }

  Future<void> fetchCourseProgress(String? courseId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        Utils.snackBar(
          'Authentication Error',
          'Please log in to view course progress.',
        );
        Get.offNamed(RouteName.loginScreen);
        return;
      }

      final url =
          '${ApiUrls.baseUrl}/connect/v1/api/user/course/progress/$courseId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${user.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        courseProgress.value = CourseProgressModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        Utils.snackBar(
          'Session Expired',
          'Please log in again.',
        );
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
      } else {
        throw Exception('Failed to fetch course progress: ${response.body}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();

      String message;
      if (e.toString().contains('SocketException')) {
        message = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('TimeoutException')) {
        message = 'Request timed out. Please try again later.';
      } else if (e.toString().contains('401')) {
        message = 'Session expired. Please log in again.';
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
        return;
      } else if (e.toString().contains('404')) {
        message = 'Course progress not found. Verify the course ID.';
      } else {
        message = 'Failed to load course progress.';
      }

      Utils.snackBar(
        message,
        'Info',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
