import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../res/assets/image_assets.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/archiveClips/archive_clips_controller.dart';
import '../../../view_models/controller/deleteClip/delete_clip_controller.dart';
import '../../../view_models/controller/myClips/my_clips_controller.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  late final MyClipsController clipsController;
  late final ArchiveClipsController archiveController;
  late final DeleteClipsController deleteClipController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    clipsController = Get.put(MyClipsController());
    archiveController = Get.put(ArchiveClipsController());
    deleteClipController = Get.put(DeleteClipsController());

    // Only fetch if not already loaded
    if (clipsController.publicClips.isEmpty &&
        clipsController.rxRequestStatus.value != Status.COMPLETED) {
      clipsController.fetchMyClips();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final status = clipsController.rxRequestStatus.value;
      final clips = clipsController.publicClips;
      final hasClips = clips.isNotEmpty;

      // Show loading only if no cached data
      if (status == Status.LOADING && !hasClips) {
        return _buildLoadingState(context);
      }

      // Show error only if no cached data
      if (status == Status.ERROR && !hasClips) {
        return _buildErrorState(context);
      }

      // Show empty state
      if (hasClips == false && status == Status.COMPLETED) {
        return _buildEmptyState(context);
      }

      // Show clips grid
      return _buildClipsGrid(context, clips);
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your clips...',
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              clipsController.error.value.isNotEmpty
                  ? clipsController.error.value
                  : 'Failed to load clips',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 16,
                fontFamily: AppFonts.opensansRegular,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => clipsController.fetchMyClips(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Public Clips Yet',
              style: TextStyle(
                fontFamily: AppFonts.helveticaBold,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start creating and sharing your clips',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClipsGrid(BuildContext context, List clips) {
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.portrait ? 3 : 5;

    return RefreshIndicator(
      onRefresh: clipsController.refreshMyClips,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: clips.length,
        itemBuilder: (context, index) {
          return _buildClipCard(context, clips[index]);
        },
      ),
    );
  }

  Widget _buildClipCard(BuildContext context, dynamic clip) {
    final imageUrl = clip.thumbnailUrl ?? "";
    final clipId = clip.sId ?? "";

    return GestureDetector(
      onTap: () => _navigateToClip(clipId),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail Image
              _buildThumbnail(imageUrl),

              // Gradient Overlay
              _buildGradientOverlay(),

              // Play Button
              _buildPlayButton(clipId),

              // View Count (if available)
              if (clip.viewCount != null) _buildViewCount(clip.viewCount),

              // Menu Button
              _buildMenuButton(context, clipId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        ImageAssets.defaultProfileImg,
        fit: BoxFit.cover,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          color: AppColors.loginContainerColor,
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade300,
            ],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.blueColor,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 4),
            Text(
              'Failed to load',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      memCacheWidth: 400,
      memCacheHeight: 600,
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(String clipId) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
        ),
        child: IconButton(
          onPressed: () => _navigateToClip(clipId),
          icon: const Icon(
            Icons.play_circle_fill,
            size: 48,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildViewCount(int viewCount) {
    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_arrow,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              _formatViewCount(viewCount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String clipId) {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
        ),
        child: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(-10, 40),
          color: Theme.of(context).cardColor,
          elevation: 8,
          onSelected: (value) => _handleMenuAction(value, clipId),
          itemBuilder: (context) => [
            _buildMenuItem(
              'archive',
              Icons.archive_outlined,
              'Archive Clip',
              AppColors.blueColor,
            ),
            _buildMenuItem(
              'delete',
              Icons.delete_outline,
              'Delete Clip',
              AppColors.redColor,
            ),
          ],
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: color,
              fontWeight:
                  value == 'delete' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToClip(String clipId) {
    if (clipId.isEmpty) {
      Get.snackbar(
        "Info",
        "Invalid clip",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.toNamed(
      RouteName.clipPlayScreen,
      arguments: clipId,
    );
  }

  void _handleMenuAction(String action, String clipId) {
    if (clipId.isEmpty) {
      Get.snackbar(
        "Info",
        "Invalid clip",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    switch (action) {
      case 'archive':
        archiveController.toggleArchiveClip(clipId);
        Get.snackbar(
          "Success",
          "Clip archived successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.greenColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(clipId);
        break;
    }
  }

  void _showDeleteConfirmation(String clipId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text(
              'Delete Clip?',
              style: TextStyle(
                fontFamily: AppFonts.helveticaBold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this clip?',
          style: TextStyle(
            color: Colors.black,
            fontFamily: AppFonts.opensansRegular,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteClipController.deleteClip(clipId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewCount(int viewCount) {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }
}

// Backward compatible function wrapper
Widget buildStatsTab(BuildContext context) {
  return const StatsTab();
}
