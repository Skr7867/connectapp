import 'dart:developer';

class Chat {
  final String id;
  final String name;
  final String? avatar;
  late final dynamic lastMessage;
  late final DateTime timestamp;
  final int unread;
  final bool isGroup;
  final bool? isOnline;
  final String? senderName;
  final List<Participant>? participants;
  final List<dynamic>? pinnedMessages;
  Chat(
      {required this.id,
      required this.name,
      this.avatar,
      required this.lastMessage,
      required this.timestamp,
      required this.unread,
      required this.isGroup,
      this.isOnline,
      this.senderName,
      this.participants,
      this.pinnedMessages});
  factory Chat.fromJson(Map<String, dynamic> json) {
    String? lastMsgText;
    DateTime lastMsgTime =
        DateTime.tryParse(json['lastMessageAt']?.toString() ?? '') ??
            DateTime.tryParse(json['chatCreatedAt']?.toString() ?? '') ??
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);

    // Parse lastMessage safely
    if (json['lastMessage'] != null) {
      if (json['lastMessage'] is Map<String, dynamic>) {
        final lm = json['lastMessage'];

        if (lm['messageType'] == 'sticker') {
          lastMsgText = '📷 Photo';
        } else if (lm['messageType'] == 'video') {
          lastMsgText = '🎥 Video';
        } else if (lm['messageType'] == 'audio') {
          lastMsgText = '🎤 Audio';
        } else if (lm['messageType'] == 'file') {
          lastMsgText = '📎 File';
        } else {
          lastMsgText = lm['content']?.toString().trim();
        }

        if (lm['createdAt'] != null) {
          lastMsgTime = DateTime.tryParse(lm['createdAt']) ?? lastMsgTime;
        }
      } else if (json['lastMessage'] is String) {
        lastMsgText = json['lastMessage'].toString().trim();
      }
    }

    //Only fall back to “No messages yet” if no message found
    final safeLastMsgText =
        (lastMsgText == null || lastMsgText.isEmpty) ? '' : lastMsgText;

    return Chat(
      id: json['_id'],
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? json['groupAvatar'],
      lastMessage: safeLastMsgText,
      timestamp: lastMsgTime,
      unread: json['unread'] ?? 0,
      isGroup: json['isGroup'] ?? false,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => Participant.fromJson(p))
              .toList()
          : null,
      pinnedMessages: json['pinnedMessages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'avatar': avatar,
      'lastMessage': lastMessage,
      'updatedAt': timestamp.toIso8601String(),
      'unread': unread,
      'isGroup': isGroup,
      'participants': participants?.map((p) => p.toJson()).toList(),
      'pinnedMessages': 'pinnedMessages'
    };
  }
}

// Fixed Reaction class
// Fixed Reaction class with debugging and robust user handling
class Reaction {
  final Sender user;
  final String emoji;

  Reaction({
    required this.user,
    required this.emoji,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    // Handle case where user might be a string ID instead of an object
    Sender user;
    if (json['user'] is String) {
      // If user is just an ID string, create a minimal Sender object
      user = Sender(
        id: json['user'],
        name: 'Unknown User', // Default name
        avatar: null,
      );
    } else if (json['user'] is Map<String, dynamic>) {
      // If user is a full object, parse it normally
      user = Sender.fromJson(json['user']);
    } else {
      throw Exception('Invalid user data type: ${json['user'].runtimeType}');
    }

    return Reaction(
      user: user,
      emoji: json['emoji'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'emoji': emoji,
    };
  }
}

// New ReplyTo model
class ReplyTo {
  final String? id;
  final String? content;
  final Sender? sender;

  ReplyTo({
    this.id,
    this.content,
    this.sender,
  });
  factory ReplyTo.fromJson(Map<String, dynamic> json) {
    try {
      return ReplyTo(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        content: json['content']?.toString(),
        sender: json['sender'] != null ? Sender.fromJson(json['sender']) : null,
      );
    } catch (e) {
      print('⚠️ Error parsing ReplyTo: $e');
      return ReplyTo(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        content: json['content']?.toString() ?? 'Reply content unavailable',
        sender: null,
      );
    }
  }
}

class FileInfo {
  final String name;
  final String type;
  final int size;
  final String url;

  FileInfo({
    required this.name,
    required this.type,
    required this.size,
    required this.url,
  });
}

class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final Sender sender;
  final bool isRead;
  String status;
  final bool isEdited;
  final DateTime? editedAt;
  final ReplyTo? replyTo;
  List<Reaction>? reactions;
  final String? messageType;
  final FileInfo? fileInfo;
  final bool isForwarded;

  final String? originalSenderId; // Added for forward support
  final OriginalSender? originalSender; // Added for forward support

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    this.isEdited = false,
    this.editedAt,
    required this.sender,
    required this.isRead,
    this.status = 'sent',
    this.replyTo,
    this.reactions,
    this.messageType,
    this.fileInfo,
    this.isForwarded = false,
    this.originalSender,
    this.originalSenderId, //
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    print('Parsing message JSON: $json');

    try {
      // Safe timestamp parsing
      DateTime messageTimestamp;
      try {
        messageTimestamp = DateTime.parse(json['createdAt']?.toString() ??
            json['timestamp']?.toString() ??
            DateTime.now().toIso8601String());
      } catch (e) {
        print('⚠️ Error parsing timestamp: $e');
        messageTimestamp = DateTime.now();
      }

      // Safe sender parsing
      Sender messageSender;
      try {
        if (json['sender'] == null) {
          messageSender = Sender(
            id: '',
            name: 'Unknown',
            avatar: null,
          );
        } else {
          messageSender = Sender.fromJson(json['sender']);
        }
      } catch (e) {
        print('⚠️ Error parsing sender: $e');
        messageSender = Sender(
          id: json['sender']?['_id'] ?? json['sender']?['id'] ?? '',
          name: 'Unknown',
          avatar: null,
        );
      }

      return Message(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        timestamp: messageTimestamp,
        sender: messageSender,
        isRead: json['status'] == 'read' ||
            json['isRead'] == true ||
            (json['seenBy'] as List?)?.isNotEmpty == true,
        status: json['status']?.toString() ?? 'sent',
        isEdited: json['isEdited'] as bool? ?? false,
        editedAt: json['editedAt'] != null
            ? DateTime.tryParse(json['editedAt'].toString())
            : null,
        replyTo:
            json['replyTo'] != null && json['replyTo'] is Map<String, dynamic>
                ? ReplyTo.fromJson(json['replyTo'] as Map<String, dynamic>)
                : null,
        reactions: _parseReactions(json['reactions']),
        messageType: json['messageType']?.toString() ?? 'text',
        isForwarded: json['isForwarded'] as bool? ?? false,
        originalSender: _parseOriginalSender(json),
        originalSenderId: _parseOriginalSenderId(json),
      );
    } catch (e, stackTrace) {
      print('❌ Critical error parsing message: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');

      // Return fallback message to prevent app crash
      return Message(
        id: json['_id']?.toString() ??
            'error-${DateTime.now().millisecondsSinceEpoch}',
        content: 'Error loading message',
        timestamp: DateTime.now(),
        sender: Sender(id: '', name: 'Unknown', avatar: null),
        isRead: false,
        status: 'error',
      );
    }
  }

// Helper method to get original sender ID
  static String? _parseOriginalSenderId(Map<String, dynamic> json) {
    try {
      if (json['originalMessage'] == null) return null;

      final originalMessage = json['originalMessage'];
      if (originalMessage is! Map<String, dynamic>) return null;

      final senderData = originalMessage['sender'];

      if (senderData is String) {
        return senderData; // Return the ID directly
      } else if (senderData is Map<String, dynamic>) {
        return senderData['_id'] ?? senderData['id'];
      }

      return null;
    } catch (e) {
      print('Error parsing original sender ID: $e');
      return null;
    }
  }

  static List<Reaction>? _parseReactions(dynamic reactionsJson) {
    if (reactionsJson == null) return null;

    if (reactionsJson is! List) {
      print('Reactions is not a list: ${reactionsJson.runtimeType}');
      return [];
    }

    List<Reaction> reactions = [];
    for (var i = 0; i < reactionsJson.length; i++) {
      try {
        var reactionData = reactionsJson[i];
        print('Processing reaction $i: $reactionData');

        if (reactionData is Map<String, dynamic>) {
          reactions.add(Reaction.fromJson(reactionData));
        } else {
          print(
              'Skipping invalid reaction at index $i: ${reactionData.runtimeType}');
        }
      } catch (e) {
        print('Error parsing reaction at index $i: $e');
        // Continue processing other reactions instead of failing completely
      }
    }

    return reactions.isEmpty ? [] : reactions;
  }

// Simplified _parseOriginalSender that only works with full objects
  static OriginalSender? _parseOriginalSender(Map<String, dynamic> json) {
    try {
      if (json['originalMessage'] == null) return null;

      final originalMessage = json['originalMessage'];
      if (originalMessage is! Map<String, dynamic>) return null;

      final senderData = originalMessage['sender'];

      // Only parse if it's a full object
      if (senderData is Map<String, dynamic>) {
        return OriginalSender.fromJson(senderData);
      }

      return null;
    } catch (e) {
      print('Error parsing original sender: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'createdAt': timestamp.toIso8601String(),
      'sender': sender.toJson(),
      'status': status,
      // 'replyTo': replyTo?.toJson(),
      'reactions': reactions?.map((reaction) => reaction.toJson()).toList(),
      'messageType': messageType,
      // 'fileInfo': fileInfo?.toJson(),
      'isForwarded': isForwarded,
      'originalSender': originalSender?.toJson(),
    };
  }

  Message copyWith({
    String? content,
    bool? isEdited,
    DateTime? editedAt,
    // ... other fields
  }) {
    return Message(
      isRead: isRead,
      id: id,
      content: content ?? this.content,
      sender: sender,
      timestamp: timestamp,
      status: status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      // ... copy other fields
    );
  }
}

// Original sender class for forwarded messages
class OriginalSender {
  final String id;
  final String name;
  final String? avatar;

  OriginalSender({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory OriginalSender.fromJson(dynamic json) {
    // Handle case where json is just a string ID
    if (json is String) {
      return OriginalSender(
        id: json,
        name: 'Unknown User',
        avatar: null,
      );
    }

    // Handle case where json is a Map (normal case)
    if (json is Map<String, dynamic>) {
      return OriginalSender(
        id: json['_id'] ?? json['id'],
        name: json['fullName'] ?? json['name'] ?? 'Unknown User',
        avatar: json['avatar'],
      );
    }

    // Fallback
    throw ArgumentError(
        'Invalid json type for OriginalSender: ${json.runtimeType}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

// Chat/Group model for forward target selection
class ForwardTarget {
  final String id;
  final String name;
  final String? avatar;
  final bool isGroup;
  final List<Participant>? participants;

  ForwardTarget({
    required this.id,
    required this.name,
    this.avatar,
    required this.isGroup,
    this.participants,
  });

  factory ForwardTarget.fromJson(Map<String, dynamic> json) {
    return ForwardTarget(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? json['groupName'] ?? json['fullName'],
      avatar: json['avatar'] ?? json['groupAvatar'],
      isGroup: json['isGroup'] ?? json['type'] == 'group',
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => Participant.fromJson(p))
              .toList()
          : null,
    );
  }
}

// Updated Sender model with toJson method
class Sender {
  final String id;
  final String name;
  final String? avatar;

  Sender({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory Sender.fromJson(Map json) {
    try {
      // Handle avatar field - it can be either a string or a map
      String? avatarUrl;

      if (json['avatar'] != null) {
        if (json['avatar'] is String) {
          avatarUrl = json['avatar'];
        } else if (json['avatar'] is Map) {
          avatarUrl = json['avatar']['imageUrl'];
        }
      }

      return Sender(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['fullName']?.toString() ??
            json['name']?.toString() ??
            'Unknown',
        avatar: avatarUrl,
      );
    } catch (e) {
      print('⚠️ Error parsing Sender: $e');
      return Sender(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: 'Unknown',
        avatar: null,
      );
    }
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': name,
      'avatar': avatar,
    };
  }
}

// Updated Participant model with toJson method
class Participant {
  final String id;
  final String name;
  final String? avatar;

  Participant({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? json['id'],
      name: json['fullName'] ?? json['name'],
      avatar: json['avatar']?['imageUrl'] ?? json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': name,
      'avatar': avatar,
    };
  }
}

class GroupMember {
  final dynamic userId;
  final String joinedAt;
  final String id;

  GroupMember({
    required this.userId,
    required this.joinedAt,
    required this.id,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    try {
      dynamic userIdData = json['userId'];

      // Handle both string ID and full object
      dynamic parsedUserId;
      if (userIdData is String) {
        // Create minimal UserInfo from string ID
        parsedUserId = UserInfo(
          id: userIdData,
          fullName: 'Loading...', // Placeholder
          email: '',
          avatar: null,
        );
      } else if (userIdData is Map<String, dynamic>) {
        // Parse full UserInfo object
        parsedUserId = UserInfo.fromJson(userIdData);
      } else {
        // Fallback
        parsedUserId = UserInfo(
          id: '',
          fullName: 'Unknown User',
          email: '',
          avatar: null,
        );
      }

      return GroupMember(
        userId: parsedUserId,
        joinedAt:
            json['joinedAt']?.toString() ?? DateTime.now().toIso8601String(),
        id: json['_id']?.toString() ?? '',
      );
    } catch (e) {
      log('⚠️ Error parsing GroupMember: $e');
      // Return fallback member instead of throwing
      return GroupMember(
        userId: UserInfo(
          id: json['userId']?.toString() ?? '',
          fullName: 'Unknown User',
          email: '',
          avatar: null,
        ),
        joinedAt:
            json['joinedAt']?.toString() ?? DateTime.now().toIso8601String(),
        id: json['_id']?.toString() ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId is UserInfo ? (userId as UserInfo).toJson() : userId,
      'joinedAt': joinedAt,
      '_id': id,
    };
  }

  UserInfo get userInfo {
    if (userId is UserInfo) {
      return userId as UserInfo;
    }
    return UserInfo(
      id: userId?.toString() ?? '',
      fullName: 'Unknown User',
      email: '',
      avatar: null,
    );
  }
}

class UserInfo {
  final String id;
  final String fullName;
  final String email;
  final Avatar? avatar;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    try {
      return UserInfo(
        id: json['_id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? 'Unknown User',
        email: json['email']?.toString() ?? '',
        avatar: json['avatar'] != null && json['avatar'] is Map<String, dynamic>
            ? Avatar.fromJson(json['avatar'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('⚠️ Error parsing UserInfo: $e');
      return UserInfo(
        id: json['_id']?.toString() ?? '',
        fullName: 'Unknown User',
        email: '',
        avatar: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'avatar': avatar?.toJson(),
    };
  }
}

class Avatar {
  final String imageUrl;

  Avatar({required this.imageUrl});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    try {
      return Avatar(imageUrl: json['imageUrl']?.toString() ?? '');
    } catch (e) {
      print('⚠️ Error parsing Avatar: $e');
      return Avatar(imageUrl: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
    };
  }
}

class GroupData {
  final String id;
  final String name;
  final List<GroupMember> members;
  final List<String> admins;
  final String? groupAvatar;
  final CreatedBy createdBy;
  final String createdAt;
  final List<dynamic>? pinnedMessages;
  final String? description; // <-- Added this line

  GroupData(
      {required this.id,
      required this.name,
      required this.members,
      required this.admins,
      this.groupAvatar,
      required this.createdBy,
      required this.createdAt,
      this.description,
      this.pinnedMessages});

  factory GroupData.fromJson(Map<String, dynamic> json) {
    try {
      return GroupData(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed Group',
        members: json['members'] != null && json['members'] is List
            ? (json['members'] as List)
                .map((m) {
                  try {
                    return GroupMember.fromJson(m as Map<String, dynamic>);
                  } catch (e) {
                    print('⚠️ Skipping invalid member: $e');
                    return null;
                  }
                })
                .whereType<GroupMember>() // Filter out nulls
                .toList()
            : [],
        admins: json['admins'] != null && json['admins'] is List
            ? List<String>.from(json['admins'])
            : [],
        groupAvatar: json['groupAvatar']?.toString(),
        createdBy: json['createdBy'] != null
            ? CreatedBy.fromJson(json['createdBy'] as Map<String, dynamic>)
            : CreatedBy(id: '', fullName: 'Unknown'),
        createdAt:
            json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        description: json['description']?.toString(),
        pinnedMessages: json['pinnedMessages'] as List?,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing GroupData: $e');
      print('Stack trace: $stackTrace');

      // Return minimal valid group
      return GroupData(
        id: json['_id']?.toString() ?? 'error',
        name: json['name']?.toString() ?? 'Error Loading Group',
        members: [],
        admins: [],
        createdBy: CreatedBy(id: '', fullName: 'Unknown'),
        createdAt: DateTime.now().toIso8601String(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'members': members.map((m) => m.toJson()).toList(),
      'admins': admins,
      'groupAvatar': groupAvatar,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt,
      'description': description, // <-- Add to toJson
      'pinnedMessages': pinnedMessages
    };
  }
}

class CreatedBy {
  final String id;
  final String fullName;

  CreatedBy({
    required this.id,
    required this.fullName,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    try {
      return CreatedBy(
        id: json['_id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? 'Unknown',
      );
    } catch (e) {
      print('⚠️ Error parsing CreatedBy: $e');
      return CreatedBy(
        id: '',
        fullName: 'Unknown',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
    };
  }
}
