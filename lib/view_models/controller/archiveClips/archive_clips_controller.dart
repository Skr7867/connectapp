import 'dart:convert';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../res/api_urls/api_urls.dart';
import '../userPreferences/user_preferences_screen.dart';

class ArchiveClipsController extends GetxController {
  var isLoading = false.obs;
  var error = ''.obs;

  final _prefs = UserPreferencesViewmodel();

  /// Toggle archive status of a clip
  Future<void> toggleArchiveClip(String clipId) async {
    isLoading.value = true;
    error.value = '';

    final url = Uri.parse(
      "${ApiUrls.baseUrl}/connect/v1/api/social/clip/toggle-archive/$clipId",
    );

    try {
      final token = await _prefs.getToken();
      if (token == null || token.isEmpty) {
        error.value = "Unauthorized: Token not found";
        Get.snackbar("Error", error.value);
        return;
      }

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      // log("ArchiveClip Response: ${response.statusCode} => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        Utils.snackBar(
          data['message'],
          "Success",
        );
      } else {
        final data = json.decode(response.body);
        error.value = data['message'] ?? "Failed to archive clip";
        Utils.snackBar(
          error.value,
          "Error",
        );
      }
    } catch (e) {
      error.value = e.toString();
      // log("ArchiveClip Error: $e", stackTrace: stack);
      Utils.snackBar(
        error.value,
        "Error",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
