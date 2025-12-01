// import 'package:connectapp/res/color/app_colors.dart';
// import 'package:flutter/material.dart';

// class FollowListScreen extends StatefulWidget {
//   const FollowListScreen({super.key});

//   @override
//   State<FollowListScreen> createState() => _FollowListScreenState();
// }

// class _FollowListScreenState extends State<FollowListScreen> {
//   // Sample data
//   final List<Map<String, String>> users = [
//     {
//       "name": "Alex Fisher",
//       "username": "@Alex",
//       "image":
//           "https://i.pravatar.cc/150?img=1", // replace with your image url or asset
//     },
//     {
//       "name": "Sandeep Singh",
//       "username": "@sandy",
//       "image": "https://i.pravatar.cc/150?img=2",
//     },
//     {
//       "name": "Deepak Kumar",
//       "username": "@dkalal",
//       "image": "https://i.pravatar.cc/150?img=3",
//     },
//   ];

//   // Track follow states
//   final List<bool> isFollowing = [];

//   @override
//   void initState() {
//     super.initState();
//     isFollowing.addAll(List.generate(users.length, (_) => false));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 15),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: users.length,
//         itemBuilder: (context, index) {
//           return Container(
//             padding: EdgeInsets.all(5),
//             width: 160,
//             margin: const EdgeInsets.only(right: 10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade400),
//               color: AppColors.textfieldColor,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Image
//                 ClipRRect(
//                   borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(10), bottom: Radius.circular(10)),
//                   child: Image.network(
//                     users[index]["image"]!,
//                     height: 150,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 // Name + username
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         users[index]["name"]!,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: AppColors.blackColor),
//                       ),
//                       Text(
//                         users[index]["username"]!,
//                         style: const TextStyle(
//                           color: Colors.black54,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Follow button
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       minimumSize: const Size.fromHeight(40),
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         isFollowing[index] = !isFollowing[index];
//                       });
//                     },
//                     child: Text(
//                       isFollowing[index] ? "Following" : "Follow",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
