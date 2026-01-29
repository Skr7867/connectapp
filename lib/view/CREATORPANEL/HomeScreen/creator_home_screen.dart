import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view/CREATORPANEL/HomeScreen/widgets/course_analytics_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../view_models/CREATORPANEL/CreatorProfile/creator_profile_controller.dart';
import '../../../view_models/controller/leaderboard/user_leaderboard_controller.dart';
import '../../../view_models/controller/notification/notification_controller.dart';
import '../../../view_models/controller/profile/user_profile_controller.dart';
import '../../settings/log_out_dialog_screen.dart';
import 'widgets/creator_course_progress_widget.dart';
import 'widgets/creator_course_ratings_widget.dart';
import 'widgets/creator_dashboard_widgets.dart';

class CreatorHomeScreen extends StatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  State<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final userData = Get.put(UserProfileController());
  final userLeaderboardData = Get.put(UserLeaderboardController());
  final NotificationController controller = Get.find<NotificationController>();
  final CreatorProfileController _creatorProfileController =
      Get.put(CreatorProfileController());

  @override
  void initState() {
    super.initState();
    userData.userList();
  }

  Future<void> onRefresh() async {
    userData.userList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(),
                child: Image.asset(ImageAssets.splashLogo),
              ),
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                title: Text(
                  'Create Avatar',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 15,
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.toNamed(RouteName.avatarCreatorScreen);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                title: Text(
                  'Inventory',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 15,
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.toNamed(RouteName.inventoryAvatarScreen);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.star_border,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                title: Text(
                  'Collection',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 15,
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.toNamed(RouteName.myAvatarCollection);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.shop,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                title: Text(
                  'MarketPlace',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 15,
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.toNamed(RouteName.myMarketPlaceAvatar);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: AppColors.redColor,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                onTap: () {
                  showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
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
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            Obx(() {
              switch (userData.rxRequestStatus.value) {
                case Status.LOADING:
                  return SizedBox(
                    height: 40,
                    width: 40,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(RouteName.profileScreen);
                      },
                      child: ClipOval(
                        child: Image.asset(
                          ImageAssets.defaultProfileImg,
                          height: orientation == Orientation.portrait
                              ? screenHeight * 0.1
                              : screenHeight * 0.2,
                          width: orientation == Orientation.portrait
                              ? screenWidth * 0.2
                              : screenWidth * 0.11,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );

                case Status.ERROR:
                  return CircleAvatar(
                    radius: 25,
                    child: IconButton(
                      onPressed: () {
                        Get.toNamed(RouteName.profileScreen);
                      },
                      icon: Image.asset(ImageAssets.profileIcon),
                    ),
                  );

                case Status.COMPLETED:
                  final imageUrl = userData.userList.value.avatar?.imageUrl;
                  return IconButton(
                    onPressed: () {
                      Get.toNamed(RouteName.profileScreen);
                    },
                    icon: imageUrl?.isNotEmpty == true
                        ? ClipOval(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                color: Colors.tealAccent,
                                border: Border.all(
                                    color: AppColors.blackColor, width: 2),
                              ),
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                //  This part handles 401 or any other load failure
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    ImageAssets.defaultProfileImg,
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                  );
                                },
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              Get.toNamed(RouteName.profileScreen);
                            },
                            child: Image.asset(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              ImageAssets.profileIcon,
                              fit: BoxFit.cover,
                              width: 25,
                              height: 25,
                            ),
                          ),
                  );
              }
            }),
            SizedBox(width: screenWidth * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  switch (userData.rxRequestStatus.value) {
                    case Status.LOADING:
                      return Text(
                        "Creator",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      );
                    case Status.ERROR:
                      return const Text("Creator");
                    case Status.COMPLETED:
                      return Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        '${userData.userList.value.fullName} ',
                        style: TextStyle(
                          fontFamily: AppFonts.helveticaMedium,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      );
                  }
                }),
              ],
            ),
            const Spacer(),
            Obx(
              () => Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onPressed: () {
                      Get.toNamed(RouteName.notificationScreen);
                    },
                  ),
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
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.6),
          child: Container(
            color: AppColors.greyColor.withOpacity(0.4),
            height: 1.0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  ResponsivePadding.symmetricPadding(context, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  //**********************************************here is the dashboard Screen code *******************************/
                  Center(
                    child: CreatorDashboardWidgets(),
                  ),

                  //****************************************************Here is the Progress Container ***************************/
                  Center(
                    child: CreatorCourseProgressWidget(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Course Analytics',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      // height: screenHeight * 0.37,
                      padding: ResponsivePadding.symmetricPadding(context,
                          vertical: 2),
                      width: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.greyColor.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Course Analytics',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: AppFonts.opensansRegular,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${_creatorProfileController.creatorList.value.stats?.activeCourses.toString() ?? 0} Courses | '
                              '${_creatorProfileController.creatorList.value.stats?.totalEnrolledUsers.toString() ?? 0} Total Enrollments',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          //**********************************Creator Course EnrollMent Chart ******************************/
                          CreatorEnrolmentsBarChart(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: Container(
                      padding: ResponsivePadding.symmetricPadding(context,
                          vertical: 2),
                      // height: screenHeight * 0.37,
                      width: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.greyColor.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Course Ratings',
                            style: TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                          //**********************************Creator Course Ratings Chart *****************************8 */
                          CreatorCourseRatingsWidget(),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
