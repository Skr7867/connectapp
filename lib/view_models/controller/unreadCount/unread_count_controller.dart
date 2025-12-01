import 'dart:developer';
import 'package:get/get.dart';
import '../../../models/UnreadCount/unread_count_model.dart';
import '../../../repository/UnreadCount/unread_count_repository.dart';
import '../service/socketservice.dart';
import '../userPreferences/user_preferences_screen.dart';

class UnreadCountController extends GetxController {
  final _repository = UnreadCountRepository();
  final _userPref = UserPreferencesViewmodel();
  final SocketService _socketService = SocketService();

  var unreadCountList = <UnreadCountModel>[].obs;
  String? currentOpenChatId;

  @override
  void onInit() {
    super.onInit();

    loadInitialUnreadCounts();

    // Listen to socket events
    _socketService.unreadCountStream.listen(updateUnreadFromSocket);
    _socketService.newMessageStream.listen(onNewMessageReceived);
    _socketService.messageStream.listen(onNewMessageReceived);
    _socketService.messagesReadStream.listen(onMessagesRead);

    log("📡 UnreadCountController initialized");
  }

  Future<void> loadInitialUnreadCounts() async {
    final token = await _userPref.getToken();
    if (token == null) return;

    unreadCountList.value = await _repository.fetchUnreadCount(token);
    log("📥 Loaded unread counts from API: ${unreadCountList.length}");
  }

  // ---- SOCKET UPDATE FROM SERVER ----
  void updateUnreadFromSocket(Map<String, dynamic> data) {
    final chatId = data["chatId"] ?? data["groupId"];
    if (chatId == null) return;

    final count = data["unreadCount"] ?? data["count"] ?? 0;
    _applyUnread(chatId, count);

    log("📩 Server updated unread → $chatId = $count");
  }

  // ---- NEW MESSAGE EVENT ----
  void onNewMessageReceived(Map<String, dynamic> data) async {
    final chatId = data["chat"] ?? data["group"] ?? data["chatId"];
    if (chatId == null) return;

    // If user is currently inside chat → no unread
    if (currentOpenChatId == chatId) {
      log("📥 Message received but chat open → ignore unread");
      return;
    }

    await _userPref.init();
    final user = await _userPref.getUser();
    final senderId = data["sender"]?["_id"] ?? data["senderId"];

    if (senderId == user?.user.id) {
      log("📤 Own message → ignore unread");
      return;
    }

    incrementUnread(chatId);
  }

  // ---- WHEN USER MARKS AS READ ----
  void onMessagesRead(Map<String, dynamic> data) {
    final chatId = data["chatId"];
    if (chatId == null) return;

    clearUnreadForChat(chatId);
    log("🧹 Socket cleared unread for $chatId (messages read)");
  }

  // ---- INTERNAL APPLY ----
  void _applyUnread(String chatId, int count) {
    final index = unreadCountList.indexWhere((item) => item.sId == chatId);

    if (index != -1) {
      unreadCountList[index] =
          unreadCountList[index].copyWith(unreadCount: count);
    } else {
      unreadCountList.add(UnreadCountModel(sId: chatId, unreadCount: count));
    }

    unreadCountList.refresh();
  }

  // ---- INCREMENT UNREAD COUNTER ----
  void incrementUnread(String chatId) {
    final index = unreadCountList.indexWhere((item) => item.sId == chatId);

    if (index != -1) {
      final currentCount = unreadCountList[index].unreadCount ?? 0;
      unreadCountList[index] =
          unreadCountList[index].copyWith(unreadCount: currentCount + 1);
    } else {
      unreadCountList.add(UnreadCountModel(sId: chatId, unreadCount: 1));
    }

    unreadCountList.refresh();

    final latestCount =
        unreadCountList.firstWhere((u) => u.sId == chatId).unreadCount;
    log("🔔 New message → $chatId unread = $latestCount");
  }

  // ---- CLEAR UNREAD WHEN USER OPENS CHAT ----
  void clearUnreadForChat(String chatId) {
    currentOpenChatId = chatId;

    final index = unreadCountList.indexWhere((item) => item.sId == chatId);
    if (index != -1) {
      unreadCountList[index] = unreadCountList[index].copyWith(unreadCount: 0);
      unreadCountList.refresh();
    }

    log("🧹 Cleared unread → $chatId");
  }
}
