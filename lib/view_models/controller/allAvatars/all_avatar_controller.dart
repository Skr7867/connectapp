import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../models/AllAvatar/all_avatar_model.dart';
import '../../../repository/AllAvatars/all_avatar_repository.dart';

class AllAvatarController extends GetxController {
  var avatars = <Avatars>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;

  final AllAvatarRepository _avatarRepository = AllAvatarRepository();

  final Set<String> _uniqueIds = <String>{};

  Future<void> fetchAvatars(String token, {bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        _uniqueIds.clear();
        avatars.clear();
      }

      if (!hasMore.value) return;

      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('Fetching avatars page ${currentPage.value}...');

      AllAvatarModel response = await _avatarRepository.allAvatar(
        token,
      );
      debugPrint('Received ${response.avatars?.length ?? 0} avatars');

      if (response.avatars != null && response.avatars!.isNotEmpty) {
        final newAvatars = <Avatars>[];
        for (var avatar in response.avatars!) {
          if (avatar.sId != null && !_uniqueIds.contains(avatar.sId)) {
            _uniqueIds.add(avatar.sId!);
            newAvatars.add(avatar);
          }
        }

        if (isRefresh) {
          avatars.assignAll(newAvatars);
        } else {
          avatars.addAll(newAvatars);
        }

        if (newAvatars.length < 10 || response.avatars!.length < 10) {
          hasMore.value = false;
        } else {
          currentPage.value++;
        }
      } else {
        if (isRefresh) avatars.clear();
        if (currentPage.value == 1) {
          errorMessage.value = 'No avatars found';
        }
        hasMore.value = false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching avatars: $e');
      debugPrint(stackTrace.toString());
      errorMessage.value = 'Failed to fetch avatars: ${e.toString()}';
      if (isRefresh) avatars.clear();
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    avatars.clear();
    _uniqueIds.clear();
    super.onClose();
  }
}
