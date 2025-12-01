
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:get/get.dart';
import '../../main.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';
import 'chat_open_tracker.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      // onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _navigateFromPayload(data);
        }
      },
    );

    await _requestPermissions();
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    RemoteMessage fakeMessage = RemoteMessage(data: data);
    _navigateFromMessage(fakeMessage);
  }

  void _navigateFromMessage(RemoteMessage message) {
    try {
      final data = message.data;
      if (data.isEmpty) return;
      isDeepLinkHandled = true;
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 100), () {
      isDeepLinkHandled = false;
    });
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final payloadData = jsonDecode(response.payload!);
        _handleNotificationTapFromPayload(payloadData);
      } catch (e) {
        log('Error parsing notification payload: $e');
      }
    }
  }

  void handleNotificationOpen(RemoteMessage message) {
    try {
      final data = message.data;
      final payloadData = {
        ...data,
        'notificationId': message.messageId ?? '',
        'title': message.notification?.title ?? data['title'] ?? '',
        'body': message.notification?.body ?? data['message'] ?? '',
      };

      Future.delayed(const Duration(milliseconds: 500), () async {
        final userPrefs = Get.find<UserPreferencesViewmodel>();
        final userData = await userPrefs.getUser();
        if (userData?.token == null) {
          log('⚠️ Notification open: No auth token, redirecting to login');
          Get.offAllNamed(RouteName.loginScreen);
          return;
        }
        log('✅ Notification open: Auth ready, navigating...');
        _handleNotificationTapFromPayload(payloadData);
      });
    } catch (e) {
      log('Error handling notification open: $e');
    }
  }

  void _handleNotificationTapFromPayload(Map<String, dynamic> data) {
    log('🔍 Handling payload: $data');

    if (data.containsKey('chatId')) {
      final chatId = data['chatId'];
      final isGroup = data['isGroup'] == 'true' || data['isGroup'] == true;
      _navigateToChat(chatId, isGroup);
      return;
    }

    final type = (data['type'] ?? '').toLowerCase();
    final title = (data['title'] ?? '').toLowerCase();
    final message = (data['message'] ?? '').toLowerCase();

    if (type == 'xp') {
      Get.offAllNamed(RouteName.streakExploreScreen);
    } else if (type == 'social') {
      if (title.contains('follower') || message.contains('started following')) {
        final userId = data['fromUserId'];
        if (userId != null &&
            userId.toString().isNotEmpty &&
            userId != 'null') {
          Get.offAllNamed(RouteName.clipProfieScreen, arguments: userId);
        } else {
          Get.offAllNamed(RouteName.reelsPage);
        }
      } else if (title.contains('comment') || message.contains('commented')) {
        final clipId = data['clipId'];
        if (clipId != null && clipId.toString().isNotEmpty) {
          Get.offAllNamed(
            RouteName.clipPlayScreen,
            arguments: {'clipId': clipId, 'openComments': true},
          );
        } else {
          Get.offAllNamed(RouteName.reelsPage);
        }
      } else if (title.contains('mention') || message.contains('mentioned')) {
        final clipId = data['clipId'];
        if (clipId != null && clipId.toString().isNotEmpty) {
          Get.offAllNamed(
            RouteName.clipPlayScreen,
            arguments: {'clipId': clipId, 'openComments': true},
          );
        } else {
          Get.offAllNamed(RouteName.reelsPage);
        }
      } else if (title.contains('clip uploaded')) {
        final clipId = data['clipId'];
        if (clipId != null && clipId.toString().isNotEmpty) {
          Get.offAllNamed(
            RouteName.clipPlayScreen,
            arguments: {'clipId': clipId, 'openComments': false},
          );
        } else {
          Get.offAllNamed(RouteName.reelsPage);
        }
      } else {
        Get.offAllNamed(RouteName.clipProfieScreen);
      }
    } else if (type == 'avatar') {
      Get.offAllNamed(RouteName.usersAvatarScreen);
    } else {
      final userId = data['userId'];
      if (userId != null && userId.toString().isNotEmpty && userId != 'null') {
        Get.offAllNamed(RouteName.clipProfieScreen, arguments: userId);
      } else {
        Get.offAllNamed(RouteName.reelsPage);
      }
    }
  }

  void _navigateToChat(String chatId, bool isGroup) {
    if (isGroup) {
      Get.offAllNamed(RouteName.chatscreen,
          arguments: {'chatId': chatId, 'isGroup': true});
    } else {
      Get.offAllNamed(RouteName.chatscreen, arguments: {'chatId': chatId});
    }
    clearChatNotifications(chatId);
  }

  // ✅ MAIN FIX: Format message based on type
  String _formatMessageBody(String body, String messageType) {
    if (messageType == 'sticker' && Uri.tryParse(body)?.isAbsolute == true) {
      return "📸 sent a sticker";
    } else if (messageType == 'file') {
      final lowerBody = body.toLowerCase();
      if (lowerBody.endsWith('.mp4') || lowerBody.endsWith('.mov')) {
        return "📹 sent a video";
      } else if (lowerBody.endsWith('.mp3') || lowerBody.endsWith('.wav')) {
        return "🎧 sent an audio message";
      } else if (lowerBody.endsWith('.pdf')) {
        return "📄 sent a document";
      } else if (lowerBody.contains('.jpg') ||
          lowerBody.contains('.jpeg') ||
          lowerBody.contains('.png')) {
        return "📸 sent a photo";
      } else {
        return "📎 sent a file";
      }
    } else if (messageType == 'emoji') {
      return body.isNotEmpty ? body : "😊 sent an emoji";
    }
    return body;
  }

  Future<void> showNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      // ✅ Get title and determine body
      final title = notification?.title ?? data['title'] ?? 'Notification';
      final messageType = data['messageType'] ?? 'text';

      // ✅ Use 'message' field if available (formatted by backend), else format 'body'
      String body;
      if (data.containsKey('message') &&
          data['message'].toString().isNotEmpty) {
        body = data['message']; // Backend already formatted it
      } else {
        final rawBody = notification?.body ?? data['body'] ?? '';
        body = _formatMessageBody(rawBody, messageType);
      }

      // Full payload for tap handling
      final payload = jsonEncode({
        ...data,
        'notificationId': message.messageId ?? '',
        'title': title,
        'body': body,
      });

      // Chat-specific notification
      if (data['chatId'] != null) {
        await showMessageNotification(
          chatId: data['chatId'],
          senderName: data['senderName'] ?? title,
          message: body,
          isGroup: data['isGroup'] == 'true' || data['isGroup'] == true,
          groupName: data['groupName'],
          avatar: data['avatar'],
          payload: payload,
        );
      } else {
        // General app notification
        await _showGeneralNotification(title, body, payload);
      }
    } catch (e) {
      log(' Error in showNotification: $e');
    }
  }

  Future<void> showMessageNotification({
    required String chatId,
    required String senderName,
    required String message,
    required bool isGroup,
    String? groupName,
    String? avatar,
    String? payload,
  }) async {
    // -------------------------------
    // 🔥 1. BLOCK completely if inside same chat
    // -------------------------------
    if (ChatOpenTracker.currentChatId != null &&
        ChatOpenTracker.currentChatId == chatId) {
      log("🔕 Blocked notification — inside chat $chatId");
      return;
    }

    // -------------------------------
    //  Detect if app is in foreground using Flutter lifecycle
    // -------------------------------
    final bool isInForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    if (isInForeground) {
      log("📳 App foreground — Showing silent notification only");
    } else {
      log("🔔 App background — full sound + vibration");
    }

    // -------------------------------
    // 3. Prepare title + message
    // -------------------------------
    final notificationId = chatId.hashCode;
    final title = isGroup ? '$senderName in $groupName' : senderName;

    final existingMessages = await _getStoredMessages(chatId);
    existingMessages.add({
      'sender': senderName,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await _storeMessages(chatId, existingMessages);
    final androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for incoming chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,

      playSound: !isInForeground, // 🔥 no sound in foreground
      enableVibration: !isInForeground, // 🔥 no vibration in foreground

      largeIcon: avatar != null ? FilePathAndroidBitmap(avatar) : null,

      styleInformation: _buildMessagingStyle(
        existingMessages,
        senderName,
        isGroup,
        groupName,
      ),
    );

    // -------------------------------
    // 5. iOS Notification (silent in foreground)
    // -------------------------------
    final iosDetails = DarwinNotificationDetails(
      presentAlert: !isInForeground,
      presentSound: !isInForeground,
      presentBadge: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // -------------------------------
    // 6. Final payload
    // -------------------------------
    final finalPayload = payload ??
        jsonEncode({
          'chatId': chatId,
          'isGroup': isGroup,
          'senderName': senderName,
        });

    try {
      await _notifications.show(
        notificationId,
        title,
        message,
        notificationDetails,
        payload: finalPayload,
      );
    } catch (e) {
      log('❌ Error showing notification: $e');
    }

    await _updateBadgeCount();
  }

  Future<void> _showGeneralNotification(
      String title, String body, String payload) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'general_notifications',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      log('❌ Error showing general notification: $e');
    }

    await _updateBadgeCount();
  }

  MessagingStyleInformation _buildMessagingStyle(
    List<Map<String, dynamic>> messages,
    String currentSender,
    bool isGroup,
    String? groupName,
  ) {
    final conversationTitle = isGroup ? groupName : null;

    return MessagingStyleInformation(
      Person(name: 'You', key: 'user'),
      groupConversation: isGroup,
      conversationTitle: conversationTitle,
      messages: messages.map((msg) {
        return Message(
          msg['message'],
          DateTime.fromMillisecondsSinceEpoch(msg['timestamp']),
          Person(name: msg['sender'], key: msg['sender']),
        );
      }).toList(),
    );
  }

  Future<bool> _isAppInForeground() async {
    return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  Future<List<Map<String, dynamic>>> _getStoredMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('notification_messages_$chatId');
    if (messagesJson != null) {
      final List<dynamic> messagesList = jsonDecode(messagesJson);
      return messagesList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> _storeMessages(
      String chatId, List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final recentMessages =
        messages.length > 5 ? messages.sublist(messages.length - 5) : messages;
    await prefs.setString(
        'notification_messages_$chatId', jsonEncode(recentMessages));
  }

  Future<void> clearChatNotifications(String chatId) async {
    final notificationId = chatId.hashCode;
    await _notifications.cancel(notificationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_messages_$chatId');
  }

  Future<void> _updateBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBadge = prefs.getInt('badge_count') ?? 0;
    await prefs.setInt('badge_count', currentBadge + 1);
  }

  Future<void> clearBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('badge_count', 0);
  }
}
