import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../view_models/controller/navbar/bottom_bav_bar_controller.dart';

class CreatorCustomNavBar extends StatelessWidget {
  CreatorCustomNavBar(
      {super.key,
      required int currentIndex,
      required void Function(dynamic index) onTap});
  final NavbarController _navBarController = Get.put(NavbarController());

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    // Orientation orientation = MediaQuery.of(context).orientation;
    // double screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, -4), // Negative Y to show shadow at top
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent, // Disable splash effect
            highlightColor: Colors.transparent, // Disable highlight effect
          ),
          child: BottomNavigationBar(
            selectedLabelStyle: TextStyle(fontFamily: AppFonts.opensansRegular),
            unselectedLabelStyle:
                TextStyle(fontFamily: AppFonts.opensansRegular),
            useLegacyColorScheme: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _navBarController.currentIndex.value,
            onTap: (index) => _navBarController.currentIndex(index),
            selectedItemColor: AppColors.buttonColor, // Selected icon color
            unselectedItemColor: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.color, // Unselected icon color
            showSelectedLabels: true, // Show labels for selected items
            showUnselectedLabels: true, // Show labels for unselected items
            type: BottomNavigationBarType
                .fixed, // Fixed type for more than 3 items
            selectedFontSize: 15,
            unselectedFontSize: 13,
            items: [
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.house),
                activeIcon: Icon(PhosphorIconsFill.house),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.chatCircle),
                activeIcon: Icon(PhosphorIconsFill.chatCircle),
                label: 'chats'.tr,
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(PhosphorIconsRegular.monitor),
              //   activeIcon: Icon(PhosphorIconsFill.monitor),
              //   label: 'reels'.tr,
              // ),

              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.graduationCap),
                activeIcon: Icon(PhosphorIconsFill.graduationCap),
                label: 'courses'.tr,
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(PhosphorIconsRegular.bell),
              //   activeIcon: Icon(PhosphorIconsFill.bell),
              //   label: 'notification'.tr,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
