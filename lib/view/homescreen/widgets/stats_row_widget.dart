import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../res/color/app_colors.dart';
import '../../../view_models/controller/profile/user_profile_controller.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Get.put(UserProfileController());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          icon: Icons.track_changes,
          value: Obx(() {
            switch (userData.rxRequestStatus.value) {
              case Status.LOADING:
                return SizedBox(width: 10, child: Text('0'));
              case Status.ERROR:
                return const Text("0");
              case Status.COMPLETED:
                return Text(
                  userData.userList.value.level.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: AppFonts.helveticaMedium,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
            }
          }),
          label: "Level",
        ),
        const SizedBox(width: 70),
        _StatItem(
          icon: Icons.local_fire_department,
          value: Obx(() {
            switch (userData.rxRequestStatus.value) {
              case Status.LOADING:
                return SizedBox(width: 10, child: Text('0'));
              case Status.ERROR:
                return const Text("0");
              case Status.COMPLETED:
                return Text(
                  userData.userList.value.maxStreak.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: AppFonts.helveticaMedium,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
            }
          }),
          label: "Streak",
        ),
        const SizedBox(width: 70),
        _StatItem(
          icon: Icons.wallet,
          value: Obx(() {
            switch (userData.rxRequestStatus.value) {
              case Status.LOADING:
                return SizedBox(width: 10, child: Text('0'));
              case Status.ERROR:
                return const Text(
                  '0',
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                );
              case Status.COMPLETED:
                return Text(
                  userData.userList.value.wallet!.coins.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: AppFonts.helveticaMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                );
            }
          }),
          label: "Coins",
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Widget value; // <-- Changed from String to Widget
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 5),
            value,
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.helveticaMedium,
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
