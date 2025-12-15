import 'package:connectapp/view/bottomnavbar/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/navbar/bottom_bav_bar_controller.dart';
import '../clip/screens/reel_upload_screen.dart';
import '../clip/screens/reeldatamanager.dart';
import '../courses/new_course_design_screen.dart';
import '../homescreen/home_screen.dart';
import '../message/chat_screen.dart';

class BottomnavBar extends StatefulWidget {
  const BottomnavBar({super.key});

  @override
  State<BottomnavBar> createState() => _BottomnavBarState();
}

class _BottomnavBarState extends State<BottomnavBar> {
  final NavbarController _navBarController = Get.put(NavbarController());
  final ReelsDataManager _reelsManager = Get.put(ReelsDataManager());

  String? directUserId;
  int? openTab;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;

    if (args != null) {
      openTab = args['open_tab'];
      directUserId = args['direct_user_id'];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (openTab != null) {
        _navBarController.currentIndex(openTab!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return WillPopScope(
        onWillPop: () async {
          // If NOT on Home tab → go to Home instead of closing app
          if (_navBarController.currentIndex.value != 0) {
            _navBarController.currentIndex(0);
            return false; // Prevent app exit
          }

          // If already on Home tab → allow exit
          return true;
        },
        child: Scaffold(
          body: IndexedStack(
            index: _navBarController.currentIndex.value,
            children: [
              HomeScreen(),
              ChatScreen(directUserId: directUserId),
              ReelsPage(),
              NewCourseDesignScreen(),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _navBarController.currentIndex.value,
            onTap: (index) {
              _navBarController.currentIndex(index);

              if (index == 2) {
                if (!_reelsManager.isInitialized.value) {
                  _reelsManager.refreshClips();
                }
              }
            },
          ),
        ),
      );
    });
  }
}
