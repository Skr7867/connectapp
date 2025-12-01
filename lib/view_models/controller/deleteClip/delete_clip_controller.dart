import 'dart:convert';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../view_models/controller/userPreferences/user_preferences_screen.dart';

class DeleteClipsController extends GetxController {
  final _prefs = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var error = ''.obs;

  /// Delete a clip by ID
  Future<void> deleteClip(String clipId) async {
    isLoading.value = true;
    error.value = '';

    final url = Uri.parse(
      "${ApiUrls.baseUrl}/connect/v1/api/social/clip/delete/$clipId",
    );

    try {
      final token = await _prefs.getToken();
      if (token == null || token.isEmpty) {
        error.value = "Unauthorized: Token not found";
        Get.snackbar("Error", error.value);
        return;
      }

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        Utils.snackBar(data['message'], "Success");
      } else {
        final data = json.decode(response.body);
        error.value = data['message'] ?? "Failed to delete clip";
        Utils.snackBar(
          error.value,
          "Error",
        );
      }
    } catch (e) {
      error.value = e.toString();
      // log("DeleteClip Error: $e", stackTrace: stack);
      Utils.snackBar(
        error.value,
        "Error",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
