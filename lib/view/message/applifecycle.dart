import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../res/routes/routes_name.dart';
import 'notificationservice.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  static bool isDeepLinkActive = false;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    print('🔄 AppLifecycleService initialized');
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('🧹 AppLifecycleService disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _updateLastActiveTime(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        print('⏸️ App inactive');
        break;
      default:
        break;
    }
  }

  Future<void> _updateLastActiveTime(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'last_active_time', DateTime.now().millisecondsSinceEpoch);
      print('🕓 Updated last active time');
    }
  }

  void _onAppResumed() {
    print('📱 App resumed - clearing notifications');
    NotificationService().clearBadgeCount();

    final currentRoute = Get.currentRoute;
    print('📍 Current route: $currentRoute');

    // 🛑 Prevent overriding deep link navigation
    if (isDeepLinkActive) {
      print('🔗 Deep link active — skipping auto redirect');
      return;
    }

    if (currentRoute == RouteName.clipPlayScreen) {
      print('On ClipPlayScreen — skipping home redirect');
      return;
    }

    // Optional auto navigation
  }

  void _onAppPaused() {
    print('🌙 App paused');
  }

  void _onAppDetached() {
    print('🛑 App detached');
  }
}
