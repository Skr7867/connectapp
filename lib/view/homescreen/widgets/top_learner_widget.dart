import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/view_models/controller/leaderboard/user_leaderboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/routes/routes_name.dart';

class TopLearnerWidget extends StatefulWidget {
  const TopLearnerWidget({super.key});

  @override
  State<TopLearnerWidget> createState() => _TopLearnerWidgetState();
}

class _TopLearnerWidgetState extends State<TopLearnerWidget> {
  final userLeaderboardData = Get.put(UserLeaderboardController());
  @override
  void initState() {
    super.initState();
    userLeaderboardData.userListApi();
  }

  Future<void> onRefresh() async {
    userLeaderboardData.userListApi();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    final List<Color> rankColors = [
      Colors.amber,
      Colors.grey,
      Colors.pink,
      Colors.blue,
      Colors.green,
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Center(
        child: Container(
          // height: screenHeight * 0.58,
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            color: AppColors.loginContainerColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Obx(() {
            final status = userLeaderboardData.rxRequestStatus.value;
            final leaderboard =
                userLeaderboardData.userLeaderboard.value.leaderboard;
            final currentUser =
                userLeaderboardData.userLeaderboard.value.currentUser;

            if (status == Status.LOADING) {
              return const Center(
                  child: CircularProgressIndicator(
                color: AppColors.whiteColor,
              ));
            } else if (status == Status.ERROR) {
              return Center(
                child: Text(
                  'Slow Internet Connection',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              );
            }

            // Limit to top 5 users (or fewer if leaderboard is smaller)
            final topUsers = leaderboard.length > 5
                ? leaderboard.sublist(0, 5)
                : leaderboard;

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: topUsers.length,
                  itemBuilder: (context, index) {
                    final user = topUsers[index];
                    final initials = user.fullName
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .join()
                        .toUpperCase();
                    final badge = 'Level ${user.level}';

                    return Column(
                      children: [
                        ListTile(
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    RouteName.clipProfieScreen,
                                    arguments: user.id,
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.buttonColor,
                                  child: user.avatar.imageUrl.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            user.avatar.imageUrl,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Text(
                                              initials,
                                              style: TextStyle(
                                                color: AppColors.whiteColor,
                                                fontFamily:
                                                    AppFonts.helveticaMedium,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          initials,
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontFamily:
                                                AppFonts.helveticaMedium,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                top: screenHeight * 0.02,
                                right: -1,
                                child: Container(
                                  height: screenHeight * 0.04,
                                  width: screenWidth * 0.04,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.blackColor, width: 1),
                                    color:
                                        rankColors[index % rankColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${user.rank}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: AppFonts.opensansRegular,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            user.fullName,
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontFamily: AppFonts.helveticaMedium,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            '${user.xp} XP',
                            style: TextStyle(
                              color: rankColors[index % rankColors.length],
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Container(
                            height: orientation == Orientation.portrait
                                ? screenHeight * 0.03
                                : screenHeight * 0.05,
                            width: orientation == Orientation.portrait
                                ? screenWidth * 0.3
                                : screenWidth * 0.17,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: rankColors[index % rankColors.length]
                                  .withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: rankColors[index % rankColors.length],
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            color: Colors.grey.withOpacity(0.3),
                            thickness: 0.7,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: ResponsivePadding.customPadding(context,
                      right: orientation == Orientation.portrait ? 53 : 70),
                  child: Text(
                    'your_position'.tr,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                        color: AppColors.blackColor),
                  ),
                ),
                // Current User Position
                ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.toNamed(
                            RouteName.profileScreen,
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.buttonColor,
                          child: Text(
                            currentUser.fullName
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .join()
                                .toUpperCase(),
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontFamily: AppFonts.opensansRegular,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.02,
                        right: -1,
                        child: Container(
                          height: screenHeight * 0.04,
                          width: screenWidth * 0.04,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.blackColor, width: 1),
                            color: rankColors[
                                (currentUser.rank - 1) % rankColors.length],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${currentUser.rank}',
                              style: TextStyle(
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: AppFonts.helveticaMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    currentUser.fullName,
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontFamily: AppFonts.helveticaMedium,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    '${currentUser.xp} XP',
                    style: TextStyle(
                      color: rankColors[
                          (currentUser.rank - 1) % rankColors.length],
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Container(
                    height: orientation == Orientation.portrait
                        ? screenHeight * 0.03
                        : screenHeight * 0.05,
                    width: orientation == Orientation.portrait
                        ? screenWidth * 0.3
                        : screenWidth * 0.17,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color:
                          rankColors[(currentUser.rank - 1) % rankColors.length]
                              .withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        'Level ${currentUser.level}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: rankColors[
                              (currentUser.rank - 1) % rankColors.length],
                          fontFamily: AppFonts.opensansRegular,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: screenHeight * 0.02),
                // Center(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(25),
                //       border:
                //           Border.all(color: AppColors.buttonColor, width: 1),
                //     ),
                //     child: RoundButton(
                //       width: screenWidth * 0.85,
                //       buttonColor: AppColors.loginContainerColor,
                //       title: 'leaderboard'.tr,
                //       onPress: () {
                //         Get.to(() => FullLeaderboardScreen(
                //               leaderboard: userLeaderboardData
                //                   .userLeaderboard.value.leaderboard,
                //             ));
                //       },
                //     ),
                //   ),
                // ),
                SizedBox(height: screenHeight * 0.02)
              ],
            );
          }),
        ),
      ),
    );
  }
}
