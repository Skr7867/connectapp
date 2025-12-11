import 'dart:developer';
import 'package:connectapp/firebase_options.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/constant/myconst.dart';
import 'package:connectapp/res/getx_localization/language.dart';
import 'package:connectapp/res/routes/routes.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/utils/notification_mute_manager.dart';
import 'package:connectapp/view/message/backgroundservice.dart';
import 'package:connectapp/view/message/notificationservice.dart';
import 'package:connectapp/view_models/controller/language/language_controller.dart';
import 'package:connectapp/view_models/controller/notification/notification_controller.dart';
import 'package:connectapp/view_models/controller/repostClips/repost_clip_controller.dart';
import 'package:connectapp/view_models/controller/themeController/theme_controller.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:connectapp/view_models/controller/useravatar/user_avatar_controller.dart';
import 'package:connectapp/data/FcmService/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links5/uni_links.dart';

import 'view/message/applifecycle.dart';
import 'view/message/chat_open_tracker.dart';
import 'view_models/controller/TaggingInComment/tag_controller.dart';
import 'view_models/controller/allFollowers/all_followers_controller.dart';
import 'view_models/controller/getClipByid/comment_controller.dart';
import 'view_models/controller/groupUnreadCount/group_unread_count_controller.dart';
import 'view_models/controller/leaderboard/user_leaderboard_controller.dart';
import 'view_models/controller/profile/user_profile_controller.dart';
import 'view_models/controller/unreadCount/unread_count_controller.dart';

bool isDeepLinkHandled = false;
String? lastMessageId;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService().showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  await GetStorage.init();

  // ⭐ HANDLE REFERRAL BEFORE ANYTHING ELSE
  await _initReferralDeepLinks();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Stripe.publishableKey = Myconst.publicKey;
  await Stripe.instance.applySettings();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  Get.put(NotificationController(), permanent: true);
  Get.put(RepostClipController(), permanent: true);
  Get.put(UserAvatarController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(UserProfileController(), permanent: true);
  Get.put(UserLeaderboardController(), permanent: true);
  Get.put(UnreadCountController(), permanent: true);
  Get.put(GroupUnreadCountController(), permanent: true);
  Get.put(AllFollowersController(), permanent: true);
  Get.put(CommentsController(), permanent: true);
  Get.put(TaggingController(), permanent: true);
  await NotificationMuteUtil.init();

  String? languageCode = prefs.getString('language_code');
  String? countryCode = prefs.getString('country_code');

  Locale savedLocale = (languageCode != null && countryCode != null)
      ? Locale(languageCode, countryCode)
      : const Locale('en', 'US');

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  BackgroundService.initialize();

  runApp(MyApp(savedLocale, initialMessage: initialMessage));
}

Future<void> _initReferralDeepLinks() async {
  final initialUri = await getInitialUri();

  if (initialUri != null) {
    final ref = initialUri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("referralCode", ref);
      log("Referral Saved (cold start): $ref");
      Future.microtask(() {
        Get.offAllNamed(RouteName.signupScreen);
      });
    }
  }

  // App already running
  uriLinkStream.listen((uri) async {
    if (uri != null) {
      final ref = uri.queryParameters['ref'];
      if (ref != null && ref.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("referralCode", ref);
        log("Referral Saved (stream): $ref");

        Get.offAllNamed(RouteName.signupScreen);
      }
    }
  });
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  final RemoteMessage? initialMessage;
  const MyApp(this.initialLocale, {this.initialMessage, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      Future.microtask(() => _navigateFromMessage(widget.initialMessage!));
    }
    _initFirebaseMessaging();
  }

  Future<void> _initFirebaseMessaging() async {
    messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final userPrefs = UserPreferencesViewmodel();
    await userPrefs.init();
    final userData = await userPrefs.getUser();
    final authToken = userData?.token;

    // Register token
    String? fcmToken = await messaging.getToken();
    if (authToken != null && fcmToken != null) {
      await FCMService.registerFCMToken(fcmToken, authToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (authToken != null) {
        await FCMService.registerFCMToken(newToken, authToken);
      }
    });

    // Subscribe to topic
    await messaging.subscribeToTopic('ConnectApp');

    FirebaseMessaging.onMessage.listen((message) {
      final data = message.data;
      final incomingChatId = data['chatId'];
      final isGroup = data['isGroup'] == true || data['isGroup'] == 'true';
      log("[FG] Foreground message received from chat: $incomingChatId");
      log('gf $data');

      if (incomingChatId != null &&
          ChatOpenTracker.currentChatId != null &&
          ChatOpenTracker.currentChatId == incomingChatId) {
        log("Message ignored — already inside chat $incomingChatId");
        return;
      }

      if (message.messageId != null && message.messageId == lastMessageId) {
        return;
      }
      lastMessageId = message.messageId;
      if (incomingChatId != null) {
        if (isGroup) {
          Get.find<GroupUnreadCountController>()
              .incrementGroupUnread(incomingChatId);
        } else {
          Get.find<UnreadCountController>().incrementUnread(incomingChatId);
        }
      }

      NotificationService().showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Future.microtask(() => _navigateFromMessage(message));
    });

    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null && !isDeepLinkHandled) {
      isDeepLinkHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateFromMessage(initialMessage);
      });
    }
  }

  // Handle notification-based navigation
  void _navigateFromMessage(RemoteMessage message) {
    try {
      if (AppLifecycleService.isDeepLinkActive) {
        print("Skipping: Deep link is already navigating");
        return;
      }
      if (isDeepLinkHandled) {
        log("Skipping FCM navigation — deep link already handled");
        return;
      }

      final data = message.data;
      if (data.isEmpty) return;
      if (data.isEmpty &&
          (message.notification?.title?.isEmpty ?? true) &&
          (message.notification?.body?.isEmpty ?? true)) {
        log("Ignoring empty FCM message");
        return;
      }
      isDeepLinkHandled = true;

      final title =
          (data['title'] ?? message.notification?.title ?? '').toLowerCase();
      final msg =
          (data['message'] ?? message.notification?.body ?? '').toLowerCase();
      final type = (data['type'] ?? '').toLowerCase();
      final fromUserId = (data['fromUserId'] ?? '').trim();
      final clipId = (data['clipId'] ?? '').trim();

      isDeepLinkHandled = true;

      if (type == 'chat') {
        final senderId = (data['chatId'] ?? '').trim();
        final groupName = (data['groupName'] ?? '').trim();
        if (senderId.isNotEmpty) {
          Get.offAllNamed(RouteName.bottomNavbar, arguments: {
            'chatId': data['chatId'],
            'isfromnoticlick': true,
            'open_tab': 1,
          });
        } else if (groupName.isNotEmpty) {
          Get.offAllNamed(RouteName.bottomNavbar, arguments: {
            'chatId': data['chatId'],
            'isfromnoticlick': true,
            'open_tab': 1,
          });
        }
        return;
      }

      if (type == 'social') {
        if (title.contains('follower') ||
            msg.contains('started following you')) {
          if (fromUserId.isNotEmpty) {
            Get.toNamed(RouteName.clipProfieScreen, arguments: fromUserId);
          } else {
            Get.snackbar('Info', 'Follower details not available',
                backgroundColor: AppColors.blueColor,
                colorText: AppColors.whiteColor);
          }
        } else if (title.contains('comment') || msg.contains('commented')) {
          if (clipId.isNotEmpty) {
            Get.toNamed(
              RouteName.clipPlayScreen,
              arguments: clipId,
            );
          } else {
            Get.snackbar('Info', 'Clip details not found',
                backgroundColor: Colors.orange);
          }
        } else if (title.contains('mention') ||
            msg.contains('mentioned') ||
            title.contains('clip uploaded')) {
          if (clipId.isNotEmpty) {
            Get.toNamed(RouteName.clipPlayScreen, arguments: clipId);
          } else {
            Get.toNamed(RouteName.reelsPage);
          }
        } else {
          Get.toNamed(RouteName.reelsPage);
        }
      } else if (type == 'avatar') {
        Get.toNamed(RouteName.usersAvatarScreen);
      } else if (type == 'level_up') {
        Get.toNamed(RouteName.profileScreen);
      } else if (type == 'xp') {
        Get.toNamed(RouteName.streakExploreScreen);
      } else {
        Get.toNamed(RouteName.homeScreen);
      }
    } catch (e) {
      print("Navigation error: $e");
      Get.toNamed(RouteName.homeScreen);
    }
    Future.delayed(const Duration(microseconds: 100), () {
      isDeepLinkHandled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Obx(() => GetMaterialApp(
          translations: Language(),
          locale: languageController.currentLocale.value,
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          getPages: AppRoutes.appRoutes(),
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
        ));
  }
}
