import 'dart:async';
import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../view/userSelfProfile/widgets/clip_play_screen.dart';
import 'get_clip_by_id_controller.dart';

class ClipPlayController extends GetxController with WidgetsBindingObserver {
  final GetClipByIdController clipByIdController =
      Get.find<GetClipByIdController>();
  var videoPlayerController = Rxn<VideoPlayerController>();
  var chewieController = Rxn<ChewieController>();
  var isMuted = false.obs;
  var showPlayPauseIcon = false.obs;

  Timer? _iconTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance
        .addObserver(this); // Add observer for lifecycle events
    final String clipId = Get.arguments ?? "";
    if (clipId.isNotEmpty) {
      clipByIdController.fetchClipById(clipId);
      log('inside clip play controller $clipId');
    }
  }

  void initPlayer(String videoUrl) {
    videoPlayerController.value = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      formatHint:
          videoUrl.endsWith('.m3u8') ? VideoFormat.hls : VideoFormat.other,
    );

    videoPlayerController.value!.initialize().then((_) {
      chewieController.value = ChewieController(
        videoPlayerController: videoPlayerController.value!,
        autoPlay: false,
        looping: true,
        showControls: true,
        showOptions: false,
        // aspectRatio: 9 / 16,
        allowMuting: true,
        allowFullScreen: true,
        customControls: const InstagramControls(),
      );
      videoPlayerController.value!.play();
      update();
    }).catchError((error) {
      Get.snackbar("Error", "Failed to load video: $error");
    });
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    videoPlayerController.value?.setVolume(isMuted.value ? 0 : 1);
  }

  void togglePlayPause() {
    if (videoPlayerController.value == null) return;

    if (videoPlayerController.value!.value.isPlaying) {
      videoPlayerController.value!.pause();
      _showPlayPauseIconTemporarily();
    } else {
      videoPlayerController.value!.play();
      _showPlayPauseIconTemporarily();
    }
    update();
  }

  void _showPlayPauseIconTemporarily() {
    // Cancel any existing timer
    _iconTimer?.cancel();

    // Show the icon
    showPlayPauseIcon.value = true;

    // Hide after 500 milliseconds
    _iconTimer = Timer(const Duration(milliseconds: 500), () {
      showPlayPauseIcon.value = false;
    });
  }

  void pauseVideo() {
    if (videoPlayerController.value != null &&
        videoPlayerController.value!.value.isPlaying) {
      videoPlayerController.value!.pause();
    }
  }

  void resumeVideo() {
    if (videoPlayerController.value != null &&
        !videoPlayerController.value!.value.isPlaying) {
      videoPlayerController.value!.play();
    }
  }

  void toggleLike(String clipId) async {
    final clip = clipByIdController.clipData.value!;
    clip.isLiked = !(clip.isLiked ?? false);
    clip.likeCount = clip.isLiked == true
        ? (clip.likeCount ?? 0) + 1
        : (clip.likeCount ?? 0) - 1;
    clipByIdController.clipData.refresh();
    // TODO: Call like/unlike API
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pauseVideo(); // Pause video when app is in background or inactive
    } else if (state == AppLifecycleState.resumed) {
      resumeVideo(); // Resume video when app is back in foreground
    }
  }

  @override
  void onClose() {
    _iconTimer?.cancel(); // Cancel timer
    pauseVideo(); // Ensure video is paused before disposal
    videoPlayerController.value?.dispose();
    chewieController.value?.dispose();
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.onClose();
  }
}
