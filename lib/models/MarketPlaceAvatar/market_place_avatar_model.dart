class MarketPlaceAvatarModel {
  String? message;
  Marketplace? marketplace;

  MarketPlaceAvatarModel({this.message, this.marketplace});

  MarketPlaceAvatarModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    marketplace = json['marketplace'] != null
        ? Marketplace.fromJson(json['marketplace'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (marketplace != null) {
      data['marketplace'] = marketplace!.toJson();
    }
    return data;
  }
}

class Marketplace {
  List<Avatars>? avatars;
  List<Collections>? collections;

  Marketplace({this.avatars, this.collections});

  Marketplace.fromJson(Map<String, dynamic> json) {
    if (json['avatars'] != null) {
      avatars = <Avatars>[];
      json['avatars'].forEach((v) {
        avatars!.add(Avatars.fromJson(v));
      });
    }
    if (json['collections'] != null) {
      collections = <Collections>[];
      json['collections'].forEach((v) {
        collections!.add(Collections.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (avatars != null) {
      data['avatars'] = avatars!.map((v) => v.toJson()).toList();
    }
    if (collections != null) {
      data['collections'] = collections!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Avatars {
  String? sId;
  String? name;
  String? description;
  String? avatar3dUrl;
  String? avatar2dUrl;
  int? coins;
  String? status;
  UserId? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isOwnedByCurrentUser;
  int? price;

  Avatars(
      {this.sId,
      this.name,
      this.description,
      this.avatar3dUrl,
      this.avatar2dUrl,
      this.coins,
      this.status,
      this.userId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.isOwnedByCurrentUser,
      this.price});

  Avatars.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    avatar3dUrl = json['Avatar3dUrl'];
    avatar2dUrl = json['Avatar2dUrl'];
    coins = json['coins'];
    status = json['status'];
    userId =
        json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isOwnedByCurrentUser = json['isOwnedByCurrentUser'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['Avatar3dUrl'] = avatar3dUrl;
    data['Avatar2dUrl'] = avatar2dUrl;
    data['coins'] = coins;
    data['status'] = status;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['isOwnedByCurrentUser'] = isOwnedByCurrentUser;
    data['price'] = price;
    return data;
  }
}

class UserId {
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;
  Subscription? subscription;
  SubscriptionFeatures? subscriptionFeatures;

  UserId(
      {this.sId,
      this.fullName,
      this.username,
      this.avatar,
      this.subscription,
      this.subscriptionFeatures});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;
    subscriptionFeatures = json['subscriptionFeatures'] != null
        ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    if (subscriptionFeatures != null) {
      data['subscriptionFeatures'] = subscriptionFeatures!.toJson();
    }
    return data;
  }
}

class Avatar {
  String? sId;
  String? imageUrl;

  Avatar({this.sId, this.imageUrl});

  Avatar.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['imageUrl'] = imageUrl;
    return data;
  }
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['planId'] = planId;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    return data;
  }
}

class SubscriptionFeatures {
  String? premiumIconUrl;

  SubscriptionFeatures({this.premiumIconUrl});

  SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    premiumIconUrl = json['premiumIconUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['premiumIconUrl'] = premiumIconUrl;
    return data;
  }
}

class Collections {
  String? sId;
  String? name;
  String? description;
  Creator? creator;
  List<Avatars>? avatars;
  int? coins;
  bool? isPublished;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Collections(
      {this.sId,
      this.name,
      this.description,
      this.creator,
      this.avatars,
      this.coins,
      this.isPublished,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Collections.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    if (json['avatars'] != null) {
      avatars = <Avatars>[];
      json['avatars'].forEach((v) {
        avatars!.add(Avatars.fromJson(v));
      });
    }
    coins = json['coins'];
    isPublished = json['isPublished'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    if (avatars != null) {
      data['avatars'] = avatars!.map((v) => v.toJson()).toList();
    }
    data['coins'] = coins;
    data['isPublished'] = isPublished;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Creator {
  SubscriptionFeatures? subscriptionFeatures;
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;
  String? id;

  Creator(
      {this.subscriptionFeatures,
      this.sId,
      this.fullName,
      this.username,
      this.avatar,
      this.id});

  Creator.fromJson(Map<String, dynamic> json) {
    subscriptionFeatures = json['subscriptionFeatures'] != null
        ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
        : null;
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (subscriptionFeatures != null) {
      data['subscriptionFeatures'] = subscriptionFeatures!.toJson();
    }
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['id'] = id;
    return data;
  }
}

class Avatarss {
  String? sId;
  String? name;
  String? description;
  String? avatar3dUrl;
  String? avatar2dUrl;

  Avatarss(
      {this.sId,
      this.name,
      this.description,
      this.avatar3dUrl,
      this.avatar2dUrl});

  Avatarss.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    avatar3dUrl = json['Avatar3dUrl'];
    avatar2dUrl = json['Avatar2dUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['Avatar3dUrl'] = avatar3dUrl;
    data['Avatar2dUrl'] = avatar2dUrl;
    return data;
  }
}
