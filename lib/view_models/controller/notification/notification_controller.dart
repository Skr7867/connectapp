import 'dart:developer';

import 'package:connectapp/data/response/status.dart';
import 'package:connectapp/models/Notification/notification_module.dart';
import 'package:connectapp/repository/AllNotifications/all_notification_repository.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../userPreferences/user_preferences_screen.dart';

class NotificationController extends GetxController {
  final _api = AllNotificationRepository();
  final _prefs = UserPreferencesViewmodel();
  final socketUrl = ApiUrls.baseUrl;
  IO.Socket? socket;

  final rxRequestStatus = Status.LOADING.obs;
  final notifications = NotificationModel().obs;
  final error = ''.obs;
  final unreadCount = 0.obs;
  final connectionStatus = 'disconnected'.obs;
  final isConnecting = true.obs;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setNotifications(NotificationModel value) => notifications.value = value;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    fetchNotifications();
    initializeSocket();
  }

  // Refresh UI without API call
  @override
  void refresh() {
    update();
  }

  Future<void> _initNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      bool? initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) {
            Get.toNamed('/notifications');
          }
        },
      );
      if (initialized == true) {
        // log('Local notifications initialized successfully');
      } else {
        // log('Failed to initialize local notifications');
      }
    } catch (e) {
      // log('Error initializing local notifications: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _showNotification(Notifications notification) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id',
        'Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        notification.sId.hashCode,
        notification.title ?? 'New Notification',
        notification.message ?? 'No details',
        platformDetails,
        payload: notification.sId,
      );
    } catch (e) {
      // log('Error showing local notification: $e', stackTrace: stackTrace);
    }
  }

  Future<void> fetchNotifications() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getToken();
      if (loginData == null || loginData.isEmpty) {
        setError("Notification not found. Refresh");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: $loginData");

      final response = await _api.allNotification(loginData);
      if (response.notifications == null && response.unreadCount == null) {
        setError("No notifications found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }
      // log("API Response: ${response.toJson()}");
      setRxRequestStatus(Status.COMPLETED);
      setNotifications(response);
      unreadCount.value = response.unreadCount ?? 0;
    } catch (error) {
      // log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshNotifications() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("Refresh TOKEN: ${loginData.token}");

      final response = await _api.allNotification(loginData.token);
      if (response.notifications == null && response.unreadCount == null) {
        setError("No notifications found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }
      // log("API Response: ${response.toJson()}");
      setRxRequestStatus(Status.COMPLETED);
      setNotifications(response);
      unreadCount.value = response.unreadCount ?? 0;
    } catch (error) {
      // log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> initializeSocket() async {
    final loginData = await _prefs.getUser();
    if (loginData == null ||
        loginData.token.isEmpty ||
        loginData.user.id.isEmpty) {
      log("Socket initialization skipped: User not authenticated.");
      return;
    }

    socket = IO.io(
      socketUrl,
      IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        'user-id': loginData.user.id,
        'Authorization': 'Bearer ${loginData.token}',
      }).build(),
    );

    socket!.onConnect((_) {
      connectionStatus.value = 'connected';
      isConnecting.value = false;
    });

    socket!.onDisconnect((_) {
      log('Disconnected from socket server');
      connectionStatus.value = 'disconnected';
      isConnecting.value = false;
    });

    socket!.on('notification', (data) {
      if (data == null) return;
      // log('Notification received: $data');
      try {
        final notification = Notifications.fromJson(data);
        notifications.update((val) {
          val?.notifications?.insert(0, notification);
          unreadCount.value++;
        });
        _showNotification(notification);
      } catch (e) {
        // log('Error parsing notification: $e', stackTrace: stackTrace);
      }
    });

    socket!.on('notification-read', (data) {
      // log('Notification read event received: $data');
      if (data != null && data['notificationId'] != null) {
        notifications.update((val) {
          final index = val?.notifications
              ?.indexWhere((n) => n.sId == data['notificationId']);
          if (index != null && index >= 0) {
            val?.notifications?[index].isRead = true;
            unreadCount.value =
                unreadCount.value > 0 ? unreadCount.value - 1 : 0;
          }
        });
        notifications.refresh();
      }
    });

    socket!.on('error', (error) {
      Get.snackbar(
          'Error', 'Error connecting to the server. Please try again later.',
          backgroundColor: Colors.red, colorText: Colors.white);
    });

    socket!.on('connect_timeout', (timeout) {
      // log('Connection timeout: $timeout');
    });

    socket!.on('reconnect_attempt', (attempt) {
      // log('Reconnect attempt: $attempt');
    });

    socket!.on('reconnect_error', (err) {
      // log('Reconnect error: $err');
    });

    socket!.emit('join', loginData.user.id);
  }

  Future<void> markNotificationRead(String notificationId) async {
    final loginData = await _prefs.getUser();
    if (loginData == null || loginData.user.id.isEmpty) {
      // log("Cannot mark notification as read: User not authenticated.");
      Get.snackbar('Error', 'User not authenticated. Please log in again.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (notificationId.isEmpty) {
      // log("Cannot mark notification as read: Invalid notification ID.");
      Get.snackbar('Error', 'Invalid notification ID.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      // Emit socket event
      if (socket != null && socket!.connected) {
        // log('Emitting notification-read for ID: $notificationId');
        socket!.emit('notification-read', {
          'notificationId': notificationId,
          'userId': loginData.user.id,
        });
      }

      // Update local notifications
      notifications.update((val) {
        final index =
            val?.notifications?.indexWhere((n) => n.sId == notificationId);
        if (index != null && index >= 0) {
          val?.notifications?[index].isRead = true;
          unreadCount.value = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
        }
      });
      notifications.refresh();
      // log('Notification marked as read locally: $notificationId');
    } catch (e) {
      // log('Error marking notification as read: $e', stackTrace: stackTrace);
      Get.snackbar(
          'Error', 'Failed to mark notification as read. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void disconnectSocket() {
    if (socket != null) {
      socket!.off('notification');
      socket!.off('notification-read');
      socket!.off('error');
      socket!.off('connect_timeout');
      socket!.off('reconnect_attempt');
      socket!.off('reconnect_error');
      socket!.disconnect();
      socket = null;
      connectionStatus.value = 'disconnected';
    }
  }

  @override
  void onClose() {
    disconnectSocket();
    super.onClose();
  }
}
