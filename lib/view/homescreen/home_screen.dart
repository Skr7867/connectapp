import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view/homescreen/widgets/progress_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../data/response/status.dart';
import '../../res/color/app_colors.dart';
import '../../res/fonts/app_fonts.dart';
import '../../view_models/controller/leaderboard/user_leaderboard_controller.dart';
import '../../view_models/controller/notification/notification_controller.dart';
import '../../view_models/controller/profile/user_profile_controller.dart';
import '../settings/log_out_dialog_screen.dart';
import 'FullLeaderBoard/full_leaderboard_screen.dart';
import 'widgets/featured_course_widget.dart';
import 'widgets/stats_row_widget.dart';
import 'widgets/top_learner_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final userData = Get.put(UserProfileController(), permanent: true);
  final userLeaderboardData = Get.put(UserLeaderboardController());
  final NotificationController controller = Get.find<NotificationController>();

  @override
  bool get wantKeepAlive => true;

  Future<void> onRefresh() async {
    await userData.refreshApi(); // manual refresh updates both local + UI
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context, size),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  ResponsivePadding.symmetricPadding(context, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(child: DashboardScreen()),
                  _buildPerformanceSection(context, size, isPortrait),
                  const SizedBox(height: 20),
                  _buildTopLearnersHeader(context, isPortrait),
                  const TopLearnerWidget(),
                  const SizedBox(height: 20),
                  _buildCoursesHeader(context),
                  const SizedBox(height: 20),
                  const FeaturedCourseWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Drawer Widget
  Widget _buildDrawer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(),
              child: Image.asset(ImageAssets.splashLogo),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.add,
              title: 'Create Avatar',
              onTap: () => Get.toNamed(RouteName.avatarCreatorScreen),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Inventory',
              onTap: () => Get.toNamed(RouteName.inventoryAvatarScreen),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.star_border,
              title: 'Collection',
              onTap: () => Get.toNamed(RouteName.myAvatarCollection),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.shop,
              title: 'MarketPlace',
              onTap: () => Get.toNamed(RouteName.myMarketPlaceAvatar),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              isLogout: true,
              onTap: () => showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? AppColors.redColor
            : Theme.of(context).textTheme.bodyLarge?.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout
              ? Colors.red
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 15,
          fontFamily: AppFonts.opensansRegular,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }

  // AppBar Widget
  PreferredSizeWidget _buildAppBar(BuildContext context, Size size) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: 70,
      title: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          _buildProfileAvatar(context),
          SizedBox(width: size.width * 0.02),
          Expanded(child: _buildUserName(context)),
          _buildNotificationIcon(context),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.blueGrey.shade100,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Obx(() {
      final imageUrl = userData.userList.value.avatar?.imageUrl;
      final hasData = userData.rxRequestStatus.value == Status.COMPLETED;

      return GestureDetector(
        onTap: () => Get.toNamed(RouteName.profileScreen),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blackColor, width: 2),
          ),
          child: ClipOval(
            child: hasData && imageUrl?.isNotEmpty == true
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Image.asset(
                      ImageAssets.defaultProfileImg,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (_, __, ___) => Image.asset(
                      ImageAssets.defaultProfileImg,
                      fit: BoxFit.cover,
                    ),
                    memCacheWidth: 90,
                    memCacheHeight: 90,
                  )
                : Image.asset(
                    ImageAssets.defaultProfileImg,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      );
    });
  }

  Widget _buildUserName(BuildContext context) {
    return Obx(() {
      final status = userData.rxRequestStatus.value;
      final fullName = userData.userList.value.fullName ?? '';

      if (status == Status.LOADING && fullName.isEmpty) {
        return SizedBox(
          width: 2,
          height: 20,
          child: CircularProgressIndicator(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        );
      }

      return Text(
        fullName.isEmpty ? 'User' : fullName,
        style: TextStyle(
          fontFamily: AppFonts.helveticaMedium,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        overflow: TextOverflow.ellipsis,
      );
    });
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Obx(() => Stack(
          children: [
            IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                // onPressed: () => Get.toNamed(RouteName.notificationScreen),
                onPressed: () {
                  Future.microtask(() {
                    Get.toNamed(RouteName.notificationScreen,
                        preventDuplicates: false);
                  });
                }),
            if (controller.unreadCount.value > 0)
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  height: 18,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${controller.unreadCount.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 7,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ));
  }

  // Performance Section
  Widget _buildPerformanceSection(
      BuildContext context, Size size, bool isPortrait) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Performance',
          style: TextStyle(
            fontSize: 18,
            fontFamily: AppFonts.helveticaBold,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => Get.toNamed(RouteName.streakExploreScreen),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isPortrait ? 16 : 24,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.loginContainerColor,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIconsFill.chartBar,
                      color: AppColors.blackColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Performance',
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.helveticaBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressInfo(context),
                const SizedBox(height: 12),
                _buildProgressBar(context),
                const SizedBox(height: 16),
                const StatsRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(BuildContext context) {
    return Obx(() {
      final status = userData.rxRequestStatus.value;
      final level = userData.userList.value.level ?? 0;
      final xp = userData.userList.value.xp ?? 0;

      if (status == Status.LOADING && level == 0) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Loading...', style: TextStyle(fontSize: 13)),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Progress to level $level',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.opensansRegular,
              color: AppColors.blackColor,
            ),
          ),
          Text(
            '${xp}XP',
            style: const TextStyle(
              fontSize: 15,
              fontFamily: AppFonts.helveticaMedium,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProgressBar(BuildContext context) {
    return Obx(() {
      final xp = userData.userList.value.xp ?? 0;
      final nextLevelAt = userData.userList.value.nextLevelAt ?? 1;
      final percentage =
          nextLevelAt > 0 ? (xp / nextLevelAt).clamp(0.0, 1.0) : 0.0;

      return GFProgressBar(
        lineHeight: 22,
        percentage: percentage,
        backgroundColor: Colors.grey.shade300,
        linearGradient: const LinearGradient(
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF2575FC),
            Color(0xFF00C6FF),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      );
    });
  }

  // Top Learners Header
  Widget _buildTopLearnersHeader(BuildContext context, bool isPortrait) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPortrait ? 8 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'top_learners'.tr,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: AppFonts.helveticaBold,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.to(() => FullLeaderboardScreen(
                    leaderboard:
                        userLeaderboardData.userLeaderboard.value.leaderboard,
                  ));
            },
            child: Text(
              'view_rank'.tr,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Courses Header
  Widget _buildCoursesHeader(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          ImageAssets.openbook,
          height: 26,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(width: 12),
        Text(
          'Courses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.helveticaBold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        )
      ],
    );
  }
}
