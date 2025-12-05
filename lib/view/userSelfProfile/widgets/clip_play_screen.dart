import 'package:connectapp/view/userSelfProfile/widgets/comment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../../data/response/status.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/follow/user_follow_controller.dart';
import '../../../view_models/controller/getClipByid/clip_play_controller.dart';
import '../../../view_models/controller/getClipByid/get_clip_by_id_controller.dart';
import '../../../view_models/controller/repostClips/repost_clip_controller.dart';

class ClipPlayScreen extends StatelessWidget {
  const ClipPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clipByIdController = Get.put(GetClipByIdController());
    final ClipPlayController controller = Get.put(ClipPlayController());
    final repostController = Get.find<RepostClipController>();
    final followController = Get.put(FollowUnfollowController());
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        controller.pauseVideo();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Get.offAllNamed(RouteName.bottomNavbar);
              }
            },
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: Colors.black,
        body: Obx(() {
          switch (clipByIdController.rxRequestStatus.value) {
            case Status.LOADING:
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            case Status.ERROR:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      clipByIdController.error.value,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            case Status.COMPLETED:
              final clip = clipByIdController.clipData.value!;
              if (controller.videoPlayerController.value == null &&
                  clip.processedUrl != null) {
                controller.initPlayer(clip.processedUrl!);
              }

              return GestureDetector(
                onTap: controller.togglePlayPause,
                child: Stack(
                  children: [
                    // Video Player
                    Center(
                      child: controller.chewieController.value != null &&
                              controller.videoPlayerController.value!.value
                                  .isInitialized
                          ? AspectRatio(
                              aspectRatio: controller.videoPlayerController
                                  .value!.value.aspectRatio,
                              child: Chewie(
                                controller: controller.chewieController.value!,
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                    ),

                    // Play/Pause Overlay
                    Center(
                      child: Obx(() {
                        if (controller.showPlayPauseIcon.value) {
                          return AnimatedOpacity(
                            opacity:
                                controller.showPlayPauseIcon.value ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                controller.videoPlayerController.value?.value
                                            .isPlaying ??
                                        false
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ),

                    // Bottom User Info
                    Positioned(
                      bottom: size.height * 0.04,
                      left: size.width * 0.03,
                      right: size.width * 0.2,
                      child: _buildUserInfo(
                        context,
                        clip,
                        controller,
                        followController,
                        size,
                      ),
                    ),

                    // Right Side Actions
                    Positioned(
                      bottom: size.height * 0.15,
                      right: size.width * 0.03,
                      child: _buildActionButtons(
                        context,
                        clip,
                        controller,
                        repostController,
                        size,
                      ),
                    ),

                    // Mute Button (Top Right)
                    // Positioned(
                    //   top: size.height * 0.12,
                    //   right: size.width * 0.03,
                    //   child: _buildMuteButton(controller),
                    // ),
                  ],
                ),
              );
          }
        }),
      ),
    );
  }

  Widget _buildUserInfo(
    BuildContext context,
    dynamic clip,
    ClipPlayController controller,
    FollowUnfollowController followController,
    Size size,
  ) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  controller.pauseVideo();
                  Get.toNamed(
                    RouteName.clipProfieScreen,
                    arguments: clip.userId!.sId.toString(),
                  );
                },
                child: _buildUserAvatar(clip, size),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            clip.userId?.fullName ?? "Unknown User",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        _buildFollowButton(
                          clip,
                          followController,
                          size,
                        ),
                      ],
                    ),
                    if (clip.userId?.username != null) ...[
                      SizedBox(height: size.height * 0.003),
                      Text(
                        '@${clip.userId!.username}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: size.width * 0.032,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (clip.tags != null && clip.tags!.isNotEmpty) ...[
            SizedBox(height: size.height * 0.01),
            Text(
              clip.tags!.join(" "),
              style: TextStyle(
                color: Colors.blue.shade300,
                fontSize: size.width * 0.034,
                fontFamily: AppFonts.opensansRegular,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (clip.caption != null && clip.caption!.isNotEmpty) ...[
            SizedBox(height: size.height * 0.008),
            Text(
              clip.caption!,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.036,
                fontFamily: AppFonts.opensansRegular,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar(dynamic clip, Size size) {
    final avatarUrl = clip.userId?.avatar?.imageUrl;
    final fullName = clip.userId?.fullName ?? "U";
    final initials = _getInitials(fullName);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: size.width * 0.055,
        backgroundColor: Colors.grey.shade800,
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: size.width * 0.11,
                  height: size.width * 0.11,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildFollowButton(
    dynamic clip,
    FollowUnfollowController followController,
    Size size,
  ) {
    return Obx(() {
      final userId = clip.userId!.sId.toString();
      final following = followController.isFollowing(userId);

      return GestureDetector(
        onTap: () {
          if (following) {
            followController.unfollowUser(userId);
          } else {
            followController.followUser(userId);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.006,
          ),
          decoration: BoxDecoration(
            gradient: following
                ? null
                : const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.purpleAccent],
                  ),
            color: following ? Colors.grey.shade700 : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: following ? Colors.grey.shade600 : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            following ? "Following" : "Follow",
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.03,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons(
    BuildContext context,
    dynamic clip,
    ClipPlayController controller,
    RepostClipController repostController,
    Size size,
  ) {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.favorite_border,
          color: clip.isLiked == true ? Colors.red : Colors.white,
          count: clip.likeCount?.toString() ?? "0",
          onTap: () => controller.toggleLike(clip.sId!),
          size: size,
        ),
        SizedBox(height: size.height * 0.025),
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          count: clip.commentCount?.toString() ?? "0",
          onTap: () {
            Get.bottomSheet(
              CommentsBottomSheet(clipId: clip.sId.toString()),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
          size: size,
        ),
        SizedBox(height: size.height * 0.025),
        _buildActionButton(
          icon: Icons.repeat_rounded,
          color: clip.isReposted == true ? Colors.green : Colors.white,
          onTap: () => repostController.toggleRepostClip(clip.sId.toString()),
          size: size,
        ),
        SizedBox(height: size.height * 0.025),
        _buildActionButton(
          icon: Icons.share,
          color: Colors.white,
          onTap: () => _showShareBottomSheet(context, clip),
          size: size,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required Size size,
    String count = "",
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(size.width * 0.028),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: size.width * 0.07,
            ),
          ),
        ),
        if (count.isNotEmpty) ...[
          SizedBox(height: size.height * 0.005),
          Text(
            _formatCount(count),
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.032,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(String count) {
    final num = int.tryParse(count) ?? 0;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return count;
  }

  // Widget _buildMuteButton(ClipPlayController controller) {
  //   return Obx(() => GestureDetector(
  //         onTap: controller.toggleMute,
  //         child: Container(
  //           padding: const EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //             color: Colors.black.withOpacity(0.4),
  //             shape: BoxShape.circle,
  //             border: Border.all(
  //               color: Colors.white.withOpacity(0.2),
  //               width: 1,
  //             ),
  //           ),
  //           child: Icon(
  //             controller.isMuted.value ? Icons.volume_off : Icons.volume_up,
  //             color: Colors.white,
  //             size: 24,
  //           ),
  //         ),
  //       ));
  // }s

  void _showShareBottomSheet(BuildContext context, dynamic clip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildShareSheet(context, clip),
    );
  }

  Widget _buildShareSheet(BuildContext context, dynamic clip) {
    final clipId = clip.sId;
    final username = clip.userId?.username ?? "user";
    final deepLink = "https://connectapp.cc/clip/$clipId";

    String shareText =
        'Check out this Clip by @$username!\n\n$deepLink\n\nDownload ConnectApp: https://play.google.com/store/apps/details?id=app.connectapp.com';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Share this Clip',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            _shareTile(
              context,
              icon: Icons.copy_rounded,
              title: "Copy Link",
              subtitle: "Share link to clipboard",
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: deepLink));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text("Link copied to clipboard!"),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
            _shareTile(
              context,
              icon: Icons.share_rounded,
              title: "Share to Apps",
              subtitle: "Share via other apps",
              onTap: () {
                Navigator.pop(context);
                Share.share(shareText);
              },
            ),
            _shareTile(
              context,
              icon: Icons.chat,
              title: "Share via WhatsApp",
              subtitle: "Send directly to WhatsApp",
              onTap: () async {
                Navigator.pop(context);
                final url =
                    "whatsapp://send?text=${Uri.encodeComponent(shareText)}";

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  Share.share(shareText);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _shareTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.purple.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class InstagramControls extends StatelessWidget {
  const InstagramControls({super.key});

  @override
  Widget build(BuildContext context) {
    final ClipPlayController controller = Get.put(ClipPlayController());
    final chewieController = ChewieController.of(context);
    final videoController = chewieController.videoPlayerController;
    Get.put(GetClipByIdController());

    return GestureDetector(
      onTap: controller.togglePlayPause,
      child: Stack(
        children: [
          Center(
            child: videoController.value.isPlaying
                ? const SizedBox.shrink()
                : const Icon(Icons.play_circle_fill,
                    color: Colors.white70, size: 70),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Obx(() => Icon(
                      controller.isMuted.value
                          ? Icons.volume_off
                          : Icons.volume_up,
                      color: Colors.white,
                    )),
                onPressed: controller.toggleMute,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 1,
            right: 1,
            child: Column(
              children: [
                VideoProgressIndicator(
                  videoController,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
