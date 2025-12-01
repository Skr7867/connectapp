import 'package:connectapp/view/CREATORPANEL/HomeScreen/creator_home_screen.dart';
import 'package:connectapp/view/bottomnavbar/custom_navbar.dart';
import 'package:connectapp/view/message/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/controller/navbar/bottom_bav_bar_controller.dart';
import '../../clip/screens/reel_upload_screen.dart';
import '../../clip/screens/reeldatamanager.dart';
import '../CreatorCourses/creator_course_screen.dart';

class CreatorBottomNavBar extends StatelessWidget {
  CreatorBottomNavBar({super.key});

  final NavbarController _navBarController = Get.put(NavbarController());
  final ReelsDataManager _reelsManager = Get.put(ReelsDataManager());

  final List<Widget> screens = [
    CreatorHomeScreen(),
    ChatScreen(),
    ReelsPage(),
    CreatorCourseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = _navBarController.currentIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Obx(
          () => CustomBottomNavBar(
            currentIndex: _navBarController.currentIndex.value,
            onTap: (index) {
              _navBarController.currentIndex(index);

              // Handle reels page specific logic
              if (index == 2) {
                if (!_reelsManager.isInitialized.value) {
                  _reelsManager.refreshClips();
                } else {}
              } else {}
            },
          ),
        ),
      );
    });
  }
}
