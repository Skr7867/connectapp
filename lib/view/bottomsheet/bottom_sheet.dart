// // File: bottom_sheets/theme_bottom_sheet.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../view_models/controller/themeController/theme_controller.dart';

// void showThemeBottomSheet(BuildContext context) {
//   final themeController = Get.find<ThemeController>();

//   showModalBottomSheet(
//     context: context,
//     builder: (_) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             title: const Text('Light Theme'),
//             onTap: () {
//               themeController.setTheme(ThemeMode.light);
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Dark Theme'),
//             onTap: () {
//               themeController.setTheme(ThemeMode.dark);
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Custom Red Theme'),
//             onTap: () {
//               Get.changeTheme(ThemeData(
//                 brightness: Brightness.light,
//                 primarySwatch: Colors.red,
//                 scaffoldBackgroundColor: Colors.red.shade50,
//               ));
//               themeController.setTheme(ThemeMode.light);
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Custom Blue Theme'),
//             onTap: () {
//               Get.changeTheme(ThemeData(
//                 brightness: Brightness.light,
//                 primarySwatch: Colors.blue,
//                 scaffoldBackgroundColor: Colors.blue.shade50,
//               ));
//               themeController.setTheme(ThemeMode.light);
//               Get.back();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
