import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../res/api_urls/api_urls.dart';
import '../../../view_models/controller/userPreferences/user_preferences_screen.dart';
import '../../../models/UserLogin/user_login_model.dart';

class CommentsController extends GetxController {
  var comments = <dynamic>[].obs;
  var isLoading = true.obs;
  var isSendingComment = false.obs;
  var replyingToCommentId = Rxn<String>();
  var replyingToUsername = Rxn<String>();
  var commentText = ''.obs;
  var commentTranslated = <String, bool>{}.obs;
  var commentTranslatedTexts = <String, String>{}.obs;
  var commentTranslating = <String, bool>{}.obs;

  bool isCommentTranslated(String commentId) =>
      commentTranslated[commentId] ?? false;
  bool isCommentTranslating(String commentId) =>
      commentTranslating[commentId] ?? false;
  String getTranslatedCommentText(String commentId) =>
      commentTranslatedTexts[commentId] ?? '';

  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  Future<void> fetchComments(String clipId) async {
    isLoading.value = true;
    final UserPreferencesViewmodel _userPreferences =
        UserPreferencesViewmodel();
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData!.token;

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/clip/get-comment-by-clipId/$clipId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        comments.value = data['comments'] ?? [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendComment(String clipId, String content) async {
    if (content.trim().isEmpty || isSendingComment.value) return;

    isSendingComment.value = true;
    final UserPreferencesViewmodel _userPreferences =
        UserPreferencesViewmodel();
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData!.token;

    try {
      Map<String, dynamic> body = {
        'content': content.trim(),
        'parentCommentId': replyingToCommentId.value,
      };

      if (replyingToCommentId.value != null) {
        body['replyToCommentId'] = null;
      }

      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/clip/comment/add/$clipId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (replyingToCommentId.value == null) {
          comments.insert(0, data['comment']);
        } else {
          _addReplyToComment(data['comment']);
        }
        commentText.value = '';
        replyingToCommentId.value = null;
        replyingToUsername.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send comment',
          backgroundColor: Colors.red);
    } finally {
      isSendingComment.value = false;
    }
  }

  Future<String?> translateText(String message) async {
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData?.token;
    if (token == null) throw Exception('No authentication token');

    // Create the request body
    final Map<String, dynamic> requestBody = {
      "text": message,
    };

    final response = await http.post(
      Uri.parse(ApiUrls.translateTextApi),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody), // Explicit JSON encoding
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      ;
      return data["translatedText"];
    } else {
      debugPrint("${response.statusCode} - ${response.body}");
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData["error"] ?? 'Translation requires Premium+ subscription';
      throw errorMessage;
    }
  }

  void handleCommentTranslation(String commentId, String content) async {
    final isCurrentlyTranslated = commentTranslated[commentId] ?? false;

    // If already translated, revert to original
    if (isCurrentlyTranslated) {
      commentTranslated[commentId] = false;
      return;
    }

    // Start translation process
    commentTranslating[commentId] = true;
    try {
      final translatedText = await translateText(content);

      if (translatedText != null) {
        commentTranslated[commentId] = true;
        commentTranslatedTexts[commentId] = translatedText;
      }
    } catch (e) {
      // Show error message
      commentTranslated[commentId] = false;
      Get.snackbar(
        'Translation Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      commentTranslating[commentId] = false;
    }
  }

  void _addReplyToComment(dynamic reply) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i]['_id'] == replyingToCommentId.value) {
        if (comments[i]['replies'] == null) {
          comments[i]['replies'] = [];
        }
        comments[i]['replies'].add(reply);
        comments.refresh();
        break;
      }
    }
  }

  void startReply(String commentId, String username) {
    replyingToCommentId.value = commentId;
    replyingToUsername.value = username;
    commentText.value = '@$username ';
  }

  void cancelReply() {
    replyingToCommentId.value = null;
    replyingToUsername.value = null;
    commentText.value = '';
  }

  String getTimeAgo(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 0) return '${difference.inDays}d ago';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      if (difference.inSeconds > 0) return '${difference.inSeconds} sec ago';
      return 'Just now';
    } catch (e) {
      return '';
    }
  }
}
