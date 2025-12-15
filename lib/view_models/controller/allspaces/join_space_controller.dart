import 'dart:convert';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/AllSpaces/join_space_model.dart';
import '../../../res/api_urls/api_urls.dart';
import '../userPreferences/user_preferences_screen.dart';

class JoinSpaceController extends GetxController {
  final _prefs = UserPreferencesViewmodel();
  final rxRequestStatus = false.obs;
  final error = ''.obs;

  void setLoading(bool value) => rxRequestStatus.value = value;
  void setError(String value) => error.value = value;
  Future<String?> joinSpace(String spaceId) async {
    if (spaceId.isEmpty) {
      Utils.snackBar("Error", "Invalid space ID.");
      return null;
    }

    setLoading(true);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setLoading(false);
        Utils.snackBar("Error", "User not authenticated. Token not found.");
        return null;
      }

      final url = "${ApiUrls.joinSpaceApi}/$spaceId";
      // log("Join URL: $url");
      // log("Join Token: ${loginData.token}");

      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${loginData.token}',
        },
        body: jsonEncode({}),
      )
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception("Request to join space timed out.");
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        final joinSpaceModel = JoinSpaceModel.fromJson(responseBody);
        if (joinSpaceModel.success == true && joinSpaceModel.roomUrl != null) {
          // log("Room URL: ${joinSpaceModel.roomUrl}");
          setLoading(false);
          Get.snackbar("Success",
              joinSpaceModel.message ?? "Successfully joined the meeting!",
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green);
          return joinSpaceModel.roomUrl; // Return the roomUrl
        } else {
          setError(
              "Failed to join space: ${joinSpaceModel.message ?? 'Unknown error'}");
          setLoading(false);
          Utils.snackBar("Error",
              "Failed to join: ${joinSpaceModel.message ?? 'Unknown error'}");
          return null;
        }
      } else {
        // Parse the error response to check for "not enrolled" message
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message']?.toString() ?? 'Unknown error';
        setError(errorMessage);
        setLoading(false);

        if (errorMessage.toLowerCase().contains('not enrolled')) {
          Utils.snackBar("User is not enrolled for this space.", "Info");
        } else {
          Utils.snackBar("Failed to join space: $errorMessage", "Info");
        }
        return null;
      }
    } catch (error) {
      // log("Join API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setLoading(false);
      Utils.snackBar(
        "Failed to join: $error",
        "Info",
      );
      return null;
    }
  }
}
