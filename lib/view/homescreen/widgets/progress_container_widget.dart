import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/leaderboard/user_leaderboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../FullLeaderBoard/full_leaderboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {"icon": Icons.group, "label": "Spaces"},
    {"icon": Icons.search, "label": "Explore"},
    {"icon": Icons.monetization_on_sharp, "label": "Coins"},
    {"icon": Icons.currency_bitcoin_sharp, "label": "Crypto"},
    {"icon": Icons.videogame_asset, "label": "Games"},
    {"icon": Icons.person_add, "label": "Refer"},
    {"icon": Icons.security, "label": "Membership"},
    {"icon": Icons.account_balance_wallet, "label": "Wallet"},
    {'icon': PhosphorIconsFill.graduationCap, "label": "Enr. Courses"},
    {'icon': PhosphorIconsFill.chatCircleDots, "label": "Chats"},
    {'icon': PhosphorIconsFill.video, "label": "Clips"},
    {'icon': PhosphorIconsFill.users, "label": "Rankings"},
  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userLeaderboardData = Get.put(UserLeaderboardController());
    return SizedBox(
      height: 360,
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  if (index == 0) {
                    Get.toNamed(RouteName.newMeetingScreen);
                  }
                  if (index == 1) {
                    Get.toNamed(RouteName.allUsersScreen);
                  }
                  if (index == 2) {
                    Get.toNamed(RouteName.buyCoinsScreen);
                  }
                  if (index == 3) {
                    Get.toNamed(RouteName.cryptoScreen);
                  }
                  if (index == 4) {
                    Get.toNamed(RouteName.gamesScreen);
                  }
                  if (index == 5) {
                    Get.toNamed(RouteName.treeScreen);
                  }
                  if (index == 6) {
                    Get.toNamed(RouteName.membershipPlan);
                  }
                  if (index == 7) {
                    Get.toNamed(RouteName.walletScreen);
                  }
                  if (index == 8) {
                    Get.toNamed(RouteName.enrolledCourses);
                  }
                  if (index == 9) {
                    Get.toNamed(RouteName.messageScreen);
                  }
                  if (index == 10) {
                    Get.toNamed(RouteName.reelsScreen);
                  }
                  if (index == 11) {
                    Get.to(
                      () => FullLeaderboardScreen(
                        leaderboard: userLeaderboardData
                            .userLeaderboard.value.leaderboard,
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    items[index]["icon"],
                    color: Theme.of(context).scaffoldBackgroundColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                items[index]["label"],
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.helveticaBold),
              ),
            ],
          );
        },
      ),
    );
  }
}
