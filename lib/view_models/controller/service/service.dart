import 'package:flutter/cupertino.dart';

class Chat {
  final String id;
  final String name;
  final String? avatar;
  final dynamic lastMessage;
  final DateTime timestamp;
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
    return Chat(
        id: json['_id'],
        name: json['name'] ?? '',
        avatar: json['avatar'] ?? json['groupAvatar'],
        lastMessage: json['lastMessage'],
        timestamp: DateTime.parse(json['updatedAt'] ?? json['createdAt']),
        unread: json['unread'] ?? 0,
        isGroup: json['isGroup'] ?? false,
        participants: json['participants'] != null
            ? (json['participants'] as List)
                .map((p) => Participant.fromJson(p))
                .toList()
            : null,
        pinnedMessages: json['pinnedMessages']);
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

  Chat copyWith({
    String? id,
    String? name,
    String? avatar,
    String? lastMessage,
    DateTime? timestamp,
    int? unread,
    bool? isGroup,
    List<Participant>? participants,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unread: unread ?? this.unread,
      isGroup: isGroup ?? this.isGroup,
      participants: participants ?? this.participants,
    );
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
    debugPrint('Reaction JSON: $json'); // Debug print
    debugPrint('User field type: ${json['user'].runtimeType}'); // Debug print
    debugPrint('User field value: ${json['user']}'); // Debug print

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
    return ReplyTo(
      id: json['_id'] ?? json['id'],
      content: json['content'],
      sender: json['sender'] != null ? Sender.fromJson(json['sender']) : null,
    );
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
    debugPrint('Parsing message JSON: $json');
    return Message(
      id: json['_id'] ?? json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['createdAt'] ?? json['timestamp']),
      sender: Sender.fromJson(json['sender']),
      isRead: json['status'] == 'read' || json['isRead'] == true,
      status: json['status'] ?? 'sent',
      isEdited: json['isEdited'] ?? false,
      editedAt:
          json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      replyTo:
          json['replyTo'] != null ? ReplyTo.fromJson(json['replyTo']) : null,
      reactions: _parseReactions(json['reactions']),
      messageType: json['messageType'],
      isForwarded: json['isForwarded'] ?? false,
      originalSender: _parseOriginalSender(json),
      originalSenderId: _parseOriginalSenderId(json),
    );
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
      debugPrint('Error parsing original sender ID: $e');
      return null;
    }
  }

  static List<Reaction>? _parseReactions(dynamic reactionsJson) {
    if (reactionsJson == null) return null;

    if (reactionsJson is! List) {
      debugPrint('Reactions is not a list: ${reactionsJson.runtimeType}');
      return [];
    }

    List<Reaction> reactions = [];
    for (var i = 0; i < reactionsJson.length; i++) {
      try {
        var reactionData = reactionsJson[i];
        debugPrint('Processing reaction $i: $reactionData');

        if (reactionData is Map<String, dynamic>) {
          reactions.add(Reaction.fromJson(reactionData));
        } else {
          debugPrint(
              'Skipping invalid reaction at index $i: ${reactionData.runtimeType}');
        }
      } catch (e) {
        debugPrint('Error parsing reaction at index $i: $e');
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
      debugPrint('Error parsing original sender: $e');
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
      isRead: this.isRead,
      id: this.id,
      content: content ?? this.content,
      sender: this.sender,
      timestamp: this.timestamp,
      status: this.status,
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
    // Handle avatar field - it can be either a string or a map
    String? avatarUrl;

    if (json['avatar'] != null) {
      if (json['avatar'] is String) {
        // Avatar is directly a string ID or URL

        avatarUrl = json['avatar'];
      } else if (json['avatar'] is Map) {
        // Avatar is a map with imageUrl field
        avatarUrl = json['avatar']['imageUrl'];
      }
    }

    return Sender(
      id: json['_id'] ?? json['id'],
      name: json['fullName'] ?? json['name'],
      avatar: avatarUrl,
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

// Updated Participant model with toJson method
class Participant {
  final String id;
  final String name;
  final String? avatar;
  final ParticipantStatus? status;

  Participant({
    required this.id,
    required this.name,
    this.avatar,
    this.status,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? json['id'],
      name: json['fullName'] ?? json['name'],
      avatar:
          json['avatar'] is Map ? json['avatar']['imageUrl'] : json['avatar'],
      status: ParticipantStatus.fromJson(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': name,
      'avatar': avatar,
      'status': status?.toJson(),
    };
  }
}

class ParticipantStatus {
  final DateTime? lastSeen;
  final bool isOnline;

  ParticipantStatus({
    this.lastSeen,
    required this.isOnline,
  });

  factory ParticipantStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ParticipantStatus(isOnline: false);
    }

    return ParticipantStatus(
      lastSeen:
          json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen']) : null,
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSeen': lastSeen?.toIso8601String(),
      'isOnline': isOnline,
    };
  }
}

class GroupMember {
  final UserInfo userId;
  final String joinedAt;
  final String id;

  GroupMember({
    required this.userId,
    required this.joinedAt,
    required this.id,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: UserInfo.fromJson(json['userId']),
      joinedAt: json['joinedAt'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId.toJson(),
      'joinedAt': joinedAt,
      '_id': id,
    };
  }
}

class UserInfo {
  final String id;
  final String fullName;
  final String email;
  final Avatar? avatar;
  final String? username;

  UserInfo(
      {required this.id,
      required this.fullName,
      required this.email,
      this.avatar,
      this.username});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      username: json['username'],
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'avatar': avatar?.toJson(),
      'username': username,
    };
  }
}

class Avatar {
  final String imageUrl;

  Avatar({required this.imageUrl});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(imageUrl: json['imageUrl']);
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
    };
  }
}

class GroupData {
  final String? id;
  final String? name;
  final List<GroupMember>? members;
  final List<String>? admins;
  final String? groupAvatar;
  final CreatedBy? createdBy;
  final String? createdAt;
  final List<dynamic>? pinnedMessages;
  final String? description;
  final dynamic lastMessage;
  final int? unreadCount;
  final bool? isInviteLinkActive;
  final String? inviteToken;
  final String? label;
  final String? updatedAt;

  GroupData({
    this.id,
    this.name,
    this.members,
    this.admins,
    this.groupAvatar,
    this.createdBy,
    this.createdAt,
    this.description,
    this.pinnedMessages,
    this.lastMessage,
    this.unreadCount,
    this.isInviteLinkActive,
    this.inviteToken,
    this.label,
    this.updatedAt,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      members: (json['members'] as List?)
          ?.map((m) => GroupMember.fromJson(m))
          .toList(),
      admins: (json['admins'] as List?)?.map((a) => a.toString()).toList(),
      groupAvatar: json['groupAvatar'] as String?,
      createdBy: json['createdBy'] != null
          ? CreatedBy.fromJson(json['createdBy'])
          : null,
      createdAt: json['createdAt'] as String?,
      description: json['description'] as String?,
      pinnedMessages: json['pinnedMessages'] as List?,
      lastMessage: json['lastMessage'],
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount']
          : int.tryParse(json['unreadCount']?.toString() ?? ''),
      isInviteLinkActive: json['isInviteLinkActive'] as bool?,
      inviteToken: json['inviteToken'] as String?,
      label: json['label'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'members': members?.map((m) => m.toJson()).toList(),
      'admins': admins,
      'groupAvatar': groupAvatar,
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt,
      'description': description,
      'pinnedMessages': pinnedMessages,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'isInviteLinkActive': isInviteLinkActive,
      'inviteToken': inviteToken,
      'label': label,
      'updatedAt': updatedAt,
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
    return CreatedBy(
      id: json['_id'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
    };
  }
}
// services/socket_service.dart
