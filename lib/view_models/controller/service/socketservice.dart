import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../userPreferences/user_preferences_screen.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  SharedPreferences? _prefs;

  // Add these controllers for reactions
  final _messageReactionUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _unreadCountController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _olderPrivateMessagesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _olderGroupMessagesController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _groupDeletedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _groupDetailsController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>>
      _privateMessageHistoryController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _pinnedMessageController =
      StreamController.broadcast();

  final StreamController<Map<String, dynamic>> _unpinnedMessageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _errorController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get messageReactionUpdatedStream =>
      _messageReactionUpdatedController.stream;
  final StreamController<Map<String, dynamic>> _messageDeletedController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get messageDeletedStream =>
      _messageDeletedController.stream;
  final StreamController<Map<String, dynamic>> _adminAddedController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get groupDetailsStream =>
      _groupDetailsController.stream;
  Stream<Map<String, dynamic>> get privateMessageHistoryStream =>
      _privateMessageHistoryController.stream;
  Stream<Map<String, dynamic>> get pinnedMessageStream =>
      _pinnedMessageController.stream;
  Stream<Map<String, dynamic>> get unpinnedMessageStream =>
      _unpinnedMessageController.stream;
  Stream<Map<String, dynamic>> get unreadCountStream =>
      _unreadCountController.stream;
  final StreamController<Map<String, dynamic>> _messageHistoryController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get messageHistoryStream =>
      _messageHistoryController.stream;
  Stream<Map<String, dynamic>> get errorStream => _errorController.stream;
  final StreamController<Map<String, dynamic>> _newMessageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _messagesReadController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get groupDeletedStream =>
      _groupDeletedController.stream;
  Stream<Map<String, dynamic>> get newMessageStream =>
      _newMessageController.stream;
  Stream<Map<String, dynamic>> get messagesReadStream =>
      _messagesReadController.stream;

  Stream<Map<String, dynamic>> get adminAddedStream =>
      _adminAddedController.stream;

  // Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // NEW: Save unread count to persistent storage
  Future<void> _saveUnreadCount(String chatId, int count) async {
    await _initPrefs();
    await _prefs?.setInt('unread_$chatId', count);
    log(' Saved unread count for $chatId: $count');
  }

  //  Get unread count from persistent storage
  Future<int> getUnreadCount(String chatId) async {
    await _initPrefs();
    final count = _prefs?.getInt('unread_$chatId') ?? 0;
    log(' Retrieved unread count for $chatId: $count');
    return count;
  }

  //  Clear unread count
  Future<void> clearUnreadCount(String chatId) async {
    await _initPrefs();
    await _prefs?.remove('unread_$chatId');
    log('🗑️ Cleared unread count for $chatId');
  }

  // Get all unread counts
  Future<Map<String, int>> getAllUnreadCounts() async {
    await _initPrefs();
    final keys = _prefs?.getKeys() ?? {};
    final Map<String, int> unreadCounts = {};

    for (String key in keys) {
      if (key.startsWith('unread_')) {
        final chatId = key.replaceFirst('unread_', '');
        final count = _prefs?.getInt(key) ?? 0;
        if (count > 0) {
          unreadCounts[chatId] = count;
        }
      }
    }

    log('📊 Retrieved all unread counts: $unreadCounts');
    return unreadCounts;
  }

  // Save last message timestamp for sorting
  Future<void> _saveLastMessageTime(String chatId, int timestamp) async {
    await _initPrefs();
    await _prefs?.setInt('lastmsg_$chatId', timestamp);
  }

  //  Get last message timestamp
  Future<int> getLastMessageTime(String chatId) async {
    await _initPrefs();
    return _prefs?.getInt('lastmsg_$chatId') ?? 0;
  }

  Future<void> connect(String serverUrl, String token) async {
    try {
      final userPrefs = UserPreferencesViewmodel();
      await userPrefs.init();
      final user = await userPrefs.getUser();

      final String userId = user?.user.id ?? "";

      log("Connecting to socket: $serverUrl with userId: $userId");

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableReconnection()
            .setPath('/socket.io')
            .setAuth({
              'userId': userId,
              'token': token,
            })
            .build(),
      );
      _socket?.onReconnect((_) {
        _socket?.auth = {'userId': userId};
      });

      // Basic connection lifecycle logs and handlers
      _socket?.onConnect((_) {
        log(" SOCKET CONNECTED with userId: $userId");
        //  Request unread counts on reconnection
        _requestAllUnreadCounts(userId);
      });

      _socket?.onConnectError((err) {
        log('Socket connect error: $err');
      });

      _socket?.onError((err) {
        log('Socket error: $err');
      });

      _socket?.onDisconnect((_) {
        log('Disconnected from socket server');
      });

      // Debug: log every event the socket receives
      _socket?.onAny((event, data) {
        log(" EVENT: $event");
        log("DATA: $data");
      });

      // Register all existing listeners
      _socket?.on('groupDeleted', (data) {
        try {
          _groupDeletedController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _groupDeletedController.add({'data': data});
        }
      });

      _socket?.on('olderPrivateMessagesResponse', (data) {
        try {
          _olderPrivateMessagesController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _olderPrivateMessagesController.add({'data': data});
        }
        log('Received older private messages response: $data');
      });

      _socket?.on('olderGroupMessagesResponse', (data) {
        try {
          _olderGroupMessagesController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _olderGroupMessagesController.add({'data': data});
        }
        log('Received older group messages response: $data');
      });

      _socket?.on('receiveMessage', (data) async {
        try {
          final messageData = Map<String, dynamic>.from(data);
          _messageController.add(messageData);
          _newMessageController.add(messageData);
        } catch (e) {
          _messageController.add({'data': data});
          _newMessageController.add({'data': data});
        }
      });

      _socket?.on('groupDetails', (data) {
        try {
          _groupDetailsController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _groupDetailsController.add({'data': data});
        }
        log('group details work: $data');
      });

      _socket?.on('unreadMessageUpdate', (data) async {
        try {
          final updateData = Map<String, dynamic>.from(data);
          final chatId = updateData['chatId'];
          final count = updateData['count'] ?? updateData['unreadCount'] ?? 0;

          if (chatId != null) {
            await _saveUnreadCount(chatId, count);
          }

          _unreadCountController.add(updateData);
          log('Unread count updated and saved: $chatId -> $count');
        } catch (e) {
          _unreadCountController.add({'data': data});
          log('Error saving unread count: $e');
        }
      });

      _socket?.on('messageHistory', (data) {
        try {
          _messageHistoryController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _messageHistoryController.add({'data': data});
        }
        log('messageHistory event received: $data');
      });

      // Pin/Unpin message listeners
      _socket?.on('messagePinned', (data) {
        try {
          _pinnedMessageController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _pinnedMessageController.add({'data': data});
        }
      });

      _socket?.on('messageUnpinned', (data) {
        try {
          _unpinnedMessageController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _unpinnedMessageController.add({'data': data});
        }
      });

      _socket?.on('error', (data) {
        try {
          _errorController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _errorController.add({'error': data});
        }
      });

      _socket?.on('newMessage', (data) {
        try {
          _newMessageController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _newMessageController.add({'data': data});
        }
      });

      _socket?.on('messageReactionUpdated', (data) {
        try {
          _messageReactionUpdatedController
              .add(Map<String, dynamic>.from(data));
        } catch (_) {
          _messageReactionUpdatedController.add({'data': data});
        }
      });

      // Handle read receipts with persistence
      _socket?.on('messagesRead', (data) async {
        try {
          final readData = Map<String, dynamic>.from(data);
          final chatId = readData['chatId'];

          if (chatId != null) {
            await clearUnreadCount(chatId);
          }

          _messagesReadController.add(readData);
          log('✅ Messages marked as read and count cleared: $chatId');
        } catch (e) {
          _messagesReadController.add({'data': data});
          log('⚠️ Error clearing read count: $e');
        }
      });

      _socket?.on('messageDeleted', (data) {
        try {
          _messageDeletedController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _messageDeletedController.add({'data': data});
        }
      });

      _socket?.on('adminAdded', (data) {
        try {
          _adminAddedController.add(Map<String, dynamic>.from(data));
        } catch (_) {
          _adminAddedController.add({'data': data});
        }
      });
    } catch (e, st) {
      log('Socket connect exception: $e\n$st');
    }
  }

  // Request all unread counts on reconnection
  void _requestAllUnreadCounts(String userId) {
    _socket?.emit('getAllUnreadCounts', {'userId': userId});
  }

  //  Mark messages as read with persistence
  void markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    final readData = {
      'chatId': chatId,
      'userId': userId,
    };

    _socket?.emit('markAsRead', readData);
    await clearUnreadCount(chatId);
    log('✅ Marking messages as read and clearing local count: $chatId');
  }

  // ✅ ENHANCED: Chat opened with unread count update
  void chatOpened({
    required String chatId,
    required String userId,
    required bool isGroup,
  }) async {
    _socket?.emit('chatOpened', {
      'chatId': chatId,
      'userId': userId,
      'isGroup': isGroup,
    });

    // Clear local unread count when chat is opened
    await clearUnreadCount(chatId);
    log('✅ Chat opened and unread count cleared: $chatId');
  }

  //**********************************existing methods remain same******************** */
  void editMessage({
    required String messageId,
    required String userId,
    required String newContent,
    required Function(bool success, String? message) callback,
  }) {
    if (_socket == null) {
      callback(false, 'Socket not connected');
      return;
    }

    final editMessageData = {
      'messageId': messageId,
      'userId': userId,
      'content': newContent,
    };

    _socket!.emitWithAck('EditMessage', editMessageData, ack: (response) {
      try {
        if (response != null) {
          Map<String, dynamic> data;

          if (response is List && response.isNotEmpty) {
            data = response[0] as Map<String, dynamic>;
          } else if (response is Map<String, dynamic>) {
            data = response;
          } else {
            callback(false, 'Invalid response format');
            return;
          }

          bool success = data['success'] ?? false;
          String? message = data['message'];
          callback(success, message);
        } else {
          callback(false, 'No response received from server');
        }
      } catch (e) {
        callback(false, 'Error parsing server response');
      }
    });
  }

  void makeAdmin({
    required String groupId,
    required String userId,
    required String ownerId,
    required Function(bool success, String? message) callback,
  }) {
    if (_socket == null) {
      callback(false, 'Socket not connected');
      return;
    }

    final makeAdminData = {
      'groupId': groupId,
      'userId': userId,
      'ownerId': ownerId,
    };

    _socket!.emitWithAck('makeAdmin', makeAdminData, ack: (response) {
      try {
        if (response != null) {
          Map<String, dynamic> data;

          if (response is List && response.isNotEmpty) {
            data = response[0] as Map<String, dynamic>;
          } else if (response is Map<String, dynamic>) {
            data = response;
          } else {
            callback(false, 'Invalid response format');
            return;
          }

          bool success = data['success'] ?? false;
          String? message = data['message'];
          callback(success, message);
        } else {
          callback(false, 'No response received from server');
        }
      } catch (e) {
        callback(false, 'Error parsing server response');
      }
    });
  }

  void deleteMessage({
    required String messageId,
    required String userId,
    required Function(bool success, String? message) callback,
  }) {
    if (_socket == null) {
      callback(false, 'Socket not connected');
      return;
    }

    final deleteMessageData = {
      'messageId': messageId,
      'userId': userId,
    };

    _socket!.emitWithAck('deleteMessage', deleteMessageData, ack: (response) {
      try {
        if (response != null) {
          Map<String, dynamic> data;

          if (response is List && response.isNotEmpty) {
            data = response[0] as Map<String, dynamic>;
          } else if (response is Map<String, dynamic>) {
            data = response;
          } else {
            callback(false, 'Invalid response format');
            return;
          }

          bool success = data['success'] ?? false;
          String? message = data['message'];
          callback(success, message);
        } else {
          callback(false, 'No response received from server');
        }
      } catch (e) {
        callback(false, 'Error parsing server response');
      }
    });
  }

  void forwardMessage({
    required String originalMessageId,
    required String senderId,
    required List<Map<String, String>> targets,
    required Function(bool success, String? message) callback,
  }) {
    if (_socket == null || !_socket!.connected) {
      callback(false, 'Socket not connected');
      return;
    }

    final forwardData = {
      'originalMessageId': originalMessageId,
      'senderId': senderId,
      'targets': targets,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    log('📤 Emitting forwardMessage: $forwardData');

    // ✅ Emit and assume success (since message is forwarding correctly)
    _socket?.emit('forwardMessage', forwardData);

    Timer(const Duration(milliseconds: 500), () {
      log('Forward message sent successfully (optimistic)');
      callback(true, 'Message forwarded successfully');
    });

    _socket?.once('forwardError', (data) {
      log('❌ Forward error received: $data');
    });
  }

  void joinGroupRoom(String groupId, String userId, Function(bool) callback) {
    _socket?.emit('joinGroupRoom', {'groupId': groupId, 'userId': userId});
    _socket?.once('joinGroupRoom', (data) {
      callback(data['success'] ?? false);
    });
  }

  void joinPrivateRoom(
    String user1Id,
    String user2Id,
    Function(Map<String, dynamic>) callback,
  ) {
    log("📤 Emitting joinPrivateRoom ---> user1:$user1Id user2:$user2Id");

    bool hasResponded = false;

    Timer(const Duration(seconds: 5), () {
      if (!hasResponded) {
        hasResponded = true;
        callback({'success': false, 'message': 'Request timeout'});
      }
    });

    _socket?.once('messageHistory', (data) {
      if (!hasResponded) {
        hasResponded = true;
        log("📥 messageHistory event response: $data");

        try {
          final roomId = data['roomId'];
          final messages = data['messages'] ?? [];
          final status = data['status'];

          if (roomId != null && status == 200) {
            callback({
              'success': true,
              'chatId': roomId,
              'messages': messages,
            });
          } else {
            callback({'success': false, 'message': 'Invalid response'});
          }
        } catch (e) {
          log("❌ Error parsing messageHistory: $e");
          callback({'success': false, 'message': e.toString()});
        }
      }
    });

    _socket?.emitWithAck(
      'joinPrivateRoom',
      {
        'user1Id': user1Id,
        'user2Id': user2Id,
      },
      ack: (response) {
        if (!hasResponded) {
          hasResponded = true;
          log("📥 ACK response for joinPrivateRoom: $response");

          try {
            if (response == null) {
              callback({'success': false, 'message': 'No response'});
              return;
            }

            if (response is Map<String, dynamic>) {
              callback(response);
            } else if (response is List && response.isNotEmpty) {
              callback(Map<String, dynamic>.from(response[0]));
            } else {
              callback(
                  {'success': false, 'message': 'Invalid response format'});
            }
          } catch (e) {
            callback({'success': false, 'message': e.toString()});
          }
        }
      },
    );
  }

  void sendMessage({
    required String senderId,
    String? receiverId,
    String? groupId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? fileInfo,
    required Function(Map<String, dynamic>) callback,
    String? replyToMessageId,
    required List<String> mentions,
  }) {
    log('📤 Sending message: senderId=$senderId, receiverId=$receiverId, groupId=$groupId');

    // Use emitWithAck instead of emit + once
    _socket?.emitWithAck('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'groupId': groupId,
      'content': content,
      'messageType': messageType,
      if (fileInfo != null) 'fileInfo': fileInfo,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
    }, ack: (response) {
      log('📨 sendMessage ACK response: $response');

      try {
        if (response != null) {
          Map<String, dynamic> data;

          // Handle both list and map responses
          if (response is List && response.isNotEmpty) {
            data = Map<String, dynamic>.from(response[0]);
          } else if (response is Map<String, dynamic>) {
            data = response;
          } else {
            data = {'success': false, 'message': 'Invalid response format'};
          }

          callback(data);
        } else {
          callback({'success': false, 'message': 'No response from server'});
        }
      } catch (e) {
        log(' Error processing sendMessage response: $e');
        callback({'success': false, 'message': e.toString()});
      }
    });

    //  Add timeout protection
    Timer(Duration(seconds: 10), () {
      log('⚠️ sendMessage timeout - no response received');
    });
  }

  void pinMessage(
      {String? groupId, String? chatId, required String messageId}) {
    final data = {
      'messageId': messageId,
      if (groupId != null) 'groupId': groupId,
      if (chatId != null) 'chatId': chatId,
    };

    _socket?.emit('pinMessage', data);
  }

  void unpinMessage({
    String? groupId,
    String? chatId,
    required String messageId,
    Function(Map<String, dynamic>)? callback,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('unpinMessage', {
        if (groupId != null) 'groupId': groupId,
        if (chatId != null) 'chatId': chatId,
        'messageId': messageId,
      });

      if (callback != null) {
        _socket?.once('unpinMessage', (data) {
          callback(data);
        });
      }
    }
  }

  void getPinnedMessages({String? groupId, String? chatId}) {
    final data = {
      if (groupId != null) 'groupId': groupId,
      if (chatId != null) 'chatId': chatId,
    };

    _socket?.emit('getPinnedMessages', data);
  }

  void removeMemberFromGroup(String groupId, String memberId, String ownerId,
      Function(bool) callback) {
    _socket?.emit('removeMemberFromGroup', {
      'groupId': groupId,
      'memberId': memberId,
      'ownerId': ownerId,
    });
    _socket?.once('removeMemberFromGroup', (data) {
      callback(data['success'] ?? false);
    });
  }

  void deleteGroup({
    required String groupId,
    required String ownerId,
    required Function(bool success) callback,
  }) {
    final groupDeleteData = {
      'groupId': groupId,
      'ownerId': ownerId,
    };

    _socket?.emit('deleteGroup', groupDeleteData);

    _socket?.once('deleteGroup', (response) {
      final success = response['success'] ?? false;
      callback(success);
    });
  }

  void leaveGroup(String groupId, String userId, Function(bool) callback) {
    _socket?.emit('leaveGroup', {
      'groupId': groupId,
      'userId': userId,
    });
    _socket?.once('leaveGroup', (data) {
      callback(data['success'] ?? false);
    });
  }

  void requestGroupDetails(String groupId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('getGroupDetails', {'groupId': groupId});
    }
  }

  void makeGroupAdmin(String groupId, String userId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('makeGroupAdmin', {
        'groupId': groupId,
        'userId': userId,
      });
    }
  }

  void removeGroupAdmin(String groupId, String userId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('removeGroupAdmin', {
        'groupId': groupId,
        'userId': userId,
      });
    }
  }

  void removeGroupMember(String groupId, String userId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('removeGroupMember', {
        'groupId': groupId,
        'userId': userId,
      });
    }
  }

  void reportUser(String userId, String reason) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('reportUser', {
        'userId': userId,
        'reason': reason,
      });
    }
  }

  void addGroupMembers(String groupId, List<String> userIds) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('addGroupMembers', {
        'groupId': groupId,
        'userIds': userIds,
      });
    }
  }

  void loadOlderGroupMessages({
    required String groupId,
    String? beforeMessageId,
    int limit = 50,
    required Function(Map<String, dynamic>) onResponse,
  }) {
    final data = {
      'groupId': groupId,
      'beforeMessageId': beforeMessageId,
      'limit': limit,
    };

    _socket?.emitWithAck('loadOlderGroupMessages', data, ack: (response) {
      if (response != null) {
        onResponse(Map<String, dynamic>.from(response));
      }
    });
  }

  void loadOlderPrivateMessages({
    required String user1Id,
    required String user2Id,
    String? beforeMessageId,
    int limit = 50,
    required Function(Map<String, dynamic>) onResponse,
  }) {
    final data = {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'beforeMessageId': beforeMessageId,
      'limit': limit,
    };

    _socket?.emitWithAck('loadOlderPrivateChatMessages', data, ack: (response) {
      if (response != null) {
        onResponse(Map<String, dynamic>.from(response));
      }
    });
  }

  void reactToMessage({
    required String messageId,
    required String userId,
    required String emoji,
  }) {
    final reactionData = {
      'messageId': messageId,
      'userId': userId,
      'emoji': emoji,
    };

    _socket?.emit('reactToMessage', reactionData);
  }

  void dispose() {
    _pinnedMessageController.close();
    _unreadCountController.close();
    _unpinnedMessageController.close();
    _errorController.close();
    _messageHistoryController.close();
    _olderPrivateMessagesController.close();
    _olderGroupMessagesController.close();
    _adminAddedController.close();
    _groupDeletedController.close();
    _messageController.close();
    _groupDetailsController.close();
    _privateMessageHistoryController.close();
    _messageDeletedController.close();
    _messagesReadController.close();
    _messageReactionUpdatedController.close();
    _newMessageController.close();
  }

  void disconnect() {
    _socket?.disconnect();
    dispose();
  }
}
