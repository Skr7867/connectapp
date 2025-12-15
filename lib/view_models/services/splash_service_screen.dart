import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../res/api_urls/api_urls.dart';
import '../../res/routes/routes_name.dart';
import '../controller/userPreferences/user_preferences_screen.dart';
import '../../../main.dart';

class SplashServices {
  final UserPreferencesViewmodel userPreferencesViewmodel =
      UserPreferencesViewmodel();

  late AppLinks _appLinks;

  // Initialize and check everything
  void initSplash() async {
    await _handleDeepLinks();
    await isLogin();
  }

  // Handle deep links (moved from main.dart)
  Future<void> _handleDeepLinks() async {
    try {
      _appLinks = AppLinks();

      // Terminated app deep link
      final initialUri = await _appLinks.getLatestAppLink();
      if (initialUri != null) {
        log('Initial deep link: $initialUri');
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateFromUri(initialUri);
        });
      }

      // Foreground deep link
      _appLinks.uriLinkStream.listen((uri) {
        log('Deep link received: $uri');
        _navigateFromUri(uri);
      }, onError: (err) {
        log('Deep link stream error: $err');
      });
    } catch (e) {
      log(' Deep link init error: $e');
    }
  }

  // Navigate based on URI
  void _navigateFromUri(Uri uri) {
    if (isDeepLinkHandled) return;
    try {
      if (uri.scheme == 'https' || uri.scheme == 'http') {
        if (uri.pathSegments.isNotEmpty) {
          final first = uri.pathSegments[0];
          if (first == 'course' && uri.pathSegments.length > 1) {
            final courseId = uri.pathSegments[1];
            log('Navigating to course details: $courseId');
            isDeepLinkHandled = true;
            Get.offAllNamed(RouteName.viewDetailsOfCourses,
                arguments: courseId);
            return;
          } else if (first == 'clip' && uri.pathSegments.length > 1) {
            final clipId = uri.pathSegments[1];
            log(' Navigating to clip: $clipId');
            isDeepLinkHandled = true;
            Get.offAllNamed(RouteName.clipPlayScreen, arguments: clipId);
            return;
          } else if (first == 'space' && uri.pathSegments.length > 1) {
            final spaceId = uri.pathSegments[1];
            log('Navigating to space: $spaceId');
            isDeepLinkHandled = true;
            Get.offAllNamed(
              RouteName.newMeetingScreen,
            );
            return;
          }
        }
      }

      if (uri.scheme == 'connectapp') {
        final host = uri.host;
        final id = uri.queryParameters['id'];
        if (host == 'course' && id != null) {
          log(' Navigating (custom scheme) course: $id');
          isDeepLinkHandled = true;
          Get.offAllNamed(RouteName.viewDetailsOfCourses, arguments: id);
          return;
        } else if (host == 'clip' && id != null) {
          log(' Navigating (custom scheme) clip: $id');
          isDeepLinkHandled = true;
          Get.offAllNamed(RouteName.clipPlayScreen, arguments: id);
          return;
        } else if (host == 'space' && id != null) {
          isDeepLinkHandled = true;
          Get.toNamed(RouteName.joinMeeting, arguments: id);
          return;
        }
      }
    } catch (e) {
      log('Deep link navigation error:$e');
    }
  }

  // Login + role check
  Future<void> isLogin() async {
    try {
      final user = await userPreferencesViewmodel.getUser();

      if (user == null || user.token.isEmpty) {
        Timer(const Duration(seconds: 1),
            () => Get.offAllNamed(RouteName.loginScreen));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken') ?? user.token;

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && !isDeepLinkHandled) {
        final jsonResponse = jsonDecode(response.body);
        final role = jsonResponse['role'];

        Timer(const Duration(microseconds: 2), () {
          if (role == 'Creator') {
            Get.offAllNamed(RouteName.creatorBottomBar);
          } else {
            Get.offAllNamed(RouteName.bottomNavbar);
          }
        });
      } else if (!isDeepLinkHandled) {
        log("Profile fetch failed: ${response.statusCode}");
        Timer(const Duration(microseconds: 2),
            () => Get.offAllNamed(RouteName.loginScreen));
      }
    } catch (e) {
      log("Splash error: $e");
      if (!isDeepLinkHandled) {
        Timer(const Duration(microseconds: 2),
            () => Get.offAllNamed(RouteName.loginScreen));
      }
    }
  }
}
