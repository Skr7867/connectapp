import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationMuteUtil {
  static const String _muteStateKey = 'notifications_muted';
  static const String _muteExpiryKey = 'mute_expiry_timestamp';

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications (call this in main.dart)
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  /// Toggle notification mute state with options dialog
  static Future<void> toggleMute(BuildContext context) async {
    final isMuted = await _isCurrentlyMuted();

    if (isMuted) {
      // If currently muted, unmute immediately
      await _unmute();
      _showSnackBar(context, 'Notifications enabled', Colors.green);
    } else {
      // If not muted, show mute options
      _showMuteOptionsDialog(context);
    }
  }

  /// Quick mute for specific duration (for direct button usage)
  static Future<void> quickMute(BuildContext context,
      {Duration? duration}) async {
    await _mute(duration: duration);

    final message = duration != null
        ? 'Muted for ${_formatDuration(duration)}'
        : 'Notifications muted';

    _showSnackBar(context, message, Colors.orange);
  }

  /// Check if notifications are currently muted
  static Future<bool> isMuted() async {
    return await _isCurrentlyMuted();
  }

  /// Get mute status with remaining time
  static Future<Map<String, dynamic>> getMuteStatus() async {
    final isMuted = await _isCurrentlyMuted();
    final remainingTime = await _getRemainingTime();

    return {
      'isMuted': isMuted,
      'remainingTime': remainingTime,
      'isTemporary': remainingTime != null,
    };
  }

  // Private implementation methods
  static Future<bool> _isCurrentlyMuted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMuted = prefs.getBool(_muteStateKey) ?? false;

      if (!isMuted) return false;

      // Check if temporary mute has expired
      final expiryTimestamp = prefs.getInt(_muteExpiryKey);
      if (expiryTimestamp != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiryTime)) {
          await _unmute(); // Auto-unmute if expired
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Duration?> _getRemainingTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTimestamp = prefs.getInt(_muteExpiryKey);

      if (expiryTimestamp == null) return null;

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      final now = DateTime.now();

      if (now.isAfter(expiryTime)) return Duration.zero;

      return expiryTime.difference(now);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _mute({Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Set mute state
      await prefs.setBool(_muteStateKey, true);

      // Set expiry if duration provided
      if (duration != null) {
        final expiryTime = DateTime.now().add(duration).millisecondsSinceEpoch;
        await prefs.setInt(_muteExpiryKey, expiryTime);
      } else {
        await prefs.remove(_muteExpiryKey);
      }

      // Platform-specific mute
      if (Platform.isAndroid) {
        await _muteAndroid();
      } else if (Platform.isIOS) {
        await _muteiOS();
      }

      // Mute push notifications
      await _mutePush();
    } catch (e) {
      print('Error muting notifications: $e');
    }
  }

  static Future<void> _unmute() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear mute state
      await prefs.setBool(_muteStateKey, false);
      await prefs.remove(_muteExpiryKey);

      // Platform-specific unmute
      if (Platform.isAndroid) {
        await _unmuteAndroid();
      } else if (Platform.isIOS) {
        await _unmuteiOS();
      }

      // Unmute push notifications
      await _unmutePush();
    } catch (e) {
      print('Error unmuting notifications: $e');
    }
  }

  // Android mute/unmute
  static Future<void> _muteAndroid() async {
    await _localNotifications.cancelAll();

    const AndroidNotificationChannel silentChannel = AndroidNotificationChannel(
      'silent_channel',
      'Silent Notifications',
      description: 'Muted notifications',
      importance: Importance.min,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(silentChannel);
  }

  static Future<void> _unmuteAndroid() async {
    const AndroidNotificationChannel normalChannel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'Normal notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(normalChannel);
  }

  // iOS mute/unmute
  static Future<void> _muteiOS() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: false,
          badge: false,
          sound: false,
        );
  }

  static Future<void> _unmuteiOS() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Push notification mute/unmute
  static Future<void> _mutePush() async {
    try {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic('all_notifications');
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      print('Error muting push: $e');
    }
  }

  static Future<void> _unmutePush() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('all_notifications');
      await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Error unmuting push: $e');
    }
  }

  // UI Helper methods
  static void _showMuteOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Mute Notifications'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMuteOption(context, '15 minutes', Duration(minutes: 15)),
            _buildMuteOption(context, '1 hour', Duration(hours: 1)),
            _buildMuteOption(context, '8 hours', Duration(hours: 8)),
            _buildMuteOption(context, '24 hours', Duration(hours: 24)),
            Divider(),
            _buildMuteOption(context, 'Until I turn back on', null),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static Widget _buildMuteOption(
      BuildContext context, String label, Duration? duration) {
    return ListTile(
      leading: Icon(
        duration == null ? Icons.notifications_off : Icons.timer,
        color: Colors.orange,
        size: 20,
      ),
      title: Text(label),
      onTap: () async {
        Navigator.pop(context);
        await _mute(duration: duration);

        final message = duration != null
            ? 'Muted for $label'
            : 'Notifications muted indefinitely';

        _showSnackBar(context, message, Colors.orange);
      },
    );
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

}
