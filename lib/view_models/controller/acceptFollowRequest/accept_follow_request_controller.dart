import 'dart:developer';

import 'package:connectapp/repository/AcceptFollowRequest/accept_follow_request_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/PendingFollowRequestModel/pending_follow_request_model.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class AcceptFollowRequestController extends GetxController {
  final _repository = AcceptFollowRequestRepository();
  final UserPreferencesViewmodel _userPrefs = UserPreferencesViewmodel();

  final rxStatus = Status.LOADING.obs;
  final pendingFollowRequest = PendingFollowRequestModel().obs;
  final errorMessage = ''.obs;

  // For button loading
  final RxSet<String> processingUserIds = <String>{}.obs;
  List<Requests> get requests => pendingFollowRequest.value.requests ?? [];

  // ACCEPT / REJECT FOLLOW REQUEST WITH AUTO-REFRESH
  Future<void> respondFollowRequest({
    required String action, // accept | reject
    required String fromUserId,
  }) async {
    final token = await _userPrefs.getToken();
    if (token == null) {
      Get.snackbar(
        'Info',
        'Authentication required',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Add user to processing list
    processingUserIds.add(fromUserId);

    try {
      // Make API call
      await _repository.respondFollowRequest(
        token: token,
        action: action,
        fromUserId: fromUserId,
      );

      // Optimistic UI update - Remove from local list
      pendingFollowRequest.update((model) {
        model?.requests?.removeWhere((r) => r.from?.sId == fromUserId);
      });

      // Show success message
      Get.snackbar(
        'Success',
        action == 'accept'
            ? 'Follow request accepted!'
            : 'Follow request rejected',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: action == 'accept'
            ? Color(0xFF10B981).withOpacity(0.9)
            : Color(0xFFEF4444).withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      log('Error in respondFollowRequest: ${e.toString()}');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to ${action} request. Please try again.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      // Remove user from processing list
      processingUserIds.remove(fromUserId);
    }
  }

  // Method to manually refresh if needed
  void removeRequestFromList(String userId) {
    pendingFollowRequest.update((model) {
      model?.requests?.removeWhere((r) => r.from?.sId == userId);
    });
  }
}
