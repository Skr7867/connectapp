import 'dart:convert';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../userPreferences/user_preferences_screen.dart';

class RepostClipController extends GetxController {
  final _prefs = UserPreferencesViewmodel();

  final isLoading = false.obs;
  final error = ''.obs;

  final repostedClips = <String>{}.obs;
  Future<void> toggleRepostClip(String clipId) async {
    final alreadyReposted = repostedClips.contains(clipId);
    if (alreadyReposted) {
      repostedClips.remove(clipId);
    } else {
      repostedClips.add(clipId);
    }

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        error.value = "User not authenticated. Token missing.";
        return;
      }

      final url =
          "${ApiUrls.baseUrl}/connect/v1/api/social/clip/toggle-repost/$clipId";

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${loginData.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (alreadyReposted) {
          Utils.toastMessageCenter('Remove Repost');
        } else {
          Utils.toastMessageCenter('Clip Repost');
        }
      } else {
        // Revert if failed
        if (alreadyReposted) {
          repostedClips.remove(clipId);
        } else {
          repostedClips.add(clipId);
        }
        final body = jsonDecode(response.body);
        error.value = body['message'] ?? "Failed to repost clip";
        Utils.snackBar(error.value, "Info");
      }
    } catch (e) {
      // log("RepostClip Error: $e", stackTrace: stackTrace);

      //  Revert if failed
      if (alreadyReposted) {
        repostedClips.remove(clipId);
      } else {
        repostedClips.add(clipId);
      }

      error.value = e.toString();
      Utils.snackBar("Something went wrong while reposting", "Error");
    }
  }
}
