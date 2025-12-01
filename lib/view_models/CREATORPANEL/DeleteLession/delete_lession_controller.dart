import 'dart:developer';
import 'package:connectapp/repository/CREATORPANEL/DeleteLession/delete_lession_repository.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class DeleteLessionController extends GetxController {
  final _api = DeleteLessionRepository();
  final _prefs = UserPreferencesViewmodel();

  final isDeleting = false.obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setIsDeleting(bool value) => isDeleting.value = value;
  final RxString deletingLessonId = ''.obs;

  void setDeletingLessonId(String id) => deletingLessonId.value = id;
  void clearDeletingLessonId() => deletingLessonId.value = '';

  Future<bool> deleteLession(
      String courseId, String sectionId, String lessionId) async {
    setIsDeleting(true);
    setDeletingLessonId(lessionId);
    setError('');

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        Get.snackbar('Error', 'User not authenticated. Please log in.');
        setIsDeleting(false);
        clearDeletingLessonId();
        return false;
      }

      await _api.deleteLession(loginData.token, courseId, sectionId, lessionId);

      setIsDeleting(false);
      clearDeletingLessonId();
      Utils.snackBar('Lession deleted successfully.', 'Success');
      return true;
    } catch (error, stackTrace) {
      log("Delete API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setIsDeleting(false);
      clearDeletingLessonId();
      return false;
    }
  }
}
