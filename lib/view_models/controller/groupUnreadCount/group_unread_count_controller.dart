// group_unread_count_controller.dart
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
      final isGroup = data["isGroup"] == true ||
          data["groupId"] != null ||
          data["group"] != null;
      if (isGroup) {
        _updateGroupUnreadFromSocket(data);
      }
    });

    _socketService.newMessageStream.listen(_onNewGroupMessageReceived);
    _socketService.messageStream.listen(_onNewGroupMessageReceived);
    _socketService.messagesReadStream.listen(_onGroupMessagesRead);
    log("📡 GroupUnreadCountController Initialized");
  }

  Future<void> _loadInitialUnreadCounts() async {
    final token = await _userPref.getToken();
    if (token == null) return;

    unreadGroupList.value = await _repository.fetchGroupUnreadCount(token);
    log("📊 Fetched group unread counts: ${unreadGroupList.length}");
    _sortGroupsByLastMessage();
  }

  void _updateGroupUnreadFromSocket(Map<String, dynamic> data) {
    final groupId = data["groupId"] ?? data["chatId"] ?? data["group"];
    final count = data["unreadCount"] ?? data["count"] ?? 0;
    final lastMessageData = data["lastMessage"];

    log("📦 Socket unread update received: groupId=$groupId, count=$count");

    if (groupId == null) {
      log("⚠️ No groupId in socket data");
      return;
    }

    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].unreadCount = count;
      if (lastMessageData != null) {
        unreadGroupList[index].lastMessage =
            LastMessage.fromJson(lastMessageData);
      }
      log("✅ Updated existing group: ${unreadGroupList[index].name} -> $count");
    } else {
      final newGroup = GroupUnreadCountModel(
        id: groupId,
        unreadCount: count,
        lastMessage: lastMessageData != null
            ? LastMessage.fromJson(lastMessageData)
            : null,
      );
      unreadGroupList.add(newGroup);
      log("➕ Added new group: $groupId -> $count");
    }

    _sortGroupsByLastMessage();
    unreadGroupList.refresh();
  }

  void _onNewGroupMessageReceived(Map<String, dynamic> data) async {
    final groupId = data["group"] ?? data["groupId"];
    if (groupId == null) return;

    // ✅ Only handle group messages
    final isGroup = data["group"] != null || data["groupId"] != null;
    if (!isGroup) {
      log("👤 Skipping private message in GroupUnreadCountController");
      return;
    }

    if (currentOpenGroupId == groupId) {
      log("📦 Group message received but group $groupId is open → ignore unread");
      return;
    }

    await _userPref.init();
    final user = await _userPref.getUser();
    final senderId = data["sender"]?["_id"] ?? data["senderId"];

    if (senderId == user?.user.id) {
      log("📤 Own group message → ignore unread");
      return;
    }

    final lastMessage = LastMessage(
      text: data["content"] ?? data["text"] ?? data["message"]?["content"],
      sentAt: data["sentAt"] ??
          data["createdAt"] ??
          data["timestamp"] ??
          DateTime.now().toIso8601String(),
    );

    log("🔔 New group message for $groupId - incrementing unread");
    _updateGroupLastMessage(groupId, lastMessage);
    incrementUnread(groupId);
  }

  void _updateGroupLastMessage(String groupId, LastMessage lastMessage) {
    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].lastMessage = lastMessage;
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
      log("💬 Updated last message for group $groupId");
    } else {
      final newGroup = GroupUnreadCountModel(
        id: groupId,
        unreadCount: 1,
        lastMessage: lastMessage,
      );
      unreadGroupList.add(newGroup);
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
      log("➕ Added new group $groupId with unread: 1");
    }
  }

  void _onGroupMessagesRead(Map<String, dynamic> data) {
    final groupId = data["groupId"] ?? data["chatId"];
    if (groupId == null) return;

    // ✅ Only handle group messages
    final isGroup = data["isGroup"] == true || data["groupId"] != null;
    if (!isGroup) return;

    clearUnread(groupId);
  }

  void incrementUnread(String groupId) {
    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      final currentCount = unreadGroupList[index].unreadCount ?? 0;
      final newCount = currentCount + 1;
      unreadGroupList[index].unreadCount = newCount;
      log(" GROUP: Incremented $groupId: $currentCount -> $newCount");
    } else {
      unreadGroupList.add(GroupUnreadCountModel(id: groupId, unreadCount: 1));
      log("GROUP: New group $groupId: 0 -> 1");
    }

    _sortGroupsByLastMessage();
    unreadGroupList.refresh();
  }

  void clearUnread(String groupId) {
    currentOpenGroupId = groupId;

    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].unreadCount = 0;
      _sortGroupsByLastMessage();
      unreadGroupList.refresh();
      log("✅ Cleared unread for group $groupId");
    }
  }

  void incrementGroupUnread(String groupId,
      {Map<String, dynamic>? lastMessageData}) {
    final index = unreadGroupList.indexWhere((g) => g.id == groupId);

    if (index != -1) {
      unreadGroupList[index].unreadCount =
          (unreadGroupList[index].unreadCount ?? 0) + 1;

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

  // ✅ Add method to close group
  void closedGroup() {
    currentOpenGroupId = null;
    log("👋 Closed current group");
  }
}
