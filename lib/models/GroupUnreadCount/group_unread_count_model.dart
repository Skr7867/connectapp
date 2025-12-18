class GroupUnreadCountModel {
  String? id;
  String? name;
  String? groupAvatar;
  int unreadCount;
  List<Member>? members;
  LastMessage? lastMessage;
  String? createdAt;

  GroupUnreadCountModel({
    this.id,
    this.name,
    this.groupAvatar,
    this.members,
    this.lastMessage,
    this.createdAt,
    this.unreadCount = 0,
  });

  factory GroupUnreadCountModel.fromJson(Map<String, dynamic> json) {
    return GroupUnreadCountModel(
      id: json['_id'],
      name: json['name'],
      groupAvatar: json['groupAvatar'],
      unreadCount: json['unreadCount'] ?? 0,
      members: json['members'] != null
          ? (json['members'] as List).map((m) => Member.fromJson(m)).toList()
          : null,
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'])
          : null,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "groupAvatar": groupAvatar,
      "unreadCount": unreadCount,
      "members": members?.map((e) => e.toJson()).toList(),
      "lastMessage": lastMessage?.toJson(),
      "createdAt": createdAt,
    };
  }

  DateTime get effectiveTimestamp {
    // First priority: Use lastMessage timestamp if available
    if (lastMessage?.timestamp != null) {
      return lastMessage!.timestamp!;
    }

    // Second priority: Parse sentAt if timestamp is null
    if (lastMessage?.sentAt != null) {
      try {
        return DateTime.parse(lastMessage!.sentAt!);
      } catch (e) {
        // Failed to parse sentAt, continue to next option
      }
    }

    // Third priority: Use group creation date
    if (createdAt != null) {
      try {
        return DateTime.parse(createdAt!);
      } catch (e) {
        // Failed to parse createdAt
      }
    }

    // Last resort: Use a fixed old date instead of DateTime.now()
    // This ensures groups without messages stay at the bottom
    return DateTime(2000, 1, 1);
  }
}

class Member {
  String? joinedAt;
  String? id;
  UserId? userId;

  Member({
    this.joinedAt,
    this.id,
    this.userId,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      joinedAt: json['joinedAt'],
      id: json['_id'],
      userId: json['userId'] != null ? UserId.fromJson(json['userId']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "joinedAt": joinedAt,
      "_id": id,
      "userId": userId?.toJson(),
    };
  }
}

class UserId {
  String? id;
  String? fullName;
  Avatar? avatar;

  UserId({
    this.id,
    this.fullName,
    this.avatar,
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json['_id'],
      fullName: json['fullName'],
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "avatar": avatar?.toJson(),
    };
  }
}

class Avatar {
  String? id;
  String? imageUrl;

  Avatar({this.id, this.imageUrl});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json["_id"],
      imageUrl: json["imageUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "imageUrl": imageUrl,
    };
  }
}

class LastMessage {
  String? text;
  String? sentAt;
  DateTime? timestamp;

  LastMessage({this.text, this.sentAt, this.timestamp});

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    DateTime? timestamp;

    if (json['sentAt'] != null) {
      try {
        timestamp = DateTime.parse(json['sentAt']);
      } catch (e) {
        timestamp = DateTime.now();
      }
    }

    return LastMessage(
      text: json['text'],
      sentAt: json['sentAt'],
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "sentAt": sentAt,
    };
  }
}
