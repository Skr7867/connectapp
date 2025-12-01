class ShowAllUsersModel {
  List<Users>? users;

  ShowAllUsersModel({this.users});

  ShowAllUsersModel.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  Wallet? wallet;
  Subscription? subscription;
  SubscriptionFeatures? subscriptionFeatures;
  String? sId;
  String? fullName;
  String? username;
  String? email;
  Avatar? avatar;
  String? role;
  int? xp;
  int? level;
  List<Badges>? badges;
  String? id;

  Users(
      {this.wallet,
      this.subscription,
      this.subscriptionFeatures,
      this.sId,
      this.fullName,
      this.username,
      this.email,
      this.avatar,
      this.role,
      this.xp,
      this.level,
      this.badges,
      this.id});

  Users.fromJson(Map<String, dynamic> json) {
    wallet =
        json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null;
    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;
    subscriptionFeatures = json['subscriptionFeatures'] != null
        ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
        : null;
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    role = json['role'];
    xp = json['xp'];
    level = json['level'];
    if (json['badges'] != null) {
      badges = <Badges>[];
      json['badges'].forEach((v) {
        badges!.add(Badges.fromJson(v));
      });
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    if (subscriptionFeatures != null) {
      data['subscriptionFeatures'] = subscriptionFeatures!.toJson();
    }
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['role'] = role;
    data['xp'] = xp;
    data['level'] = level;
    if (badges != null) {
      data['badges'] = badges!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class Wallet {
  int? coins;

  Wallet({this.coins});

  Wallet.fromJson(Map<String, dynamic> json) {
    coins = json['coins'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coins'] = coins;
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

class Badges {
  String? sId;
  String? name;

  Badges({this.sId, this.name});

  Badges.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}
