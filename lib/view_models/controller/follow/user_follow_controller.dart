import 'dart:convert';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../userPreferences/user_preferences_screen.dart';

class FollowUnfollowController extends GetxController {
  var followedUserIds = <String>{}.obs;

  final _prefs = UserPreferencesViewmodel();

  // Per-user loading state
  final Map<String, bool> userLoading = <String, bool>{}.obs;

  bool isFollowing(String userId) {
    return followedUserIds.contains(userId);
  }

  bool isLoadingUser(String userId) {
    return userLoading[userId] ?? false;
  }

  // Follow User
  Future<bool> followUser(String userId) async {
    try {
      userLoading[userId] = true;
      final token = await _prefs.getToken();

      final url =
          "${ApiUrls.baseUrl}/connect/v1/api/social/follow-user/$userId";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.toastMessageCenter(res["message"]);
        followedUserIds.add(userId);
        return true;
      } else {
        Utils.toastMessageCenter(res["message"]);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      userLoading[userId] = false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      userLoading[userId] = true;
      final token = await _prefs.getToken();

      final url =
          "${ApiUrls.baseUrl}/connect/v1/api/social/unfollow-user/$userId";

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.toastMessageCenter(res["message"]);
        followedUserIds.remove(userId);
        return true;
      } else {
        Utils.toastMessageCenter(res["message"]);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      userLoading[userId] = false;
    }
  }
}
