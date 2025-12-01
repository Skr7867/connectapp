import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreatorDashboardWidgets extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {"icon": Icons.group, "label": "Spaces"},
    {"icon": Icons.search, "label": "Explore"},
    {"icon": Icons.monetization_on_sharp, "label": "Coins"},
    {"icon": Icons.currency_bitcoin_sharp, "label": "Crypto"},
    {"icon": Icons.videogame_asset, "label": "Games"},
    {"icon": Icons.person_add, "label": "Refer"},
    {"icon": Icons.security, "label": "Membership"},
    {"icon": Icons.account_balance_wallet, "label": "Wallet"},
    {'icon': PhosphorIconsFill.graduationCap, "label": "Your Courses"},
    {'icon': PhosphorIconsFill.chatCircleDots, "label": "Chats"},
    {'icon': PhosphorIconsFill.video, "label": "Clips"},
    {'icon': PhosphorIconsFill.users, "label": "Your Spaces"},
  ];

  CreatorDashboardWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
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
                    Get.toNamed(RouteName.creatorMembershipScreen);
                  }
                  if (index == 7) {
                    Get.toNamed(RouteName.walletScreen);
                  }
                  if (index == 8) {
                    Get.toNamed(RouteName.creatorCourseManagementScreen);
                  }
                  if (index == 9) {
                    Get.toNamed(RouteName.messageScreen);
                  }
                  if (index == 10) {
                    Get.toNamed(RouteName.reelsScreen);
                  }
                  if (index == 11) {
                    Get.toNamed(RouteName.meetingDetailScreen);
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
