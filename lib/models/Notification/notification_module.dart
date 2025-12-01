class NotificationModel {
  List<Notifications>? notifications;
  int? unreadCount;

  NotificationModel({this.notifications, this.unreadCount});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(Notifications.fromJson(v));
      });
    }
    unreadCount = json['unreadCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notifications != null) {
      data['notifications'] =
          notifications!.map((v) => v.toJson()).toList();
    }
    data['unreadCount'] = unreadCount;
    return data;
  }
}

class Notifications {
  String? sId;
  UserId? userId;
  String? title;
  String? message;
  String? type;
  bool? isRead;
  String? fromUserId;
  String? clipId;
  String? createdAt;
  int? iV;

  Notifications(
      {this.sId,
      this.userId,
      this.title,
      this.message,
      this.type,
      this.isRead,
      this.fromUserId,
      this.clipId,
      this.createdAt,
      this.iV});

  Notifications.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId =
        json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    title = json['title'];
    message = json['message'];
    type = json['type'];
    isRead = json['isRead'];
    fromUserId = json['fromUserId'];
    clipId = json['clipId'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['title'] = title;
    data['message'] = message;
    data['type'] = type;
    data['isRead'] = isRead;
    data['fromUserId'] = fromUserId;
    data['clipId'] = clipId;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}

class UserId {
  String? sId;
  String? fullName;
  String? id;

  UserId({this.sId, this.fullName, this.id});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['id'] = id;
    return data;
  }
}
