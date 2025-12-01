class UnreadCountModel {
  final String? sId;
  final List<Participants>? participants;
  int? unreadCount;
  final List<dynamic>? pinnedMessages;
  final String? createdAt;
  final String? updatedAt;
  final LastMessage? lastMessage;

  UnreadCountModel({
    this.sId,
    this.participants,
    this.unreadCount,
    this.pinnedMessages,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
  });

  // ✅ ADD: copyWith method for immutable updates
  UnreadCountModel copyWith({
    String? sId,
    List<Participants>? participants,
    int? unreadCount,
    List<dynamic>? pinnedMessages,
    String? createdAt,
    String? updatedAt,
    LastMessage? lastMessage,
  }) {
    return UnreadCountModel(
      sId: sId ?? this.sId,
      participants: participants ?? this.participants,
      unreadCount: unreadCount ?? this.unreadCount,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  UnreadCountModel.fromJson(Map<String, dynamic> json)
      : sId = json['_id'],
        participants = json['participants'] != null
            ? (json['participants'] as List)
                .map((v) => Participants.fromJson(v))
                .toList()
            : null,
        unreadCount = json['unreadCount'],
        pinnedMessages = json['pinnedMessages'] ?? [],
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'],
        lastMessage = json['lastMessage'] != null
            ? LastMessage.fromJson(json['lastMessage'])
            : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    if (participants != null) {
      data['participants'] = participants!.map((v) => v.toJson()).toList();
    }
    data['unreadCount'] = unreadCount;
    data['pinnedMessages'] = pinnedMessages;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (lastMessage != null) {
      data['lastMessage'] = lastMessage!.toJson();
    }
    return data;
  }

  // ✅ ADD: Equality operators for proper comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnreadCountModel &&
        other.sId == sId &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode => sId.hashCode ^ unreadCount.hashCode;
}

class Participants {
  final Subscription? subscription;
  final SubscriptionFeatures? subscriptionFeatures;
  final String? sId;
  final String? fullName;
  final String? email;
  final Avatar? avatar;
  final String? id;

  Participants({
    this.subscription,
    this.subscriptionFeatures,
    this.sId,
    this.fullName,
    this.email,
    this.avatar,
    this.id,
  });

  Participants.fromJson(Map<String, dynamic> json)
      : subscription = json['subscription'] != null
            ? Subscription.fromJson(json['subscription'])
            : null,
        subscriptionFeatures = json['subscriptionFeatures'] != null
            ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
            : null,
        sId = json['_id'],
        fullName = json['fullName'],
        email = json['email'],
        avatar =
            json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
        id = json['id'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (subscription != null) data['subscription'] = subscription!.toJson();
    if (subscriptionFeatures != null) {
      data['subscriptionFeatures'] = subscriptionFeatures!.toJson();
    }
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
    if (avatar != null) data['avatar'] = avatar!.toJson();
    data['id'] = id;
    return data;
  }
}

class Subscription {
  final dynamic planId;
  final String? status;
  final dynamic startDate;
  final dynamic endDate;

  Subscription({this.planId, this.status, this.startDate, this.endDate});

  Subscription.fromJson(Map<String, dynamic> json)
      : planId = json['planId'],
        status = json['status'],
        startDate = json['startDate'],
        endDate = json['endDate'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['planId'] = planId;
    data['status'] = status;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    return data;
  }
}

class SubscriptionFeatures {
  final dynamic premiumIconUrl;

  SubscriptionFeatures({this.premiumIconUrl});

  SubscriptionFeatures.fromJson(Map<String, dynamic> json)
      : premiumIconUrl = json['premiumIconUrl'];

  Map<String, dynamic> toJson() {
    return {'premiumIconUrl': premiumIconUrl};
  }
}

class Avatar {
  final String? sId;
  final String? imageUrl;

  Avatar({this.sId, this.imageUrl});

  Avatar.fromJson(Map<String, dynamic> json)
      : sId = json['_id'],
        imageUrl = json['imageUrl'];

  Map<String, dynamic> toJson() {
    return {'_id': sId, 'imageUrl': imageUrl};
  }
}

class LastMessage {
  final String? text;
  final String? sentAt;

  LastMessage({
    this.text,
    this.sentAt,
  });

  LastMessage.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        sentAt = json['sentAt'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['text'] = text;
    data['sentAt'] = sentAt;
    return data;
  }
}
