import 'dart:developer';

import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view/usersocialprofile/widgets/users_all_clips_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/response/status.dart';
import '../../res/color/app_colors.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/UserSocialProfile/user_social_profile_controller.dart';
import '../../view_models/controller/follow/user_follow_controller.dart';
import '../../view_models/controller/repostClipByUser/repost_clip_by_user_controller.dart';
import 'widgets/repost_clips_widgets.dart';

class UserSocialProfileScreen extends StatelessWidget {
  const UserSocialProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Get.put(UserSocialProfileController());
    final args = Get.arguments;
    late final String userId;

    if (args is String) {
      userId = args;
    } else if (args is Map && args['direct_user_id'] is String) {
      userId = args['direct_user_id'];
    } else {
      userId = "";
    }

    final repostController = Get.put(ClipRepostByUserController());
    final followController = Get.put(FollowUnfollowController());

    if (userId.isNotEmpty) {
      repostController.fetchRepostedClips(userId);
      log(userId);
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          automaticallyImplyLeading: true,
          title: "Profile",
        ),
        body: RefreshIndicator(
          color: Colors.pinkAccent,
          onRefresh: () async {
            await userData.refreshUserProfile();
            if (userId.isNotEmpty) {
              await repostController.refreshRepostedClips(userId);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Gradient Header Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pinkAccent.withOpacity(0.1),
                        Colors.purpleAccent.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Avatar with Ring
                      Obx(() {
                        switch (userData.rxRequestStatus.value) {
                          case Status.LOADING:
                            return _buildLoadingAvatar(
                                screenHeight, screenWidth, orientation);
                          case Status.ERROR:
                            return _buildErrorAvatar();
                          case Status.COMPLETED:
                            final profile = userData.userProfile.value;
                            final avatar = profile?.avatar;
                            final isActive =
                                profile?.subscription.status == "Active";

                            return InkWell(
                              onTap: () {
                                Get.toNamed(RouteName.fullProfileScreen,
                                    arguments: avatar!.imageUrl);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isActive
                                      ? LinearGradient(
                                          colors: [
                                            Colors.pinkAccent,
                                            Colors.purpleAccent,
                                            Colors.orangeAccent,
                                          ],
                                        )
                                      : null,
                                  border: !isActive
                                      ? Border.all(
                                          color: AppColors.greyColor
                                              .withOpacity(0.3),
                                          width: 2)
                                      : null,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  child: ClipOval(
                                    child: (avatar != null &&
                                            avatar.imageUrl.isNotEmpty)
                                        ? Image.network(
                                            avatar.imageUrl,
                                            height: 110,
                                            width: 110,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return _buildDefaultAvatar();
                                            },
                                          )
                                        : _buildDefaultAvatar(),
                                  ),
                                ),
                              ),
                            );
                        }
                      }),

                      const SizedBox(height: 16),

                      // Full Name
                      Obx(() {
                        switch (userData.rxRequestStatus.value) {
                          case Status.LOADING:
                            return _buildShimmer(width: 150, height: 28);
                          case Status.ERROR:
                            return const Text("No Name");
                          case Status.COMPLETED:
                            return Text(
                              userData.userProfile.value?.fullName ?? "Unknown",
                              style: TextStyle(
                                fontSize: 26,
                                fontFamily: AppFonts.opensansRegular,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                letterSpacing: 0.5,
                              ),
                            );
                        }
                      }),

                      const SizedBox(height: 8),

                      // Username + Premium Badge
                      Obx(() {
                        switch (userData.rxRequestStatus.value) {
                          case Status.LOADING:
                            return _buildShimmer(width: 120, height: 20);
                          case Status.ERROR:
                            return const Text("No username");
                          case Status.COMPLETED:
                            final profile = userData.userProfile.value;
                            final username = profile?.username ?? "unknown";
                            final isActive =
                                profile?.subscription.status == "Active";

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: isActive
                                    ? LinearGradient(
                                        colors: [
                                          Colors.amber.shade300,
                                          Colors.orange.shade400,
                                        ],
                                      )
                                    : null,
                                color: !isActive
                                    ? Colors.grey.withOpacity(0.1)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '@$username',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: AppFonts.opensansRegular,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? AppColors.blackColor
                                          : AppColors.greyColor,
                                    ),
                                  ),
                                  if (isActive &&
                                      profile?.premiumIconUrl != null &&
                                      profile!.premiumIconUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: Image.network(
                                        profile.premiumIconUrl!,
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                ],
                              ),
                            );
                        }
                      }),

                      const SizedBox(height: 24),

                      // Stats Row with modern cards
                      Obx(() {
                        final profile = userData.userProfile.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildModernStat("${profile?.totalPost ?? 0}",
                                  "Posts", Icons.grid_on_outlined),
                              _buildStatDivider(),
                              _buildModernStat("${profile?.followerCount ?? 0}",
                                  "Followers", Icons.people_outline),
                              _buildStatDivider(),
                              _buildModernStat(
                                  "${profile?.followingCount ?? 0}",
                                  "Following",
                                  Icons.person_add_outlined),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 28),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildModernButton(
                                // onPressed: () => Get.toNamed(
                                //     RouteName.bottomNavbar,
                                //     arguments: userId),

                                onPressed: () => Get.toNamed(
                                    RouteName.bottomNavbar,
                                    arguments: {
                                      "open_tab": 1,
                                      "direct_user_id": userId,
                                    }),

                                icon: Icons.chat_bubble_outline,
                                label: 'Message',
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Obx(() {
                                final isFollowing =
                                    userData.userProfile.value?.isFollowing ??
                                        false;
                                return _buildModernButton(
                                  onPressed: () async {
                                    if (isFollowing) {
                                      await followController
                                          .unfollowUser(userId);
                                      userData.userProfile.update((val) {
                                        val?.isFollowing = false;
                                      });
                                    } else {
                                      await followController.followUser(userId);
                                      userData.userProfile.update((val) {
                                        val?.isFollowing = true;
                                      });
                                    }
                                  },
                                  icon: isFollowing
                                      ? Icons.person_remove_outlined
                                      : Icons.person_add_outlined,
                                  label: isFollowing ? 'Following' : 'Follow',
                                  isPrimary: !isFollowing,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // About Section
                _buildModernSectionTitle("About", Icons.info_outline),
                _buildModernCard(
                  child: Obx(() {
                    switch (userData.rxRequestStatus.value) {
                      case Status.LOADING:
                        return Column(
                          children: [
                            _buildShimmer(width: double.infinity, height: 16),
                            const SizedBox(height: 8),
                            _buildShimmer(width: double.infinity, height: 16),
                          ],
                        );
                      case Status.ERROR:
                        return const Text("No bio available");
                      case Status.COMPLETED:
                        final bio = userData.userProfile.value?.bio ?? "";
                        return Text(
                          bio.isEmpty ? "No bio available" : bio,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: AppFonts.helveticaBold,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.8),
                            height: 1.5,
                          ),
                        );
                    }
                  }),
                ),

                // Premium Card
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildModernCard(
                    child: Obx(() {
                      final isActive =
                          userData.userProfile.value?.subscription.status ==
                              "Active";
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isActive
                                    ? [
                                        Colors.amber.shade300,
                                        Colors.orange.shade400
                                      ]
                                    : [
                                        Colors.grey.shade300,
                                        Colors.grey.shade400
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.workspace_premium,
                              color: isActive
                                  ? AppColors.blackColor
                                  : Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Premium Member",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isActive
                                      ? "Active subscription"
                                      : "Upgrade to premium",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isActive ? "Active" : "Inactive",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: AppFonts.helveticaBold,
                                color: isActive
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                // Social Links
                _buildModernSectionTitle("Social Links", Icons.link),
                Obx(() {
                  final socialLinks =
                      userData.userProfile.value?.socialLinks ?? {};
                  final twitter = socialLinks["twitter"] ?? "";
                  final instagram = socialLinks["instagram"] ?? "";
                  final linkedin = socialLinks["linkedin"] ?? "";
                  final website = socialLinks["website"] ?? "";

                  List<Widget> links = [];

                  if (instagram.isNotEmpty) {
                    links.add(_buildModernSocialLink(
                      ImageAssets.instagram,
                      "Instagram",
                      instagram,
                      Colors.pink.shade400,
                    ));
                  }
                  if (twitter.isNotEmpty) {
                    links.add(_buildModernSocialLink(
                      ImageAssets.twitterIcon,
                      "X (Twitter)",
                      twitter,
                      Colors.black,
                    ));
                  }
                  if (linkedin.isNotEmpty) {
                    links.add(_buildModernSocialLink(
                      ImageAssets.linkedin,
                      "LinkedIn",
                      linkedin,
                      Colors.blue.shade700,
                    ));
                  }
                  if (website.isNotEmpty) {
                    links.add(_buildModernSocialLink(
                      ImageAssets.website,
                      "Website",
                      website,
                      Colors.purple.shade400,
                    ));
                  }

                  if (links.isEmpty) {
                    return _buildModernCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "No social links available",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontFamily: AppFonts.helveticaBold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return _buildModernCard(
                    child: Column(
                      children: links
                          .asMap()
                          .entries
                          .expand((entry) => [
                                entry.value,
                                if (entry.key < links.length - 1)
                                  Divider(
                                      color: Colors.grey.shade200, height: 24),
                              ])
                          .toList(),
                    ),
                  );
                }),

                // Tabs for Clips
                const SizedBox(height: 8),
                _buildModernSectionTitle("Clips", Icons.video_library_outlined),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    labelColor: AppColors.blackColor,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    indicator: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "Your Clips"),
                      Tab(text: "Reposts"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // TabBarView
                SizedBox(
                  height: screenHeight * 0.5,
                  child: TabBarView(
                    children: [
                      UsersAllClipsWidgets(),
                      RepostsTab(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern Stat Widget
  static Widget _buildModernStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  // Modern Button
  static Widget _buildModernButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [Colors.pinkAccent, Colors.purpleAccent],
                  )
                : null,
            color: !isPrimary ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.blackColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Section Title
  static Widget _buildModernSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.pinkAccent),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.helveticaBold,
            ),
          ),
        ],
      ),
    );
  }

  // Modern Card
  static Widget _buildModernCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Modern Social Link
  static Widget _buildModernSocialLink(
    String imagePath,
    String label,
    String link,
    Color accentColor,
  ) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    link,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  // Loading Avatar
  static Widget _buildLoadingAvatar(
      double screenHeight, double screenWidth, Orientation orientation) {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
    );
  }

  // Error Avatar
  static Widget _buildErrorAvatar() {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  // Default Avatar
  static Widget _buildDefaultAvatar() {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined,
              size: 30, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(
            'No profile',
            style: TextStyle(
              fontSize: 11,
              fontFamily: AppFonts.helveticaBold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer Loading Effect
  static Widget _buildShimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
