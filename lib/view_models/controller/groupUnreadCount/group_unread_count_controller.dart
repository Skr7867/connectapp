import 'dart:developer';

import 'package:get/get.dart';

import '../../../models/GroupUnreadCount/group_unread_count_model.dart';
import '../../../repository/GroupUnreadCount/group_unread_count_repository.dart';
import '../service/socketservice.dart';
import '../userPreferences/user_preferences_screen.dart';

class GroupUnreadCountController extends GetxController {
  final GroupUnreadCountRepository _repository = GroupUnreadCountRepository();
  final UserPreferencesViewmodel _userPref = UserPreferencesViewmodel();
  final SocketService _socketService = SocketService();

  var unreadGroupList = <GroupUnreadCountModel>[].obs;
  String? currentOpenGroupId;

  @override
  void onInit() {
    super.onInit();
    _loadInitialUnreadCounts();

    // Listen to socket unread count update
    _socketService.unreadCountStream.listen((data) {
      if (data["isGroup"] == true || data["groupId"] != null) {
        _updateGroupUnreadFromSocket(data);
      }
    });

    _socketService.newMessageStream.listen(_onNewGroupMessageReceived);
    _socketService.messagesReadStream.listen(_onGroupMessagesRead);
    log(" GroupUnreadCountController Initialized");
  }

  Future<void> _loadInitialUnreadCounts() async {
    final token = await _userPref.getToken();
    if (token == null) return;

    unreadGroupList.value = await _repository.fetchGroupUnreadCount(token);
    log("Fetched group unread counts: ${unreadGroupList.length}");

    // Sort groups by last message timestamp
    _sortGroupsByLastMessage();
  }

  void _updateGroupUnreadFromSocket(Map<String, dynamic> data) {
    final groupId = data["groupId"] ?? data["chatId"];
    final count = data["unreadCount"] ?? data["count"] ?? 0;
    final lastMessageData = data["lastMessage"];

    log("Socket unread update received: groupId=$groupId, count=$count, rawData=$data");

    if (groupId == null) {
      log(" No groupId in socket data");
      return;
    }

    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      // Update existing group
      unreadGroupList[index].unreadCount = count;

      // Update last message if provided
      if (lastMessageData != null) {
        unreadGroupList[index].lastMessage =
            LastMessage.fromJson(lastMessageData);
      }

      log("Updated existing group: ${unreadGroupList[index]}");
    } else {
      // Create new group entry
      final newGroup = GroupUnreadCountModel(
        id: groupId,
        unreadCount: count,
        lastMessage: lastMessageData != null
            ? LastMessage.fromJson(lastMessageData)
            : null,
      );
      unreadGroupList.add(newGroup);
    }

    // Sort groups after update
    _sortGroupsByLastMessage();
    unreadGroupList.refresh();
    log("Total groups tracked: ${unreadGroupList.length}");
  }

  void _onNewGroupMessageReceived(Map<String, dynamic> data) async {
    final groupId = data["group"] ?? data["groupId"];
    if (groupId == null) return;
    if (currentOpenGroupId == groupId) return;

    await _userPref.init();
    final user = await _userPref.getUser();
    final senderId = data["sender"]?["_id"] ?? data["senderId"];
    if (senderId == user?.user.id) return;

    // Create last message from socket data
    final lastMessage = LastMessage(
      text: data["text"] ?? data["content"],
      sentAt: data["sentAt"] ??
          data["createdAt"] ??
          DateTime.now().toIso8601String(),
    );

    _updateGroupLastMessage(groupId, lastMessage);
    incrementUnread(groupId);
  }

  void _updateGroupLastMessage(String groupId, LastMessage lastMessage) {
    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].lastMessage = lastMessage;
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
    } else {
      // If group not found in list, add it
      final newGroup = GroupUnreadCountModel(
        id: groupId,
        unreadCount: 1,
        lastMessage: lastMessage,
      );
      unreadGroupList.add(newGroup);
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
    }
  }

  void _onGroupMessagesRead(Map<String, dynamic> data) {
    final groupId = data["groupId"] ?? data["chatId"];
    if (groupId == null) return;

    clearUnread(groupId);
  }

  void incrementUnread(String groupId) {
    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].unreadCount++;
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
    } else {
      unreadGroupList.add(GroupUnreadCountModel(id: groupId, unreadCount: 1));
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
    }
  }

  void clearUnread(String groupId) {
    currentOpenGroupId = groupId;

    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].unreadCount = 0;
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
    }

    log("Cleared unread → Group $groupId");
  }

  // Add this method to sort groups by last message timestamp
  void _sortGroupsByLastMessage() {
    unreadGroupList.sort((a, b) {
      // Use the effective timestamp for sorting (last message time or creation time)
      return b.effectiveTimestamp.compareTo(a.effectiveTimestamp);
    });
  }
}
