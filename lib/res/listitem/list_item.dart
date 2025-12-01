import 'dart:core';

import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

final List<Map<String, String>> chatData = [
  {
    "name": "Sandeep",
    "message": "Hi, How’s you? How’s everything?",
    "time": "01:06 PM",
    "image": "https://randomuser.me/api/portraits/men/11.jpg"
  },
  {
    "name": "Sandeep",
    "message": "Hello",
    "time": "01:06 PM",
    "image": "https://randomuser.me/api/portraits/men/12.jpg"
  },
  {
    "name": "Sandeep",
    "message": "How’s everything?",
    "time": "01:06 PM",
    "image": "https://randomuser.me/api/portraits/men/13.jpg"
  },
  {
    "name": "Sandeep",
    "message": "Hi, How’s you? How’s everything?",
    "time": "01:06 PM",
    "image": "https://randomuser.me/api/portraits/men/14.jpg"
  },
];

final List<Map<String, dynamic>> messages = [
  {"text": "Hello, Kya kr rhe ho", "isSender": false},
  {"text": "?", "isSender": false},
  {"text": "Kuch nhi abhi office aya hu", "isSender": true},
  {"text": "tum kaha ho", "isSender": true},
  {"text": "Main to ghar hu aaj", "isSender": false},
  {"text": "Tbyt khrab ho gyi", "isSender": false},
  {"text": "kaise kya hua", "isSender": true},
];
final todayNotifications = [
  {
    "title": "Anish",
    "subtitle": "Your notification will app...",
    "time": "10 mins ago",
    "isProfile": true,
    "imageUrl": "https://randomuser.me/api/portraits/men/32.jpg",
  },
  {
    "title": "New Course Material Available",
    "subtitle": "Check out the latest lecture...",
    "time": "12:20",
    "isProfile": false,
  },
];
final yesterdayNotifications = [
  {
    "title": "Upcoming event",
    "subtitle": "Encourage atten...",
    "time": "1 day ago",
    "isProfile": false,
  },
  {
    "title": "Pradeep kumar",
    "subtitle": "Your notification will app ...",
    "time": "10 mins ago",
    "isProfile": true,
    "imageUrl": "https://randomuser.me/api/portraits/men/55.jpg",
  },
];

List<String> settingLeading = [
  ImageAssets.membershipIcon,
  ImageAssets.missionIcon,
  ImageAssets.languageIcon,
  ImageAssets.rewardIcon,
  ImageAssets.themeIcon,
  ImageAssets.logOutIcon,
];
List<String> settingTitle = [
  'Membership Type',
  'Our Mission',
  'Change theme',
  'XP & Reward System',
  'Language Preferences',
  'Log Out'
];
List<Map<String, dynamic>> allCourses = [
  {
    'title': 'Learn Python Programming',
    'image': ImageAssets.pythonIcon,
    'category': 'Python', // 🔥 Important
  },
  {
    'title': 'Java for Beginners',
    'image': ImageAssets.pythonIcon,
    'category': 'Java',
  },
  {
    'title': 'HTML5 Masterclass',
    'image': ImageAssets.javaIcon,
    'category': 'HTML',
  },
  {
    'title': 'Full Stack Development',
    'image': ImageAssets.javaIcon,
    'category': 'All', // or whichever category it belongs
  },
];

//****************************video screen design from here ******************* */

final List<Map<String, dynamic>> users = [
  {
    "name": "Sarah Johnson",
    "xp": '⚡︎1250',
    "badge": "Top Contributor",
    "rank": 1
  },
  {"name": "Michael Chen", "xp": "⚡︎1150", "badge": "Course Master", "rank": 2},
  {
    "name": "Jessica Williams",
    "xp": "⚡︎1050",
    "badge": "Quick Learner",
    "rank": 3
  },
  {
    "name": "David Kim",
    "xp": "⚡︎960",
    "badge": "Consistent Learner",
    "rank": 4
  },
  {
    "name": "Emily Roberts",
    "xp": "⚡︎890",
    "badge": "Helpful Member",
    "rank": 5
  },
];

List<Color> usersColors = [
  Colors.yellow,
  Colors.white,
  Colors.orange,
  AppColors.blueShade,
  AppColors.blueShade,
];

List<String> eventTitle = ['Live Q&A Session', 'Group Study Session'];
List<String> eventSubtitle = [
  'Flutter Mastery Q&A with instructor',
  'AI Fundamentals study group'
];
List<String> participants = ['24 Participants, 12 Participants'];

final activityStats = [
  {
    'icon': PhosphorIconsFill.bookOpen,
    'label': '5',
    'subLabel': 'Courses Completed',
    'bgColor': Colors.green[700],
  },
  {
    'icon': PhosphorIconsFill.bookBookmark,
    'label': '2',
    'subLabel': 'Active Courses',
    'bgColor': Colors.red[400],
  },
  {
    'icon': PhosphorIconsFill.calendar,
    'label': '14',
    'subLabel': 'Days Active',
    'bgColor': Colors.amber[800],
  },
  {
    'icon': PhosphorIconsFill.trophy,
    'label': '3',
    'subLabel': 'Achievements',
    'bgColor': Colors.blue[700],
  },
];

List<String> achievementTitle = [
  'First Course Completed',
  'Week Streak',
  'Achievement Unlocked'
];
List<String> achievementSubTitle = [
  'Completed your first course on the  platform',
  'Maintained a 7-day activity streak',
  'You unlocked an achievement'
];
List<String> achievementTrailing = [
  '+100 XP',
  '+50 XP',
  '+50 XP',
];

List<Color> achievementColor = [
  Colors.greenAccent,
  Colors.yellow,
  Colors.deepPurpleAccent
];
List<IconData> achievementLeadingIcon = [
  PhosphorIconsFill.graduationCap,
  PhosphorIconsFill.calendar,
  PhosphorIconsFill.medal,
];

List<String> recentTitle = [
  'Completed Module 3 in Flutter Mastery',
  'New message from design group',
  'Earned Consistent Learner badge'
];
List<String> recentSubTitle = [
  '2 hours ago',
  '5 hours ago',
  '1 day ago',
];
List<IconData> recentLeadingIcon = [
  PhosphorIconsFill.graduationCap,
  PhosphorIconsFill.chatCircle,
  PhosphorIconsFill.medal,
];
List<String> languageTitle = [
  "English (United States)",
  "Hindi(India)",
];
List<String> languageSubTitle = [
  "English (United States)",
  "हिंदी (भारत)",
];

List<String> quickAccessIcon = [
  ImageAssets.courseIcon,
  ImageAssets.chatsIcon,
  ImageAssets.spacesIcon,
  ImageAssets.rankingIcon,
];
List<Color> quickAccessColor = [
  Colors.greenAccent,
  Colors.deepPurpleAccent,
  Colors.redAccent,
  Colors.yellow,
];

// final items = [
//   {
//     'title': 'course'.tr,
//     'icon': PhosphorIconsFill.graduationCap,
//     'color': const Color(0xFF00b894),
//     'route': () {},
//   },
//   {
//     'title': 'chats'.tr,
//     'icon': PhosphorIconsFill.chatCircleDots,
//     'color': const Color(0xFF6C5CE7),
//     'route': () {},
//   },
//   {
//     'title': 'clip'.tr,
//     'icon': PhosphorIconsFill.video,
//     'color': const Color(0xFFfd79a8),
//     'route': () {},
//   },
//   {
//     'title': 'ranking'.tr,
//     'icon': PhosphorIconsFill.trophy,
//     'color': const Color(0xFFfdcb6e),
//     'route': () {},
//   },
// ];

List<Icon> contacticons = [
  PhosphorIcon(Icons.group),
  PhosphorIcon(Icons.verified),
  PhosphorIcon(Icons.g_mobiledata_rounded),
  PhosphorIcon(Icons.message),
];

List<String> contactTitle = [
  "Community First",
  "Quality Content",
  "Global Perspective",
  "Open Communication",
];

List<String> contactSubTitle = [
  "We believe that the strength of our platform lies in the community we build. Every feature is designed with our users in mind.",
  "We bring forward high-quality, educational content that genuinely adds value to your digital experience.",
  "We embrace diversity and inclusion, bringing together people from all backgrounds to create a rich, global community.",
  "We prioritize transparent, open communication with our community, valuing feedback as essential to our growth.",
];

List<String> teamsImage = [
  'https://connect-frontend-1ogx.onrender.com/assets/Wilfried-CS2xIdch.png',
  'https://connect-frontend-1ogx.onrender.com/assets/Endi-DXVBl8KJ.png',
  'https://connect-frontend-1ogx.onrender.com/assets/Simon-BMTKfUks.png',
];

List<String> teamTitle = [
  'Wilfried Streiner',
  'Andrea Streiner',
  'Simon Streiner'
];

List<String> teamPositions = [
  'President',
  'Vice President',
  'Simon Streiner',
];

List<String> teamDescription = [
  'Wilfried has many years of experience in finance and entrepreneurship and would like to give something back - his knowledge!',
  "Andrea loves helping others - her favourite thing would be to set up an orphanage in Africa. We'd like to help!",
  "Simon is the creative brain of our team, the best ideas come from his crazy brain.",
];
