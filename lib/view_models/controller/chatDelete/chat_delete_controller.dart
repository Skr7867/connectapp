import 'dart:developer';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import '../../../repository/ChatDelete/chat_delete_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class ChatController extends GetxController {
  final chatRepository = ChatDeleteRepository();
  final _userPref = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var apiResponse = {}.obs;

  Future<void> deleteChat(Map<String, dynamic> requestBody) async {
    try {
      isLoading.value = true;
      final token = await _userPref.getToken();
      if (token == null || token.isEmpty) {
        log('Token not found');
        isLoading.value = false;
        return;
      }
      final response = await chatRepository.chatDelete(requestBody, token);
      apiResponse.value = response;
      Utils.snackBar('Chat deleted successfully', 'Success');
    } catch (e) {
      Utils.snackBar(e.toString(), 'Network Error');
    } finally {
      isLoading.value = false;
    }
  }
}
