import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../res/assets/image_assets.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/controller/UserSocialProfile/user_social_profile_controller.dart';
import '../../../view_models/controller/usersAllClips/users_all_clips_controller.dart';

class UsersAllClipsWidgets extends StatelessWidget {
  const UsersAllClipsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final userClips = Get.put(UsersAllClipsController());
    final userData = Get.find<UserSocialProfileController>();
    return Obx(() {
      switch (userClips.rxRequestStatus.value) {
        case Status.LOADING:
          return const Center(
              child:
                  CircularProgressIndicator()); // Updated to match RepostsTab

        case Status.ERROR:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userClips.error.value,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 16), // Updated font size
                ),
                IconButton(
                  onPressed: () => userClips.fetchUserClips(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );

        case Status.COMPLETED:
          final clips = userClips.userClips.value?.clips ?? [];
          final isPrivate = userData.userProfile.value?.isPrivate ?? false;
          final isFollowing = userData.userProfile.value?.isFollowing ?? false;
          if (isPrivate && !isFollowing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Private Account",
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Follow this account to see their content.",
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      color: AppColors.greyColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }
          if (clips.isEmpty) {
            return Center(
              child: Text(
                "No clips found",
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: userClips.refreshUserClips,
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8, // Updated spacing
                mainAxisSpacing: 10, // Updated spacing
                childAspectRatio: 0.6, // Updated aspect ratio
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
                                    child:
                                        CircularProgressIndicator(), // Added loading indicator
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
                                RouteName
                                    .clipPlayScreen, // Updated to match RepostsTab
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

                    Positioned(
                        left: 10,
                        top: 168,
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: AppColors.whiteColor,
                              size: 11,
                            ),
                            SizedBox(width: 3),
                            Text(
                              clip.likeCount.toString(),
                              style: TextStyle(
                                  color: AppColors.whiteColor, fontSize: 10),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.remove_red_eye,
                                size: 11, color: AppColors.whiteColor),
                            SizedBox(width: 3),
                            Text(
                              clip.viewCount.toString(),
                              style: TextStyle(
                                  color: AppColors.whiteColor, fontSize: 10),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.comment,
                                size: 11, color: AppColors.whiteColor),
                            SizedBox(width: 3),
                            Text(
                              clip.commentCount.toString(),
                              style: TextStyle(
                                  color: AppColors.whiteColor, fontSize: 10),
                            ),
                          ],
                        ))
                  ],
                );
              },
            ),
          );
      }
    });
  }
}
