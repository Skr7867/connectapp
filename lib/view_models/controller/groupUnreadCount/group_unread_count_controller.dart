// group_unread_count_controller.dart
import 'dart:developer';
import 'package:get/get.dart';
import '../../../models/GroupUnreadCount/group_unread_count_model.dart';
import '../../../repository/GroupUnreadCount/group_unread_count_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class GroupUnreadCountController extends GetxController {
  final GroupUnreadCountRepository _repository = GroupUnreadCountRepository();
  final UserPreferencesViewmodel _userPref = UserPreferencesViewmodel();
  var unreadGroupList = <GroupUnreadCountModel>[].obs;
  String? currentOpenGroupId;
  final Map<String, String?> lastGroupMessageId = {};

  @override
  void onInit() {
    super.onInit();
    _loadInitialUnreadCounts();
  }

  Future<void> _loadInitialUnreadCounts() async {
    final token = await _userPref.getToken();
    if (token == null) return;

    unreadGroupList.value = await _repository.fetchGroupUnreadCount(token);
    log("Fetched group unread counts: ${unreadGroupList.length}");
    _sortGroupsByLastMessage();
  }

  void clearUnread(String groupId) {
    currentOpenGroupId = groupId;

    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].unreadCount = 0;
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
      log("Cleared unread for group $groupId");
    }
  }

  void incrementGroupUnread(String groupId,
      {Map<String, dynamic>? lastMessageData}) {
    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].unreadCount =
          (unreadGroupList[index].unreadCount) + 1;

      if (lastMessageData != null) {
        unreadGroupList[index].lastMessage =
            LastMessage.fromJson(lastMessageData);
      }
    } else {
      unreadGroupList.add(
        GroupUnreadCountModel(
          id: groupId,
          unreadCount: 1,
          lastMessage: lastMessageData != null
              ? LastMessage.fromJson(lastMessageData)
              : null,
        ),
      );
    }

    _sortGroupsByLastMessage();
    unreadGroupList.refresh();
  }

  void _sortGroupsByLastMessage() {
    unreadGroupList.sort((a, b) {
      return b.effectiveTimestamp.compareTo(a.effectiveTimestamp);
    });
  }

  void closedGroup() {
    currentOpenGroupId = null;
    log("Closed current group");
  }
}
