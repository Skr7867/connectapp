import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/response/status.dart';
import '../../models/AllFollowers/all_followers_model.dart';
import '../../models/AllFollowing/all_following_model.dart';
import '../../res/color/app_colors.dart';
import '../../res/fonts/app_fonts.dart';
import '../../view_models/controller/allFollowers/all_followers_controller.dart';
import '../../view_models/controller/allFollowings/all_followings_controller.dart';
import '../../view_models/controller/follow/user_follow_controller.dart';

class FollowersFollowingScreen extends StatefulWidget {
  const FollowersFollowingScreen({super.key});

  @override
  State<FollowersFollowingScreen> createState() =>
      _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final AllFollowersController followersController =
      Get.put(AllFollowersController());
  final AllFollowingsController followingsController =
      Get.put(AllFollowingsController());
  final FollowUnfollowController followUnfollowController =
      Get.put(FollowUnfollowController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(context),

            // Stats Overview
            _buildStatsOverview(),

            // Tabs
            _buildTabs(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFollowersList(),
                  _buildFollowingList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontFamily: AppFonts.opensansRegular,
        ),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.blueColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Obx(() {
      final followersCount =
          followersController.rxRequestStatus.value == Status.COMPLETED
              ? followersController.followers.length
              : 0;
      final followingCount =
          followingsController.rxRequestStatus.value == Status.COMPLETED
              ? followingsController.followings.length
              : 0;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.blueColor.withOpacity(0.1),
              Colors.tealAccent.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.blueColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              Icons.people_rounded,
              followersCount.toString(),
              'Followers',
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            _buildStatItem(
              Icons.person_add_rounded,
              followingCount.toString(),
              'Following',
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.blueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.blueColor, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.whiteColor,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.opensansRegular,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.opensansRegular,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_rounded, size: 18),
                SizedBox(width: 6),
                Text('Followers'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_rounded, size: 18),
                SizedBox(width: 6),
                Text('Following'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowersList() {
    return Obx(() {
      switch (followersController.rxRequestStatus.value) {
        case Status.LOADING:
          return _buildLoadingShimmer();
        case Status.ERROR:
          return _buildErrorState(
            followersController.error.value,
            followersController.fetchFollowers,
          );
        case Status.COMPLETED:
          final allFollowers = followersController.followers;
          final filteredFollowers = allFollowers.where((followerItem) {
            final follower = followerItem.follower;
            if (follower == null) return false;
            final name = follower.fullName?.toLowerCase() ?? '';
            final username = follower.username?.toLowerCase() ?? '';
            return name.contains(_searchQuery) ||
                username.contains(_searchQuery);
          }).toList();

          if (filteredFollowers.isEmpty) {
            return _buildEmptyState(
              _searchQuery.isEmpty
                  ? 'No followers yet'
                  : 'No matching followers',
              _searchQuery.isEmpty
                  ? 'Users who follow you will appear here'
                  : 'Try a different search term',
              Icons.people_outline_rounded,
            );
          }

          return RefreshIndicator(
            onRefresh: followersController.refreshFollowers,
            color: AppColors.blueColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredFollowers.length,
              itemBuilder: (context, index) {
                final followerItem = filteredFollowers[index];
                final user = followerItem.follower;
                if (user == null) return const SizedBox.shrink();
                return _buildUserCard(user, showUnfollow: false);
              },
            ),
          );
      }
    });
  }

  Widget _buildFollowingList() {
    return Obx(() {
      switch (followingsController.rxRequestStatus.value) {
        case Status.LOADING:
          return _buildLoadingShimmer();
        case Status.ERROR:
          return _buildErrorState(
            followingsController.error.value,
            followingsController.fetchFollowings,
          );
        case Status.COMPLETED:
          final allFollowings = followingsController.followings;
          final filteredFollowings = allFollowings.where((followingItem) {
            final followingUser = followingItem.following;
            if (followingUser == null) return false;
            final name = followingUser.fullName?.toLowerCase() ?? '';
            final username = followingUser.username?.toLowerCase() ?? '';
            return name.contains(_searchQuery) ||
                username.contains(_searchQuery);
          }).toList();

          if (filteredFollowings.isEmpty) {
            return _buildEmptyState(
              _searchQuery.isEmpty
                  ? 'Not following anyone'
                  : 'No matching users',
              _searchQuery.isEmpty
                  ? 'Users you follow will appear here'
                  : 'Try a different search term',
              Icons.person_add_alt_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: followingsController.refreshFollowings,
            color: AppColors.blueColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredFollowings.length,
              itemBuilder: (context, index) {
                final followingItem = filteredFollowings[index];
                final user = followingItem.following;
                if (user == null) return const SizedBox.shrink();
                return _buildUserCardForFollowing(user, showUnfollow: true);
              },
            ),
          );
      }
    });
  }

  Widget _buildUserCard(Follower user, {required bool showUnfollow}) {
    final initials = user.fullName
            ?.split(' ')
            .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
            .take(2)
            .join() ??
        'U';
    final hasAvatar =
        user.avatar?.imageUrl != null && user.avatar!.imageUrl!.isNotEmpty;

    return InkWell(
      onTap: () {
        Get.toNamed(RouteName.clipProfieScreen, arguments: user.sId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.greyColor.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with gradient border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.blueColor.withOpacity(0.5),
                    Colors.tealAccent.withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).cardColor,
                child: hasAvatar
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.avatar!.imageUrl!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.teal,
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade400,
                              Colors.teal.shade600,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? 'Unknown',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.alternate_email,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.username ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Button
            if (showUnfollow) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCardForFollowing(Followings user,
      {required bool showUnfollow}) {
    final initials = user.fullName
            ?.split(' ')
            .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
            .take(2)
            .join() ??
        'U';
    final hasAvatar =
        user.avatar?.imageUrl != null && user.avatar!.imageUrl!.isNotEmpty;
    final userId = user.id ?? '';

    return InkWell(
      onTap: () {
        Get.toNamed(RouteName.clipProfieScreen, arguments: user.sId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.greyColor.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with gradient border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.blueColor.withOpacity(0.5),
                    Colors.tealAccent.withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).cardColor,
                child: hasAvatar
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.avatar!.imageUrl!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.teal,
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade400,
                              Colors.teal.shade600,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? 'Unknown',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.alternate_email,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.username ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unfollow Button
            if (showUnfollow)
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: followUnfollowController.isLoadingUser(userId)
                        ? null
                        : () async {
                            await _handleUnfollow(userId);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: followUnfollowController.isLoadingUser(userId)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_remove_rounded,
                                size: 16,
                                color: AppColors.redColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Unfollow',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const ShimmerBox(width: 56, height: 56, isCircle: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 150, height: 16),
                    SizedBox(height: 8),
                    ShimmerBox(width: 100, height: 14),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontFamily: AppFonts.opensansRegular,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 72,
                  color: AppColors.blueColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontFamily: AppFonts.opensansRegular,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUnfollow(String userId) async {
    final success = await followUnfollowController.unfollowUser(userId);
    if (success) {
      await followingsController.refreshFollowings();
    }
  }
}

// Shimmer Box Widget
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final bool isCircle;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
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
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle ? null : BorderRadius.circular(12),
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
