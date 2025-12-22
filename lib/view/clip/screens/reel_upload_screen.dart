import 'dart:async';
import 'dart:developer';
import 'package:connectapp/models/UserLogin/user_login_model.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view/clip/screens/reeldatamanager.dart';
import 'package:connectapp/view_models/controller/navbar/bottom_bav_bar_controller.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../../res/api_urls/api_urls.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/repostClips/repost_clip_controller.dart';
import '../../userSelfProfile/widgets/comment_bottom_sheet.dart';

// Upload Progress Controller
class UploadProgressController extends GetxController {
  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;
  var uploadingFileName = ''.obs;
  var uploadStatus = ''.obs;

  void startUpload(String fileName) {
    isUploading.value = true;
    uploadProgress.value = 0.0;
    uploadingFileName.value = fileName;
    uploadStatus.value = 'uploading';
  }

  void updateProgress(double progress, {String? status}) {
    uploadProgress.value = progress;
    if (status != null) {
      uploadStatus.value = status;
    }
  }

  void completeUpload() {
    uploadProgress.value = 1.0;
    uploadStatus.value = 'completed';
    Future.delayed(Duration(seconds: 3), () {
      isUploading.value = false;
      uploadProgress.value = 0.0;
      uploadingFileName.value = '';
      uploadStatus.value = '';
    });
  }

  void failUpload(String error) {
    uploadStatus.value = 'failed';
    Future.delayed(Duration(seconds: 5), () {
      isUploading.value = false;
      uploadProgress.value = 0.0;
      uploadingFileName.value = '';
      uploadStatus.value = '';
    });
  }

  void cancelUpload() {
    isUploading.value = false;
    uploadProgress.value = 0.0;
    uploadingFileName.value = '';
    uploadStatus.value = '';
  }
}

// Video Controller Manager - Manages controllers for efficient memory usage
class VideoControllerManager {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _initializedControllers = {};
  final int maxCachedControllers = 5; // Keep only 5 controllers in memory

  Future<VideoPlayerController?> getOrCreateController(
    String clipId,
    String videoUrl,
  ) async {
    // Return existing controller if available
    if (_controllers.containsKey(clipId)) {
      log('Reusing existing controller for clip: $clipId');
      return _controllers[clipId];
    }

    // Clean up old controllers if we have too many
    if (_controllers.length >= maxCachedControllers) {
      _cleanupOldControllers();
    }

    try {
      log('Creating new controller for clip: $clipId');
      final controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      controller.setLooping(true);

      _controllers[clipId] = controller;
      _initializedControllers[clipId] = true;

      log('Controller initialized successfully for clip: $clipId');
      return controller;
    } catch (e) {
      log('Error creating controller for clip $clipId: $e');
      return null;
    }
  }

  void _cleanupOldControllers() {
    if (_controllers.length <= maxCachedControllers) return;

    // Remove oldest controllers (keep most recent 3)
    final keys = _controllers.keys.toList();
    final toRemove = keys.take(keys.length - 3).toList();

    for (final key in toRemove) {
      log('Disposing old controller: $key');
      _controllers[key]?.dispose();
      _controllers.remove(key);
      _initializedControllers.remove(key);
    }
  }

  void pauseAll() {
    for (final controller in _controllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void disposeController(String clipId) {
    if (_controllers.containsKey(clipId)) {
      log('Disposing controller: $clipId');
      _controllers[clipId]?.dispose();
      _controllers.remove(clipId);
      _initializedControllers.remove(clipId);
    }
  }

  void disposeAll() {
    log('Disposing all controllers');
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initializedControllers.clear();
  }

  bool isInitialized(String clipId) {
    return _initializedControllers[clipId] == true;
  }
}

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  final repostController = Get.put(RepostClipController());
  final uploadProgressController = Get.put(UploadProgressController());
  final VideoControllerManager _videoControllerManager =
      VideoControllerManager();

  int currentIndex = 0;
  bool _isPageActive = true;
  bool _isCurrentTab = false;

  late ReelsDataManager _reelsManager;
  late NavbarController _navController;

  static const int clipsToPreload = 2; // Reduced from 3 for better performance

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _reelsManager = ReelsDataManager.instance;

    try {
      _navController = Get.find<NavbarController>();
      final initialIndex = _navController.currentIndex.value;
      _isCurrentTab = initialIndex == 2;

      _navController.currentIndex.listen((index) {
        if (mounted) {
          final wasCurrentTab = _isCurrentTab;
          final isNowCurrentTab = index == 2;

          setState(() {
            _isCurrentTab = isNowCurrentTab;
          });

          if (!wasCurrentTab && isNowCurrentTab) {
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {});
              }
            });
          } else if (wasCurrentTab && !isNowCurrentTab) {
            // Pause all videos when leaving tab
            _videoControllerManager.pauseAll();
          }
        }
      });
    } catch (e) {
      _isCurrentTab = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _isPageActive = state == AppLifecycleState.resumed;
    });

    if (state != AppLifecycleState.resumed) {
      _videoControllerManager.pauseAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _videoControllerManager.disposeAll();
    super.dispose();
  }

  void _checkAndLoadMore() {
    final remainingClips = _reelsManager.clips.length - currentIndex;
    log('Current index: $currentIndex, Total clips: ${_reelsManager.clips.length}, Remaining: $remainingClips');

    if (remainingClips <= clipsToPreload && _reelsManager.hasNextPage.value) {
      log('Triggering load more clips');
      _reelsManager.loadMoreClips();
    }
  }

  void _navigateToUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadVideoPage(),
      ),
    );
  }

  Future<void> _refreshReels() async {
    await _reelsManager.refreshClips();
    // Reset to first page after refresh
    if (_pageController.hasClients && _reelsManager.clips.isNotEmpty) {
      _pageController.jumpToPage(0);
      setState(() {
        currentIndex = 0;
      });
    }
  }

  void _updateClipFollowStatus(
      String userId, bool isFollowing, int followerCount) {
    _reelsManager.updateClipFollowStatus(userId, isFollowing, followerCount);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() => _buildBody()),

          // Upload Progress Indicator (keeping your existing code)
          Obx(() {
            if (uploadProgressController.isUploading.value) {
              final status = uploadProgressController.uploadStatus.value;
              final progress = uploadProgressController.uploadProgress.value;

              Color statusColor = Colors.blue;
              IconData statusIcon = Icons.cloud_upload_outlined;

              if (status == 'processing') {
                statusColor = Colors.orange;
                statusIcon = Icons.sync;
              } else if (status == 'completed') {
                statusColor = Colors.green;
                statusIcon = Icons.check_circle_outline;
              } else if (status == 'failed') {
                statusColor = Colors.red;
                statusIcon = Icons.error_outline;
              }

              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: status == 'processing'
                                  ? Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: statusColor,
                                      ),
                                    )
                                  : Icon(
                                      statusIcon,
                                      color: statusColor,
                                      size: 20,
                                    ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    status == 'completed'
                                        ? 'Upload Complete!'
                                        : status == 'failed'
                                            ? 'Upload Failed'
                                            : status == 'processing'
                                                ? 'Processing Clip'
                                                : 'Uploading Clip',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    uploadProgressController
                                        .uploadingFileName.value,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (status != 'completed' && status != 'failed')
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (status == 'completed')
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 24),
                            if (status == 'failed')
                              IconButton(
                                icon: Icon(Icons.close,
                                    color: Colors.white, size: 20),
                                onPressed: () =>
                                    uploadProgressController.cancelUpload(),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[800],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_reelsManager.isInitialized.value && _reelsManager.isLoading.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading Clips...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preparing your feed',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_reelsManager.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                _reelsManager.errorMessage.value,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _reelsManager.refreshClips(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.refresh, size: 22),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_reelsManager.clips.isEmpty && _reelsManager.isInitialized.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.blue.withOpacity(0.3)
                    ],
                  ),
                ),
                child: Icon(
                  Icons.video_library_outlined,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'No Clips Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Be the first to share a Clip!',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _navigateToUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.add_circle_outline, size: 22),
                label: Text(
                  'Create Clip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: _refreshReels,
                icon: Icon(Icons.refresh, color: Colors.grey[400]),
                label: Text(
                  'Refresh',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshReels,
          backgroundColor: Colors.white,
          color: Colors.black,
          strokeWidth: 3,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              log('Page changed to index: $index');
              setState(() {
                currentIndex = index;
              });
              _checkAndLoadMore();
            },
            itemCount: _reelsManager.clips.length,
            itemBuilder: (context, index) {
              final shouldPlay =
                  index == currentIndex && _isPageActive && _isCurrentTab;

              return ReelItem(
                key: ValueKey(_reelsManager.clips[index]['_id']),
                clip: _reelsManager.clips[index],
                isCurrentPage: shouldPlay,
                onAddPressed: _navigateToUpload,
                onFollowStatusChanged: _updateClipFollowStatus,
                videoControllerManager: _videoControllerManager,
              );
            },
          ),
        ),
        if (_reelsManager
            .isLoadingMore.value) // Use isLoadingMore instead of isLoading
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ReelItem remains mostly the same, just update the _navigateToUpload call

// ReelItem with optimized video controller management
class ReelItem extends StatefulWidget {
  final dynamic clip;
  final bool isCurrentPage;
  final VoidCallback onAddPressed;
  final Function(String userId, bool isFollowing, int followerCount)
      onFollowStatusChanged;
  final VideoControllerManager videoControllerManager;

  const ReelItem({
    super.key,
    required this.clip,
    required this.isCurrentPage,
    required this.onAddPressed,
    required this.onFollowStatusChanged,
    required this.videoControllerManager,
  });

  @override
  _ReelItemState createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool isLiked = false;
  bool isVideoReady = false;
  bool showFullCaption = false;
  bool showAllTags = false;
  int currentCommentCount = 0;
  bool _isManuallyPaused = false;
  Timer? _singleTapTimer;
  Timer? _pauseIndicatorTimer;
  bool _showPauseIndicator = false;

  bool _showLikeAnimation = false;
  int _lastTapTime = 0;
  static const int doubleTapTimeLimit = 300;

  bool isFollowing = false;
  int followerCount = 0;
  bool isFollowLoading = false;

  String? _selectedReportReason;
  String _reportDescription = '';
  final TextEditingController _reportDescriptionController =
      TextEditingController();

  bool _isInitializingVideo = false;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    isLiked = widget.clip['isLiked'] ?? false;
    currentCommentCount = widget.clip['commentCount'] ?? 0;

    final user = widget.clip['userId'];
    followerCount = user['followerCount'] ?? 0;
    isFollowing = widget.clip['isFollowing'] ?? false;

    // Initialize video if this is the current page
    if (widget.isCurrentPage) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.clip != widget.clip) {
      final user = widget.clip['userId'];
      followerCount = user['followerCount'] ?? 0;
      isFollowing = widget.clip['isFollowing'] ?? false;
    }

    // Handle page changes
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      // This clip is now visible
      log('Clip ${widget.clip['_id']} became visible');
      _initializeVideo();
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      // This clip is no longer visible
      log('Clip ${widget.clip['_id']} hidden');
      if (_controller != null && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  void _initializeVideo() async {
    if (_isInitializingVideo) {
      log('Already initializing video for ${widget.clip['_id']}');
      return;
    }

    final processedUrl = widget.clip['processedUrl'];
    if (processedUrl == null || processedUrl.isEmpty) {
      log('No processed URL for clip ${widget.clip['_id']}');
      setState(() {
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isInitializingVideo = true;
      _hasError = false;
    });

    try {
      log('Initializing video for clip: ${widget.clip['_id']}');

      // Use the controller manager to get or create controller
      final controller =
          await widget.videoControllerManager.getOrCreateController(
        widget.clip['_id'],
        processedUrl,
      );

      if (controller == null) {
        throw Exception('Failed to create video controller');
      }

      if (mounted) {
        setState(() {
          _controller = controller;
          isVideoReady = true;
          _isInitializingVideo = false;
        });

        // Auto-play if this is the current page and not manually paused
        if (widget.isCurrentPage && !_isManuallyPaused) {
          _controller!.play();
          log('Started playing clip: ${widget.clip['_id']}');
        }

        _controller!.addListener(_videoStateListener);
      }
    } catch (error) {
      log('Error initializing video for ${widget.clip['_id']}: $error');
      if (mounted) {
        setState(() {
          isVideoReady = false;
          _isInitializingVideo = false;
          _hasError = true;
        });
      }
    }
  }

  void _videoStateListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    _pauseIndicatorTimer?.cancel();
    _reportDescriptionController.dispose();

    // Remove listener but don't dispose controller - it's managed by VideoControllerManager
    _controller?.removeListener(_videoStateListener);

    super.dispose();
  }

  void _pauseVideoForNavigation() {
    if (_controller != null && _controller!.value.isPlaying) {
      _controller!.pause();
      setState(() {
        _isManuallyPaused = true;
        _showPauseIndicator = true;
      });
    }
  }

  // Keep all your existing methods (toggleLike, toggleFollow, share, etc.)
  Future<void> _toggleLike() async {
    final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData!.token;

    setState(() {
      isLiked = !isLiked;
    });

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/clip/toggle-like/${widget.clip['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isLiked = data['liked'] ?? isLiked;
        });
      }
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (isFollowLoading) return;

    final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData?.token;
    final userId = widget.clip['userId']['_id'];

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to perform action'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool currentFollowState = isFollowing;
    final int currentFollowerCount = followerCount;

    setState(() {
      isFollowLoading = true;
    });

    setState(() {
      isFollowing = !currentFollowState;
      if (currentFollowState) {
        followerCount = currentFollowerCount - 1;
      } else {
        followerCount = currentFollowerCount + 1;
      }
    });

    widget.onFollowStatusChanged(userId, !currentFollowState, followerCount);

    try {
      http.Response response;

      if (currentFollowState) {
        response = await http.delete(
          Uri.parse(
              '${ApiUrls.baseUrl}/connect/v1/api/social/unfollow-user/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } else {
        response = await http.post(
          Uri.parse(
              '${ApiUrls.baseUrl}/connect/v1/api/social/follow-user/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                (!currentFollowState
                    ? 'Followed successfully'
                    : 'Unfollowed successfully')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          isFollowing = currentFollowState;
          followerCount = currentFollowerCount;
        });

        widget.onFollowStatusChanged(
            userId, currentFollowState, currentFollowerCount);

        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                'Failed to ${currentFollowState ? 'unfollow' : 'follow'} user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isFollowing = currentFollowState;
        followerCount = currentFollowerCount;
      });

      widget.onFollowStatusChanged(
          userId, currentFollowState, currentFollowerCount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isFollowLoading = false;
      });
    }
  }

  Future<void> _shareClip() async {
    try {
      final clipId = widget.clip['_id'];
      final user = widget.clip['userId'];
      final username = user['username'] ?? 'user';
      final caption = widget.clip['caption'] ?? '';

      final deepLink = _generateDeepLink(clipId);

      String shareText = 'Check out this awesome Clip by @$username';
      if (caption.isNotEmpty) {
        shareText += '\n\n"$caption"';
      }
      shareText +=
          '\n\n$deepLink\n\nDownload ConnectApp: https://play.google.com/store/apps/details?id=app.connectapp.com';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Preparing to share...'),
            ],
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.blue,
        ),
      );

      await Share.share(
        shareText,
        subject: 'Check out this Clip!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share clip'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Share this Clip',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildShareOption(
                      icon: Icons.copy,
                      title: 'Copy Link',
                      onTap: () async {
                        final clipId = widget.clip['_id'];
                        final deepLink = _generateDeepLink(clipId);
                        await Clipboard.setData(ClipboardData(text: deepLink));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildShareOption(
                      icon: Icons.share,
                      title: 'Share to Other Apps',
                      onTap: () {
                        Navigator.pop(context);
                        _shareClip();
                      },
                    ),
                    const Divider(height: 1),
                    _buildShareOption(
                      icon: Icons.share,
                      title: 'Share via WhatsApp',
                      onTap: () async {
                        Navigator.pop(context);
                        final clipId = widget.clip['_id'];
                        final user = widget.clip['userId'];
                        final username = user['username'] ?? 'user';
                        final deepLink = _generateDeepLink(clipId);

                        final message =
                            'Check out this Clip by @$username!\n\n$deepLink\n\nDownload ConnectApp: https://play.google.com/store/apps/details?id=app.connectapp.com';
                        final whatsappUrl =
                            'whatsapp://send?text=${Uri.encodeComponent(message)}';

                        try {
                          final uri = Uri.parse(whatsappUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            await Share.share(message,
                                subject: 'Check out this Clip!');
                          }
                        } catch (e) {
                          await Share.share(message,
                              subject: 'Check out this Clip!');
                        }
                      },
                    ),
                    const Divider(height: 1),
                    _buildShareOption(
                      icon: Icons.message,
                      title: 'Send via Message',
                      onTap: () async {
                        Navigator.pop(context);
                        final clipId = widget.clip['_id'];
                        final user = widget.clip['userId'];
                        final username = user['username'] ?? 'user';
                        final deepLink = _generateDeepLink(clipId);

                        await Share.share(
                          'Check out this Clip by @$username!\n\n$deepLink\n\nDownload ConnectApp: https://play.google.com/store/apps/details?id=app.connectapp.com',
                          subject: 'Check out this Clip!',
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildShareOption(
                      icon: Icons.more_horiz,
                      title: 'More Options',
                      onTap: () async {
                        Navigator.pop(context);
                        final clipId = widget.clip['_id'];
                        final user = widget.clip['userId'];
                        final username = user['username'] ?? 'user';
                        final caption = widget.clip['caption'] ?? '';
                        final deepLink = _generateDeepLink(clipId);

                        String shareText =
                            'Check out this awesome Clip by @$username';
                        if (caption.isNotEmpty) {
                          shareText += '\n\n"$caption"';
                        }
                        shareText +=
                            '\n\n$deepLink\n\nDownload ConnectApp: https://play.google.com/store/apps/details?id=app.connectapp.com';

                        await Share.share(shareText,
                            subject: 'Check out this Clip!');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _generateDeepLink(String clipId) {
    return 'https://connectapp.cc/clip/$clipId';
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
                size: 22,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    _singleTapTimer?.cancel();

    if (currentTime - _lastTapTime < doubleTapTimeLimit) {
      _handleDoubleTap();
      _lastTapTime = 0;
    } else {
      _lastTapTime = currentTime;
      _singleTapTimer = Timer(Duration(milliseconds: doubleTapTimeLimit), () {
        if (mounted && _lastTapTime != 0) {
          _handleSingleTap();
          _lastTapTime = 0;
        }
      });
    }
  }

  void _handleSingleTap() {
    if (_controller != null && mounted) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          _isManuallyPaused = true;
          _showPauseIndicator = true;
        } else {
          _controller!.play();
          _isManuallyPaused = false;
          _showPauseIndicator = false;
        }
      });

      if (_isManuallyPaused) {
        _pauseIndicatorTimer?.cancel();
        _pauseIndicatorTimer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showPauseIndicator = false;
            });
          }
        });
      }
    }
  }

  void _handleDoubleTap() {
    _toggleLike();
    _showLikeAnimationEffect();
  }

  void _handlePlayIconTap() {
    if (_controller != null && mounted && _isManuallyPaused) {
      setState(() {
        _controller!.play();
        _isManuallyPaused = false;
        _showPauseIndicator = false;
      });
      _pauseIndicatorTimer?.cancel();
    }
  }

  void _showLikeAnimationEffect() {
    setState(() {
      _showLikeAnimation = true;
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showLikeAnimation = false;
        });
      }
    });
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        clipId: widget.clip['_id'],
      ),
    );
  }

  // Keep your existing report methods...
  void _showReportDialog(BuildContext context) {
    _selectedReportReason = null;
    _reportDescription = '';
    _reportDescriptionController.clear();

    final user = widget.clip['userId'];
    final fullName = user['fullName'] ?? 'Unknown User';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please provide details about the issue you\'re reporting.',
                      style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reported User',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: Text(
                        fullName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reason',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReportReason,
                          hint: const Text('Select a reason'),
                          isExpanded: true,
                          items: [
                            'spam',
                            'abuse',
                            'misleading',
                            'inappropriate',
                            'other'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedReportReason = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reportDescriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Please provide additional details about the report...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        _reportDescription = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _submitReport(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(BuildContext context) async {
    try {
      if (_selectedReportReason == null || _selectedReportReason!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill in all required fields"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final UserPreferencesViewmodel userPreferences =
          UserPreferencesViewmodel();
      LoginResponseModel? userData = await userPreferences.getUser();
      final token = userData!.token;

      final reportedUserId = widget.clip['userId']['_id'];
      if (reportedUserId == null) {
        throw Exception("Unable to get user ID");
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Submitting report..."),
              ],
            ),
          );
        },
      );

      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/report/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reportedUser': reportedUserId,
          'reason': _selectedReportReason,
          'description': _reportDescription,
        }),
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        _selectedReportReason = null;
        _reportDescription = '';
        _reportDescriptionController.clear();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit report');
      }
    } catch (error) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      final errorMessage = error.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              errorMessage.isEmpty ? "Report submission failed" : errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getTruncatedCaption(String caption, {int maxLength = 100}) {
    if (caption.length <= maxLength) return caption;
    return '${caption.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final user = widget.clip['userId'];
    final subscription = widget.clip['userId']['subscription'];
    final status = subscription?['status'];

    final likeCount = widget.clip['likeCount'] ?? 0;
    final commentCount = widget.clip['commentCount'] ?? 0;
    final caption = widget.clip['caption'] ?? '';
    final tags = widget.clip['tags'] as List<dynamic>? ?? [];

    final userAvatar = user['avatar']?['imageUrl'];
    final username = user['username'] ?? 'Unknown';

    final bool isActivePremium = status?.toString() == 'Active';

    void navigateToProfile(BuildContext context, String userId) {
      _pauseVideoForNavigation();
      Get.toNamed(RouteName.clipProfieScreen, arguments: userId);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player or Thumbnail
        Positioned.fill(
          child: _controller != null && isVideoReady
              ? GestureDetector(
                  onTap: _handleTap,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              : Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.clip['thumbnailUrl'] ?? '',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.black,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.black,
                              child: Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                        if (_isInitializingVideo)
                          // Container(
                          //   color: Colors.black.withOpacity(0.5),
                          //   child: Center(
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         CircularProgressIndicator(
                          //             color: Colors.white),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          if (_hasError)
                            Container(
                              color: Colors.black.withOpacity(0.7),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Failed to load video',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _hasError = false;
                                        });
                                        _initializeVideo();
                                      },
                                      child: Text(
                                        'Retry',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
        ),

        // Like Animation
        if (_showLikeAnimation)
          Center(
            child: AnimatedScale(
              scale: _showLikeAnimation ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: AnimatedOpacity(
                opacity: _showLikeAnimation ? 1.0 : 0.0,
                duration: Duration(milliseconds: 800),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),

        // Pause Indicator
        if (_controller != null &&
            isVideoReady &&
            _isManuallyPaused &&
            _showPauseIndicator)
          Center(
            child: GestureDetector(
              onTap: _handlePlayIconTap,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),

        // Bottom Gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Action Buttons (Right Side)
        Positioned(
          right: 16,
          bottom: 20,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _pauseVideoForNavigation();
                  widget.onAddPressed();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.purple,
                        Colors.pink,
                      ],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
                count: likeCount + (isLiked && !widget.clip['isLiked'] ? 1 : 0),
                onTap: _toggleLike,
              ),
              SizedBox(height: 10),
              ActionButton(
                icon: Icons.chat_bubble_outline,
                color: Colors.white,
                count: commentCount,
                onTap: _showCommentsBottomSheet,
              ),
              SizedBox(height: 10),
              Obx(() {
                final repostController = Get.put(RepostClipController());
                final isReposted =
                    repostController.repostedClips.contains(widget.clip['_id']);

                return GestureDetector(
                  onTap: () {
                    repostController.toggleRepostClip(widget.clip['_id']);
                  },
                  child: AnimatedScale(
                    scale: isReposted ? 1.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: Icon(
                        PhosphorIconsRegular.repeat,
                        color: isReposted ? Colors.green : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 10),
              ActionButton(
                icon: Icons.send_outlined,
                color: Colors.white,
                count: 0,
                onTap: _showShareBottomSheet,
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _showReportDialog(context);
                },
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        // User Info and Caption (Bottom Left)
        Positioned(
          left: 16,
          right: 80,
          bottom: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => navigateToProfile(context, user['_id']),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: userAvatar != null
                            ? Image.network(
                                userAvatar,
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      navigateToProfile(context, user['_id']);
                    },
                    child: Text(
                      '@$username',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  if (isActivePremium) ...[
                    SizedBox(width: 6),
                    Icon(
                      Icons.workspace_premium,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ],
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: isFollowLoading ? null : _toggleFollow,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFollowing
                            ? Colors.transparent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isFollowing ? Colors.grey[600]! : Colors.white,
                          width: 1,
                        ),
                      ),
                      child: isFollowLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    isFollowing ? Colors.white : Colors.black,
                              ),
                            )
                          : Text(
                              isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                color:
                                    isFollowing ? Colors.white : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.helveticaBold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFullCaption = !showFullCaption;
                  });
                },
                child: Text(
                  showFullCaption ? caption : _getTruncatedCaption(caption),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: showFullCaption ? null : 3,
                  overflow: showFullCaption ? null : TextOverflow.ellipsis,
                ),
              ),
              if (!showFullCaption && caption.length > 100)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFullCaption = true;
                    });
                  },
                  child: Text(
                    'more',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(height: 8),
              if (tags.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: (showAllTags ? tags : tags.take(8))
                          .map<Widget>((tag) {
                        return Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList(),
                    ),
                    if (tags.length > 8)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllTags = !showAllTags;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            showAllTags ? 'less' : 'more',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),

        // Progress Indicator
        if (_controller != null && isVideoReady)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          if (count > 0)
            Text(
              count > 999 ? '${(count / 1000).toStringAsFixed(1)}K' : '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// Keep all your existing UploadVideoPage, VideoPreviewPage, and AddCaptionPage code unchanged...

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  File? selectedVideo;
  bool isUploading = false;
  final ReelsDataManager _reelsManager = ReelsDataManager.instance;

  Future<void> _pickVideo() async {
    if (!_reelsManager.areUploadDetailsReady) {
      await _reelsManager.refreshUploadDetails();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        selectedVideo = File(result.files.single.path!);
      });
      _navigateToPreview();
    }
  }

  void _navigateToPreview() {
    if (selectedVideo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewPage(
            videoFile: selectedVideo!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text(
          'Upload New Clip',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (_reelsManager.isUploadDetailsLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Preparing upload...',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        if (_reelsManager.uploadDetailsError.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: Icon(Icons.error, color: Colors.red, size: 50),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Failed to prepare upload',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _reelsManager.uploadDetailsError.value,
                    style: TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _reelsManager.refreshUploadDetails(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blackColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.refresh, size: 22),
                    label: Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.greyColor.withOpacity(0.3),
                  width: 2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.05),
                    Colors.blue.withOpacity(0.05),
                  ],
                ),
              ),
              child: InkWell(
                onTap: _pickVideo,
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.2),
                            Colors.blue.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 60,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      'Drop your video here',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'or click to browse files',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'MP4, MOV, AVI • Max 100MB',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Video Preview Page with enhanced design
class VideoPreviewPage extends StatefulWidget {
  final File videoFile;

  const VideoPreviewPage({
    super.key,
    required this.videoFile,
  });

  @override
  _VideoPreviewPageState createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  VideoPlayerController? _controller;
  bool isPlaying = false;
  final ReelsDataManager _reelsManager = ReelsDataManager.instance;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        isPlaying = false;
      } else {
        _controller!.play();
        isPlaying = true;
      }
    });
  }

  void _navigateToCaption() {
    if (_reelsManager.areUploadDetailsReady) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCaptionPage(
            videoFile: widget.videoFile,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload preparation failed. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Preview Video',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller != null && _controller!.value.isInitialized)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  else
                    CircularProgressIndicator(color: Colors.white),
                  if (_controller != null && _controller!.value.isInitialized)
                    Positioned(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              path.basename(widget.videoFile.path),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${(widget.videoFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                              style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 14,
                                  fontFamily: AppFonts.opensansRegular),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Obx(() {
                    final areUploadDetailsReady =
                        _reelsManager.areUploadDetailsReady;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            areUploadDetailsReady ? _navigateToCaption : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: areUploadDetailsReady
                              ? AppColors.blackColor
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add Caption Page with enhanced design and upload progress
class AddCaptionPage extends StatefulWidget {
  final File videoFile;

  const AddCaptionPage({
    super.key,
    required this.videoFile,
  });

  @override
  _AddCaptionPageState createState() => _AddCaptionPageState();
}

class _AddCaptionPageState extends State<AddCaptionPage> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> tags = [];
  bool isUploading = false;
  final ReelsDataManager _reelsManager = ReelsDataManager.instance;
  final uploadProgressController = Get.find<UploadProgressController>();

  void _addTag() {
    String tag = _tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  Future<void> _uploadClip() async {
    if (!_reelsManager.areUploadDetailsReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Upload preparation incomplete. Please try again.')),
      );
      return;
    }

    final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData!.token;

    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a caption')),
      );
      return;
    }

    // Start upload in background
    uploadProgressController.startUpload(path.basename(widget.videoFile.path));

    // Navigate back immediately - upload continues in background
    Navigator.popUntil(context, (route) => route.isFirst);

    // Show a toast that upload has started
    Get.snackbar(
      'Upload Started',
      'Your clip is being uploaded in the background',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      icon: Icon(Icons.cloud_upload, color: Colors.blue),
      duration: Duration(seconds: 2),
    );

    // Perform upload in background
    _performBackgroundUpload(token);
  }

// 3. New method for background upload
  Future<void> _performBackgroundUpload(String token) async {
    try {
      String tagsString = tags.isNotEmpty
          ? tags.map((tag) => tag.startsWith('#') ? tag : '#$tag').join(' ')
          : '#general';

      String clipId = _reelsManager.savedClipId.value;

      Map<String, dynamic> requestBody = {
        'caption': _captionController.text.trim(),
        'tags': tagsString,
        'clipId': clipId,
      };

      log('Request body: ${json.encode(requestBody)}');
      log('Using Clip ID: $clipId');

      // Update progress to 10%
      uploadProgressController.updateProgress(0.1, status: 'Preparing...');

      // Step 1: Save metadata
      final metadataResponse = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/clip/add-initial-clip-data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      log('Metadata response status code: ${metadataResponse.statusCode}');

      if (metadataResponse.statusCode == 200 ||
          metadataResponse.statusCode == 201) {
        uploadProgressController.updateProgress(0.2,
            status: 'Uploading video...');

        // Step 2: Upload video file
        String uploadUrl = _reelsManager.savedUploadUrl.value;
        if (uploadUrl.isNotEmpty) {
          log('Starting video upload to: $uploadUrl');

          final videoBytes = await widget.videoFile.readAsBytes();
          final totalBytes = videoBytes.length;
          log('Video file size: $totalBytes bytes');

          // Simulate smooth upload progress
          _simulateUploadProgress();

          final uploadResponse = await http.put(
            Uri.parse(uploadUrl),
            headers: {
              'Content-Type': 'video/mp4',
              'Content-Length': totalBytes.toString(),
            },
            body: videoBytes,
          );

          log('Video upload response status: ${uploadResponse.statusCode}');

          if (uploadResponse.statusCode == 200) {
            uploadProgressController.updateProgress(0.95,
                status: 'Finalizing...');

            // Wait a moment for backend processing
            await Future.delayed(Duration(seconds: 1));

            uploadProgressController.completeUpload();

            // Show success notification
            Get.snackbar(
              'Upload Complete!',
              'Your clip has been uploaded successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              icon: Icon(Icons.check_circle, color: Colors.white),
              duration: Duration(seconds: 3),
            );

            // Refresh clips to show the new one
            _reelsManager.refreshClips();
          } else {
            log('Upload response body: ${uploadResponse.body}');
            throw Exception(
                'Failed to upload video: ${uploadResponse.statusCode}');
          }
        } else {
          throw Exception('Upload URL is not available');
        }
      } else {
        String errorMessage = 'Failed to save metadata';
        try {
          final errorBody = json.decode(metadataResponse.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          // Keep default error message
        }
        throw Exception(
            '$errorMessage (Status: ${metadataResponse.statusCode})');
      }
    } catch (e) {
      log('Upload error: $e');
      uploadProgressController.failUpload(e.toString());

      // Show error notification
      Get.snackbar(
        'Upload Failed',
        'Failed to upload clip}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        duration: Duration(seconds: 5),
      );
    }
  }

// Add this helper method to simulate smooth progress
  void _simulateUploadProgress() async {
    // Simulate progress from 20% to 85%
    for (double progress = 0.2; progress <= 0.85; progress += 0.05) {
      uploadProgressController.updateProgress(progress, status: 'Uploading...');
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Add Description',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final areUploadDetailsReady = _reelsManager.areUploadDetailsReady;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!areUploadDetailsReady)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Upload preparation incomplete',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _reelsManager.refreshUploadDetails(),
                        child: Text('Retry',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                ),

              // Add Caption Section
              Text(
                'Add Caption',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.greyColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _captionController,
                  cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
                  cursorHeight: 22,
                  maxLines: 5,
                  maxLength: 500,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'What\'s your clip about? Make it engaging...',
                    hintStyle: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 15,
                        fontFamily: AppFonts.opensansRegular),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    counterStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Add Tags Section
              Text(
                '# Add Tags',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.greyColor.withOpacity(0.3)),
                      ),
                      child: TextField(
                        cursorColor:
                            Theme.of(context).textTheme.bodyLarge?.color,
                        cursorHeight: 22,
                        controller: _tagController,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                        decoration: InputDecoration(
                          hintText: 'Add a tag...',
                          hintStyle: TextStyle(
                              color: AppColors.textColor,
                              fontFamily: AppFonts.opensansRegular),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _addTag,
                      icon: Icon(Icons.add, color: Colors.white, size: 24),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Display added tags
              if (tags.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tags.map((tag) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.8),
                            Colors.blue.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#$tag',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeTag(tag),
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: 40),

              // Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (areUploadDetailsReady && !isUploading)
                      ? _uploadClip
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: areUploadDetailsReady
                        ? AppColors.blackColor
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: areUploadDetailsReady ? 2 : 0,
                  ),
                  child: isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Uploading...',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 22),
                            SizedBox(width: 12),
                            Text(
                              'Upload Clip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
