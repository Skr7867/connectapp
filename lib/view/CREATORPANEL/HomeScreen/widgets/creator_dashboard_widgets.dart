import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreatorDashboardWidgets extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      "icon": Icons.group,
      "label": "Spaces",
      "gradient": [Color(0xFF667eea), Color(0xFF764ba2)]
    },
    {
      "icon": Icons.search,
      "label": "Explore",
      "gradient": [Color(0xFFf093fb), Color(0xFFf5576c)]
    },
    {
      "icon": Icons.monetization_on_sharp,
      "label": "Coins",
      "gradient": [Color(0xFFffecd2), Color(0xFFfcb69f)]
    },
    {
      "icon": Icons.currency_bitcoin_sharp,
      "label": "Crypto",
      "gradient": [Color(0xFFff9a56), Color(0xFFff6a88)]
    },
    {
      "icon": Icons.videogame_asset,
      "label": "Games",
      "gradient": [Color(0xFF4facfe), Color(0xFF00f2fe)]
    },
    {
      "icon": Icons.person_add,
      "label": "Refer",
      "gradient": [Color(0xFF43e97b), Color(0xFF38f9d7)]
    },
    {
      "icon": Icons.security,
      "label": "Membership",
      "gradient": [Color(0xFFfa709a), Color(0xFFfee140)]
    },
    {
      "icon": Icons.account_balance_wallet,
      "label": "Wallet",
      "gradient": [Color(0xFF30cfd0), Color(0xFF330867)]
    },
    {
      'icon': PhosphorIconsFill.graduationCap,
      "label": "Your Courses",
      "gradient": [Color(0xFFa8edea), Color(0xFFfed6e3)]
    },
    {
      'icon': PhosphorIconsFill.chatCircleDots,
      "label": "Chats",
      "gradient": [Color(0xFFff6e7f), Color(0xFFbfe9ff)]
    },
    {
      'icon': PhosphorIconsFill.video,
      "label": "Clips",
      "gradient": [Color(0xFFc471f5), Color(0xFFfa71cd)]
    },
    {
      'icon': PhosphorIconsFill.users,
      "label": "Your Spaces",
      "gradient": [Color(0xFF74ebd5), Color(0xFFacb6e5)]
    },
  ];

  CreatorDashboardWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (index == 0) Get.toNamed(RouteName.newMeetingScreen);
              if (index == 1) Get.toNamed(RouteName.allUsersScreen);
              if (index == 2) Get.toNamed(RouteName.buyCoinsScreen);
              if (index == 3) Get.toNamed(RouteName.cryptoScreen);
              if (index == 4) Get.toNamed(RouteName.gamesScreen);
              if (index == 5) Get.toNamed(RouteName.treeScreen);
              if (index == 6) Get.toNamed(RouteName.creatorMembershipScreen);
              if (index == 7) Get.toNamed(RouteName.walletScreen);
              if (index == 8) {
                Get.toNamed(RouteName.creatorCourseManagementScreen);
              }
              if (index == 9) Get.toNamed(RouteName.messageScreen);
              if (index == 10) Get.toNamed(RouteName.reelsScreen);
              if (index == 11) Get.toNamed(RouteName.meetingDetailScreen);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: items[index]["gradient"],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: items[index]["gradient"][0].withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    items[index]["icon"],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  items[index]["label"],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.helveticaBold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
