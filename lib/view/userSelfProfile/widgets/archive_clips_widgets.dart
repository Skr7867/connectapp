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

Widget archiveClipsTab(BuildContext context) {
  final clipsController = Get.put(MyClipsController());
  final archiveController = Get.put(ArchiveClipsController());
  final deleteClipController = Get.put(DeleteClipsController());

  return Obx(() {
    switch (clipsController.rxRequestStatus.value) {
      case Status.LOADING:
        return Center(
          child: SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        );

      case Status.ERROR:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clipsController.error.value,
                style: const TextStyle(color: Colors.red),
              ),
              IconButton(
                onPressed: () => clipsController.fetchMyClips(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        );

      case Status.COMPLETED:
        // ✅ Now we only show PUBLIC clips
        final clips = clipsController.privateClips;
        if (clips.isEmpty) {
          return Center(
            child: Text(
              "No Archive clips found",
              style: TextStyle(
                fontFamily: AppFonts.helveticaMedium,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }

        // Preload thumbnails for the first 10 clips
        for (var clip in clips.take(10)) {
          if (clip.thumbnailUrl != null && clip.thumbnailUrl!.isNotEmpty) {
            precacheImage(
              CachedNetworkImageProvider(clip.thumbnailUrl!),
              context,
            );
          }
        }

        return RefreshIndicator(
          onRefresh: clipsController.refreshMyClips,
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(6),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: clips.length,
            itemBuilder: (BuildContext context, int index) {
              final clip = clips[index];
              final imageUrl = clip.thumbnailUrl ?? "";

              return Stack(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                color: AppColors.loginContainerColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              ImageAssets.defaultProfileImg,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            ImageAssets.defaultProfileImg,
                            fit: BoxFit.cover,
                          ),
                  ),

                  // Play button center
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () {
                          if (clip.processedUrl != null &&
                              clip.processedUrl!.isNotEmpty) {
                            Get.toNamed(
                              RouteName.clipPlayScreen,
                              arguments: clip.sId,
                            );
                          } else {
                            Get.snackbar("Error", "Invalid video URL");
                          }
                        },
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 30,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  // 3-dot menu top-right
                  Positioned(
                    top: 6,
                    right: 6,
                    child: PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (value) {
                        if (value == 'unarchive') {
                          archiveController.toggleArchiveClip(clip.sId ?? "");
                        } else if (value == 'delete') {
                          deleteClipController.deleteClip(clip.sId ?? "");
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'unarchive',
                          child: Text(
                            "Unarchive Clip",
                            style: TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            "Delete Clip",
                            style: TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                color: AppColors.redColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
    }
  });
}
