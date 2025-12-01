import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../res/assets/image_assets.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../view_models/CREATORPANEL/CreatorController/creator_controller.dart';
import '../../../view_models/CREATORPANEL/CreatorController/switch_creator_controller.dart';

class UserProfileContainerWidget extends StatelessWidget {
  const UserProfileContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Get.put(UserProfileController());
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isSmallScreen = size.width < 360;

    Get.put(CreatorController());
    Get.put(CreatorModeController());

    return RefreshIndicator(
      onRefresh: () async {
        await userData.refreshApi();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with back and settings buttons
                _buildHeader(context),
                SizedBox(height: size.height * 0.02),

                // Profile Avatar
                _buildProfileAvatar(userData, size, isPortrait),
                SizedBox(height: size.height * 0.02),

                // User Name
                _buildUserName(userData, context),
                SizedBox(height: size.height * 0.01),

                // Username with Premium Badge
                _buildUsername(userData, context, size),
                SizedBox(height: size.height * 0.03),

                // Stats Row
                _buildStatsRow(userData, size, isSmallScreen),
                SizedBox(height: size.height * 0.03),

                // Action Buttons
                _buildActionButtons(size, isSmallScreen),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(RouteName.settingScreen),
          icon: Icon(
            Icons.settings_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(
      UserProfileController userData, Size size, bool isPortrait) {
    final avatarSize = isPortrait ? size.width * 0.28 : size.height * 0.35;

    return Obx(() {
      final imageUrl = userData.userList.value.avatar?.imageUrl;
      final isError = userData.rxRequestStatus.value == Status.ERROR;

      return GestureDetector(
        onTap: () => Get.toNamed(RouteName.profileScreen),
        child: Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.blueColor.withOpacity(0.3),
                Colors.tealAccent.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(Get.context!).cardColor,
              ),
              child: ClipOval(
                child: isError || imageUrl == null || imageUrl.isEmpty
                    ? Image.asset(
                        ImageAssets.profileIcon,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.blueColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          ImageAssets.profileIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUserName(UserProfileController userData, BuildContext context) {
    return Obx(() {
      switch (userData.rxRequestStatus.value) {
        case Status.LOADING:
          return const ShimmerLoading(width: 150, height: 25);
        case Status.ERROR:
          return Text(
            "No Name",
            style: TextStyle(
              fontSize: 20,
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          );
        case Status.COMPLETED:
          return Text(
            userData.userList.value.fullName ?? "No Name",
            style: TextStyle(
              fontSize: 26,
              fontFamily: AppFonts.helveticaBold,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          );
      }
    });
  }

  Widget _buildUsername(
      UserProfileController userData, BuildContext context, Size size) {
    return Obx(() {
      if (userData.rxRequestStatus.value == Status.LOADING) {
        return const ShimmerLoading(width: 120, height: 20);
      }

      if (userData.rxRequestStatus.value == Status.ERROR) {
        return const SizedBox.shrink();
      }

      final isActive = userData.userList.value.subscription?.status == "Active";
      // final premiumIconUrl =
      //     userData.userList.value.subscriptionFeatures?.premiumIconUrl;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12 : 0,
          vertical: isActive ? 8 : 0,
        ),
        decoration: isActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFA500),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '@${userData.userList.value.username}',
              style: TextStyle(
                fontSize: 15,
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black87 : AppColors.redColor,
              ),
            ),
            // if (isActive && premiumIconUrl != null && premiumIconUrl.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(left: 6),
            //     child: CachedNetworkImage(
            //       imageUrl: premiumIconUrl,
            //       width: 20,
            //       height: 20,
            //       fit: BoxFit.contain,
            //       placeholder: (context, url) => const SizedBox(
            //         width: 20,
            //         height: 20,
            //         child: CircularProgressIndicator(strokeWidth: 1),
            //       ),
            //       errorWidget: (context, url, error) => const SizedBox.shrink(),
            //     ),
            //   ),
          ],
        ),
      );
    });
  }

  Widget _buildStatsRow(
      UserProfileController userData, Size size, bool isSmallScreen) {
    return Obx(() {
      final profile = userData.userList.value;
      final isLoading = userData.rxRequestStatus.value == Status.LOADING;

      if (isLoading) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => const ShimmerLoading(width: 75, height: 70),
          ),
        );
      }

      return Wrap(
        spacing: isSmallScreen ? 8 : 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildStatCard("${profile.totalPost ?? 0}", "Clips",
              Icons.video_library_rounded, null),
          _buildStatCard(
            "${profile.followerCount ?? 0}",
            "Followers",
            Icons.people_rounded,
            () => Get.toNamed(RouteName.allFollowersScreen),
          ),
          _buildStatCard(
            "${profile.followingCount ?? 0}",
            "Following",
            Icons.person_add_rounded,
            () => Get.toNamed(RouteName.allFollowersScreen),
          ),
          _buildStatCard("${profile.totalLikes ?? 0}", "Likes",
              Icons.favorite_rounded, null),
        ],
      );
    });
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.greyColor.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: AppColors.blueColor,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Size size, bool isSmallScreen) {
    final buttonData = [
      {
        'label': 'Edit Profile',
        'route': RouteName.editProfileScreen,
        'icon': Icons.edit_rounded
      },
      {
        'label': 'All Avatar',
        'route': RouteName.allAvatarsScreen,
        'icon': Icons.dashboard_rounded
      },
      {
        'label': 'My Avatar',
        'route': RouteName.usersAvatarScreen,
        'icon': Icons.person_rounded
      },
    ];

    return Wrap(
      spacing: isSmallScreen ? 8 : 1,
      runSpacing: isSmallScreen ? 4 : 6,
      alignment: WrapAlignment.center,
      children: buttonData.map((data) {
        return _buildActionButton(
          data['label'] as String,
          data['route'] as String,
          data['icon'] as IconData,
          isSmallScreen,
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
      String label, String route, IconData icon, bool isSmallScreen) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.whiteColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer Loading Widget
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}
