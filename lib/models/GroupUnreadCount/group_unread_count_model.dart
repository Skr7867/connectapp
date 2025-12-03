// class GroupUnreadCountModel {
//   String? id;
//   String? name;
//   String? groupAvatar;
//   int unreadCount;
//   List<Member>? members;
//   LastMessage? lastMessage;
//   String? createdAt;

//   GroupUnreadCountModel({
//     this.id,
//     this.name,
//     this.groupAvatar,
//     this.members,
//     this.lastMessage,
//     this.createdAt,
//     this.unreadCount = 0,
//   });

//   factory GroupUnreadCountModel.fromJson(Map<String, dynamic> json) {
//     return GroupUnreadCountModel(
//       id: json['_id'],
//       name: json['name'],
//       groupAvatar: json['groupAvatar'],
//       unreadCount: json['unreadCount'] ?? 0,
//       members: json['members'] != null
//           ? (json['members'] as List).map((m) => Member.fromJson(m)).toList()
//           : null,
//       lastMessage: json['lastMessage'] != null
//           ? LastMessage.fromJson(json['lastMessage'])
//           : null,
//       createdAt: json['createdAt'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "name": name,
//       "groupAvatar": groupAvatar,
//       "unreadCount": unreadCount,
//       "members": members?.map((e) => e.toJson()).toList(),
//       "lastMessage": lastMessage?.toJson(),
//       "createdAt": createdAt,
//     };
//   }

//   DateTime get effectiveTimestamp {
//     if (lastMessage?.timestamp != null) {
//       return lastMessage!.timestamp!;
//     }
//     if (createdAt != null) {
//       try {
//         return DateTime.parse(createdAt!);
//       } catch (e) {
//         return DateTime.now();
//       }
//     }
//     return DateTime.now();
//   }
// }

// class Member {
//   String? joinedAt;
//   String? id;
//   UserId? userId;

//   Member({
//     this.joinedAt,
//     this.id,
//     this.userId,
//   });

//   factory Member.fromJson(Map<String, dynamic> json) {
//     return Member(
//       joinedAt: json['joinedAt'],
//       id: json['_id'],
//       userId: json['userId'] != null ? UserId.fromJson(json['userId']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "joinedAt": joinedAt,
//       "_id": id,
//       "userId": userId?.toJson(),
//     };
//   }
// }

// class UserId {
//   String? id;
//   String? fullName;
//   Avatar? avatar;

//   UserId({
//     this.id,
//     this.fullName,
//     this.avatar,
//   });

//   factory UserId.fromJson(Map<String, dynamic> json) {
//     return UserId(
//       id: json['_id'],
//       fullName: json['fullName'],
//       avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "fullName": fullName,
//       "avatar": avatar?.toJson(),
//     };
//   }
// }

// class Avatar {
//   String? id;
//   String? imageUrl;

//   Avatar({this.id, this.imageUrl});

//   factory Avatar.fromJson(Map<String, dynamic> json) {
//     return Avatar(
//       id: json["_id"],
//       imageUrl: json["imageUrl"],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "imageUrl": imageUrl,
//     };
//   }
// }

// class LastMessage {
//   String? text;
//   String? sentAt;
//   DateTime? timestamp;

//   LastMessage({this.text, this.sentAt, this.timestamp});

//   factory LastMessage.fromJson(Map<String, dynamic> json) {
//     DateTime? timestamp;

//     if (json['sentAt'] != null) {
//       try {
//         timestamp = DateTime.parse(json['sentAt']);
//       } catch (e) {
//         timestamp = DateTime.now();
//       }
//     }

//     return LastMessage(
//       text: json['text'],
//       sentAt: json['sentAt'],
//       timestamp: timestamp,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "text": text,
//       "sentAt": sentAt,
//     };
//   }
// }

class GroupUnreadCountModel {
  String? id;
  String? name;
  List<Members>? members;
  String? label;
  String? description;
  List<String>? admins;
  String? groupAvatar;
  UserId? createdBy;
  List<dynamic>? pinnedMessages; // FIXED
  UnreadCounts? unreadCounts;
  String? inviteToken;
  bool? isInviteLinkActive;
  String? createdAt;
  String? updatedAt;
  int? v;
  LastMessage? lastMessage;
  int? unreadCount;

  GroupUnreadCountModel({
    this.id,
    this.name,
    this.members,
    this.label,
    this.description,
    this.admins,
    this.groupAvatar,
    this.createdBy,
    this.pinnedMessages,
    this.unreadCounts,
    this.inviteToken,
    this.isInviteLinkActive,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.lastMessage,
    this.unreadCount,
  });

  DateTime get effectiveTimestamp {
    if (lastMessage?.timestamp != null) {
      return lastMessage!.timestamp!;
    }
    if (createdAt != null) {
      try {
        return DateTime.parse(createdAt!);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  GroupUnreadCountModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];

    if (json['members'] != null) {
      members =
          (json['members'] as List).map((e) => Members.fromJson(e)).toList();
    }

    label = json['label'];
    description = json['description'];
    admins = json['admins'] != null ? List<String>.from(json['admins']) : [];
    groupAvatar = json['groupAvatar'];

    createdBy =
        json['createdBy'] != null ? UserId.fromJson(json['createdBy']) : null;

    pinnedMessages =
        json['pinnedMessages'] != null ? List.from(json['pinnedMessages']) : [];

    unreadCounts = json['unreadCounts'] != null
        ? UnreadCounts.fromJson(json['unreadCounts'])
        : null;

    inviteToken = json['inviteToken'];
    isInviteLinkActive = json['isInviteLinkActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];

    lastMessage = json['lastMessage'] != null
        ? LastMessage.fromJson(json['lastMessage'])
        : null;

    unreadCount = json['unreadCount'];
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "members": members?.map((e) => e.toJson()).toList(),
        "label": label,
        "description": description,
        "admins": admins,
        "groupAvatar": groupAvatar,
        "createdBy": createdBy?.toJson(),
        "pinnedMessages": pinnedMessages,
        "unreadCounts": unreadCounts?.toJson(),
        "inviteToken": inviteToken,
        "isInviteLinkActive": isInviteLinkActive,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
        "lastMessage": lastMessage?.toJson(),
        "unreadCount": unreadCount,
      };
}

class Members {
  UserId? userId;
  String? joinedAt;
  String? id;

  Members({this.userId, this.joinedAt, this.id});

  Members.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    joinedAt = json['joinedAt'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() => {
        "userId": userId?.toJson(),
        "joinedAt": joinedAt,
        "_id": id,
      };
}

class UserId {
  Subscription? subscription;
  SubscriptionFeatures? subscriptionFeatures;
  String? id;
  String? fullName;
  String? username;
  String? email;
  Avatar? avatar;
  String? uid;

  UserId({
    this.subscription,
    this.subscriptionFeatures,
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.avatar,
    this.uid,
  });

  UserId.fromJson(Map<String, dynamic> json) {
    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;

    subscriptionFeatures = json['subscriptionFeatures'] != null
        ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
        : null;

    id = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];

    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;

    uid = json['id'];
  }

  Map<String, dynamic> toJson() => {
        "subscription": subscription?.toJson(),
        "subscriptionFeatures": subscriptionFeatures?.toJson(),
        "_id": id,
        "fullName": fullName,
        "username": username,
        "email": email,
        "avatar": avatar?.toJson(),
        "id": uid,
      };
}

class Subscription {
  String? status;
  String? planId;
  String? startDate;
  String? endDate;

  Subscription({this.status, this.planId, this.startDate, this.endDate});

  Subscription.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    planId = json['planId'];
    startDate = json['startDate'];
    endDate = json['endDate'];
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "planId": planId,
        "startDate": startDate,
        "endDate": endDate,
      };
}

class SubscriptionFeatures {
  String? premiumIconUrl;

  SubscriptionFeatures({this.premiumIconUrl});

  SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    premiumIconUrl = json['premiumIconUrl'];
  }

  Map<String, dynamic> toJson() => {
        "premiumIconUrl": premiumIconUrl,
      };
}

class Avatar {
  String? id;
  String? imageUrl;

  Avatar({this.id, this.imageUrl});

  Avatar.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "imageUrl": imageUrl,
      };
}

class UnreadCounts {
  UnreadCounts();

  UnreadCounts.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() => {};
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
