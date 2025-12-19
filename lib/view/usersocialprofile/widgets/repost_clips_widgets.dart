import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../res/assets/image_assets.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/profile/user_profile_controller.dart';
import '../../../view_models/controller/repostClipByUser/repost_clip_by_user_controller.dart';

class RepostsTab extends StatelessWidget {
  const RepostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClipRepostByUserController>();
    final userProfileController = Get.find<UserProfileController>();

    return RefreshIndicator(
      onRefresh: () async {
        final String userId = Get.arguments ?? '';
        if (userId.isNotEmpty) {
          await controller.refreshRepostedClips(userId);
        }
      },
      child: Obx(() {
        switch (controller.rxRequestStatus.value) {
          case Status.LOADING:
            return const Center(child: CircularProgressIndicator());
          case Status.ERROR:
            return Center(
              child: Text(
                controller.error.value,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          case Status.COMPLETED:
            final clips = controller.repostedClips.value?.clips ?? [];
            if (userProfileController.userList.value.isPrivate == true) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Private Account",
                      style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Follow this account to see their content.",
                      style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            } else if (clips.isEmpty) {
              return Center(
                child: Text(
                  'No reposts available',
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return GridView.builder(
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
                          ? InkWell(
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
                              child: CachedNetworkImage(
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
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  ImageAssets.defaultProfileImg,
                                  fit: BoxFit.cover,
                                ),
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
                            if (clip.sId != null && clip.sId!.isNotEmpty) {
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
                  ],
                );
              },
            );
        }
      }),
    );
  }
}
