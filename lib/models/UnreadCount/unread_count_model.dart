class UnreadCountModel {
  final String? sId;
  final List<Participants>? participants;
  final int? unreadCount;
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

  // ✅ copyWith
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

  // JSON From
  factory UnreadCountModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountModel(
      sId: json['_id'],
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((v) => Participants.fromJson(v))
              .toList()
          : null,
      unreadCount: json['unreadCount'],
      pinnedMessages: json['pinnedMessages'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'])
          : null,
    );
  }

  // JSON To
  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'participants': participants?.map((v) => v.toJson()).toList(),
      'unreadCount': unreadCount,
      'pinnedMessages': pinnedMessages,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastMessage': lastMessage?.toJson(),
    };
  }
}

class Participants {
  final Subscription? subscription;
  final SubscriptionFeatures? subscriptionFeatures;
  final Status? status;
  final String? sId;
  final String? fullName;
  final String? email;
  final Avatar? avatar;
  final String? id;

  Participants({
    this.subscription,
    this.subscriptionFeatures,
    this.status,
    this.sId,
    this.fullName,
    this.email,
    this.avatar,
    this.id,
  });

  Participants copyWith({
    Subscription? subscription,
    SubscriptionFeatures? subscriptionFeatures,
    Status? status,
    String? sId,
    String? fullName,
    String? email,
    Avatar? avatar,
    String? id,
  }) {
    return Participants(
      subscription: subscription ?? this.subscription,
      subscriptionFeatures: subscriptionFeatures ?? this.subscriptionFeatures,
      status: status ?? this.status,
      sId: sId ?? this.sId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      id: id ?? this.id,
    );
  }

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
      subscriptionFeatures: json['subscriptionFeatures'] != null
          ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
          : null,
      status: json['status'] != null ? Status.fromJson(json['status']) : null,
      sId: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription': subscription?.toJson(),
      'subscriptionFeatures': subscriptionFeatures?.toJson(),
      'status': status?.toJson(),
      '_id': sId,
      'fullName': fullName,
      'email': email,
      'avatar': avatar?.toJson(),
      'id': id,
    };
  }
}

class Subscription {
  final dynamic planId;
  final String? status;
  final dynamic startDate;
  final dynamic endDate;

  Subscription({this.planId, this.status, this.startDate, this.endDate});

  Subscription copyWith({
    dynamic planId,
    String? status,
    dynamic startDate,
    dynamic endDate,
  }) {
    return Subscription(
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      planId: json['planId'],
      status: json['status'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class SubscriptionFeatures {
  final dynamic premiumIconUrl;

  SubscriptionFeatures({this.premiumIconUrl});

  SubscriptionFeatures copyWith({dynamic premiumIconUrl}) {
    return SubscriptionFeatures(
      premiumIconUrl: premiumIconUrl ?? this.premiumIconUrl,
    );
  }

  factory SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeatures(
      premiumIconUrl: json['premiumIconUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'premiumIconUrl': premiumIconUrl};
  }
}

class Avatar {
  final String? sId;
  final String? imageUrl;

  Avatar({this.sId, this.imageUrl});

  Avatar copyWith({String? sId, String? imageUrl}) {
    return Avatar(
      sId: sId ?? this.sId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      sId: json['_id'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'imageUrl': imageUrl,
    };
  }
}

class Status {
  final bool? isOnline;
  final String? lastSeen;

  Status({this.isOnline, this.lastSeen});

  Status copyWith({bool? isOnline, String? lastSeen}) {
    return Status(
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      isOnline: json['isOnline'],
      lastSeen: json['lastSeen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}

class LastMessage {
  final String? text;
  final String? sentAt;

  LastMessage({
    this.text,
    this.sentAt,
  });

  LastMessage copyWith({
    String? text,
    String? sentAt,
  }) {
    return LastMessage(
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      text: json['text'],
      sentAt: json['sentAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sentAt': sentAt,
    };
  }
}
