// import 'package:connectapp/view/CREATORPANEL/HomeScreen/creator_home_screen.dart';
// import 'package:connectapp/view/bottomnavbar/custom_navbar.dart';
// import 'package:connectapp/view/message/chat_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../view_models/controller/navbar/bottom_bav_bar_controller.dart';
// import '../../clip/screens/reel_upload_screen.dart';
// import '../../clip/screens/reeldatamanager.dart';
// import '../CreatorCourses/creator_course_screen.dart';

// class CreatorBottomNavBar extends StatelessWidget {
//   CreatorBottomNavBar({super.key});

//   final NavbarController _navBarController = Get.put(NavbarController());
//   final ReelsDataManager _reelsManager = Get.put(ReelsDataManager());

//   final List<Widget> screens = [
//     CreatorHomeScreen(),
//     ChatScreen(),
//     ReelsPage(),
//     CreatorCourseScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final currentIndex = _navBarController.currentIndex.value;
//       return Scaffold(
//         body: IndexedStack(
//           index: currentIndex,
//           children: screens,
//         ),
//         bottomNavigationBar: Obx(
//           () => CustomBottomNavBar(
//             currentIndex: _navBarController.currentIndex.value,
//             onTap: (index) {
//               _navBarController.currentIndex(index);

//               // Handle reels page specific logic
//               if (index == 2) {
//                 if (!_reelsManager.isInitialized.value) {
//                   _reelsManager.refreshClips();
//                 } else {}
//               } else {}
//             },
//           ),
//         ),
//       );
//     });
//   }
// }

import 'package:connectapp/view/bottomnavbar/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/view/CREATORPANEL/HomeScreen/creator_home_screen.dart';
import 'package:connectapp/view/message/chat_screen.dart';
import '../../../view_models/controller/navbar/bottom_bav_bar_controller.dart';
import '../../clip/screens/reel_upload_screen.dart';
import '../../clip/screens/reeldatamanager.dart';
import '../CreatorCourses/creator_course_screen.dart';

class CreatorBottomNavBar extends StatefulWidget {
  const CreatorBottomNavBar({super.key});

  @override
  State<CreatorBottomNavBar> createState() => _CreatorBottomNavBarState();
}

class _CreatorBottomNavBarState extends State<CreatorBottomNavBar> {
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
          return true;
        },
        child: Scaffold(
          body: IndexedStack(
            index: _navBarController.currentIndex.value,
            children: [
              CreatorHomeScreen(),
              ChatScreen(),
              ReelsPage(),
              CreatorCourseScreen(),
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
