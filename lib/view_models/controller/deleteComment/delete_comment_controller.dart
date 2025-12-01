import 'dart:developer';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../repository/DeleteComment/delete_comment_repository.dart';
import '../../../utils/utils.dart';
import '../userPreferences/user_preferences_screen.dart';

class DeleteCommentController extends GetxController {
  final DeleteCommentRepository _deleteRepo = DeleteCommentRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  /// Observables
  var isDeleting = false.obs;
  var deleteStatus = Status.COMPLETED.obs;
  var errorMessage = "".obs;

  /// Delete Comment Function
  Future<void> deleteComment(String commentId) async {
    try {
      isDeleting.value = true;
      deleteStatus.value = Status.LOADING;

      // Get token
      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        errorMessage.value = "User authentication failed. Token not found.";
        deleteStatus.value = Status.ERROR;
        isDeleting.value = false;
        return;
      }

      final token = user.token;

      log("Deleting Comment ID: $commentId");
      log("Token: $token");

      // API Call
      final response = await _deleteRepo.deleteComment(commentId, token);

      log("Delete Comment Response: $response");

      deleteStatus.value = Status.COMPLETED;
      isDeleting.value = false;

      Utils.toastMessageCenter('Comment Deleted');
    } catch (e, stack) {
      log("Delete Comment Error: $e", stackTrace: stack);
      deleteStatus.value = Status.ERROR;
      isDeleting.value = false;
      errorMessage.value = e.toString();

      Utils.toastMessageCenter('Failed to delete Comment');
    }
  }
}
