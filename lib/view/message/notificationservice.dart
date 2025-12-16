import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../res/routes/routes_name.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isHandlingTap = false; // prevent double-navigation

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _createNotificationChannels();
    await _requestPermissions();

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Listen for taps coming from MainActivity (terminated/foreground)
    const MethodChannel channel = MethodChannel("notification_tap_channel");

    channel.setMethodCallHandler((call) async {
      if (call.method == "notificationTap") {
        if (_isHandlingTap) return;
        _isHandlingTap = true;

        final data = Map<String, dynamic>.from(call.arguments);
        log("🔔 Tap from ANDROID → $data");

        _navigate(data);

        Future.delayed(const Duration(milliseconds: 300), () {
          _isHandlingTap = false;
        });
      }
    });

    log("🚀 NotificationService initialized");
  }

  // ----------------------------- TAP FROM NOTIFICATION ---------------------

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    if (_isHandlingTap) return;
    _isHandlingTap = true;

    try {
      final data = jsonDecode(response.payload!);
      _navigate(data);
    } catch (e) {
      log("❌ decode error: $e");
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _isHandlingTap = false;
    });
  }

  // ----------------------------- NAVIGATION HANDLER ------------------------

  void _navigate(Map<String, dynamic> data) {
    log("🚀 NAVIGATE → $data");

    // Extract inner payload if exists
    if (data.containsKey('payload')) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(data['payload']));
      } catch (_) {}
    }

    // CHAT NOTIFICATION
    if (data['chatId'] != null && data['chatId'].toString().isNotEmpty) {
      _navigateToChat(data['chatId'], data['isGroup'] == true);
      return;
    }

    final type = (data['type'] ?? "").toLowerCase();
    final title = (data['title'] ?? "").toLowerCase();
    final message = (data['message'] ?? "").toLowerCase();

    // SOCIAL
    if (type == "social") {
      _navigateSocial(data, title, message);
      return;
    }

    if (type == "xp") {
      Get.toNamed(RouteName.streakExploreScreen);
      return;
    }

    if (type == "avatar") {
      Get.toNamed(RouteName.usersAvatarScreen);
      return;
    }

    // DEFAULT → Notification Screen
    Get.toNamed(RouteName.notificationScreen);
  }

  // --------------------------- SOCIAL HANDLING -----------------------------

  void _navigateSocial(
      Map<String, dynamic> data, String title, String message) {
    final clipId = data['clipId']?.toString();
    final userId = data['fromUserId']?.toString();

    // FOLLOWER
    if (title.contains("follow") || message.contains("started following")) {
      if (userId != null && userId.isNotEmpty) {
        Get.toNamed(RouteName.clipProfieScreen, arguments: userId);
        return;
      }
    }

    // COMMENT
    if (title.contains("comment") || message.contains("commented")) {
      if (clipId != null && clipId.isNotEmpty) {
        Get.toNamed(RouteName.clipPlayScreen, arguments: {'clipId': clipId});
        return;
      }
    }

    Get.toNamed(RouteName.notificationScreen);
  }

  // --------------------------- CHAT NAVIGATION -----------------------------

  void _navigateToChat(String chatId, bool isGroup) {
    Get.toNamed(
      RouteName.bottomNavbar,
      arguments: {
        'chatId': chatId,
        'open_tab': 1,
        'isfromnoticlick': true,
      },
    );

    clearChatNotifications(chatId);
  }

  // --------------------------- NOTIFICATION CHANNELS ------------------------

  Future<void> _createNotificationChannels() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'chat_messages',
        'Chat Messages',
        description: 'Messages',
        importance: Importance.max,
      ),
    );

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'general_notifications',
        'General Notifications',
        description: 'General Alerts',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
  }

  // --------------------------- SHOW NOTIFICATION ---------------------------

  Future<void> showNotification(RemoteMessage message) async {
    final data = message.data;
    final title = data['title'] ?? "Notification";
    final body = data['message'] ?? data['body'] ?? "";

    final payload = jsonEncode({
      ...data,
      'title': title,
      'body': body,
    });

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'general_notifications',
          'General Notifications',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      payload: payload,
    );
  }

  // --------------------------- Clear chat bubble ---------------------------

  Future<void> clearChatNotifications(String chatId) async {
    await _notifications.cancel(chatId.hashCode);
  }
}
