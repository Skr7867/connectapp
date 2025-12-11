import 'dart:developer';

import 'package:connectapp/models/UserLogin/user_login_model.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../res/api_urls/api_urls.dart';
import 'service.dart';

class ChatService {
  static String baseUrl = ApiUrls.baseUrl;
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  Future<List<GroupData>> getMyGroups() async {
    LoginResponseModel? userData = await _userPreferences.getUser();

    try {
      final token = userData?.token;
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/connect/v1/api/creator/course/get-my-chat-groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((group) => GroupData.fromJson(group)).toList();
      } else {
        throw Exception('HTTP error! status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch groups: $error');
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
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      log("Translated Text ==========> ${data["translatedText"]}");
      return data["translatedText"];
    } else {
      log("${response.statusCode} - ${response.body}");
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData["error"] ?? 'Translation requires Premium+ subscription';
      throw errorMessage;
    }
  }

  Future<List<Chat>> getPrivateChats(String currentUserId) async {
    final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
    try {
      LoginResponseModel? userData = await userPreferences.getUser();
      final token = userData?.token;
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/connect/v1/api/chat/get-all-private-chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((chat) {
          final otherParticipant = (chat['participants'] as List)
              .firstWhere((p) => p['_id'] != currentUserId);

          // Extract lastMessage as a Map or keep it as is
          dynamic lastMessageData = chat['lastMessage'];
          String lastMessageText = '';

          // Handle different lastMessage formats
          if (lastMessageData != null) {
            if (lastMessageData is Map<String, dynamic>) {
              // If it's a full message object, keep it as is
              lastMessageText = lastMessageData['content'] ?? '';
            } else if (lastMessageData is String) {
              // If it's just a string
              lastMessageText = lastMessageData;
            }
          }

          return Chat(
            id: chat['_id'],
            name: otherParticipant['fullName'],
            avatar: otherParticipant['avatar']?['imageUrl'],
            // Pass the full lastMessage object, not just the content
            lastMessage: lastMessageData ?? '',
            timestamp: DateTime.parse(chat['updatedAt']),
            // unread: 0,
            isGroup: false,
            participants: (chat['participants'] as List)
                .map((p) => Participant.fromJson(p))
                .toList(),
            pinnedMessages: chat['pinnedMessages'],
          );
        }).toList();
      } else {
        throw Exception('HTTP error! status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch private chats: $error');
    }
  }
}
