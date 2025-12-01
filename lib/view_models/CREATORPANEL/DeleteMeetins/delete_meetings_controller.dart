import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../controller/userPreferences/user_preferences_screen.dart';
import '../FetchCreatorSpace/fetch_creator_space_controller.dart';

class DeleteMeetingsController extends GetxController {
  final RxBool isDeleting = false.obs;
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
  }

  Future<bool> deleteSpace(String spaceId) async {
    try {
      isDeleting.value = true;

      final user = await _userPreferences.getUser();
      final String? token = user?.token;

      if (token == null || token.isEmpty) {
        Utils.snackBar(
            'Error', 'No authentication token found. Please log in.');
        Get.offAllNamed('/loginscreen');
        return false;
      }

      final url =
          Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/space/delete/$spaceId');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        jsonDecode(response.body);
        Utils.snackBar('Space deleted successfully', 'Success');

        // Refresh spaces list
        final fetchController = Get.find<FetchCreatorSpaceController>();
        await fetchController.fetchSpaces();

        return true;
      } else {
        Utils.snackBar(
            'Error', 'Failed to delete space: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
