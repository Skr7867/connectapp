import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../res/assets/image_assets.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/repostClips/fetch_repost_clips_controller.dart';

Widget repostClipsTab(BuildContext context) {
  final repostedClipController = Get.put(FetchRepostClipsController());

  return Obx(() {
    switch (repostedClipController.rxRequestStatus.value) {
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
                repostedClipController.error.value,
                style: const TextStyle(color: Colors.red),
              ),
              IconButton(
                onPressed: () => repostedClipController.fetchRepostedClips(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        );

      case Status.COMPLETED:
        final clips = repostedClipController.repostedClips.value?.clips ?? [];
        if (clips.isEmpty) {
          return Center(
            child: Text(
              "No Reposted clips found",
              style: TextStyle(
                fontFamily: AppFonts.helveticaMedium,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }

        for (var clip in clips.take(10)) {
          if (clip.thumbnailUrl != null && clip.thumbnailUrl!.isNotEmpty) {
            precacheImage(
              CachedNetworkImageProvider(clip.thumbnailUrl!),
              context,
            );
          }
        }

        return RefreshIndicator(
          onRefresh: repostedClipController.refreshRepostedClips,
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

              return GestureDetector(
                onTap: () {
                  if (clip.sId != null && clip.sId!.isNotEmpty) {
                    Get.toNamed(
                      RouteName.clipPlayScreen,
                      arguments: clip.sId,
                    );
                  } else {
                    Get.snackbar("Error", "Invalid video URL");
                  }
                },
                child: ClipRRect(
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
              );
            },
          ),
        );
    }
  });
}
