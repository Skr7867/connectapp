class AllUsersModel {
  List<SearchedUser>? searchedUser;

  AllUsersModel({this.searchedUser});

  AllUsersModel.fromJson(Map<String, dynamic> json) {
    if (json['searchedUser'] != null) {
      searchedUser = <SearchedUser>[];
      json['searchedUser'].forEach((v) {
        searchedUser!.add(SearchedUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (searchedUser != null) {
      data['searchedUser'] = searchedUser!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchedUser {
  SocialLinks? socialLinks;
  Wallet? wallet;
  Subscription? subscription;
  SubscriptionFeatures? subscriptionFeatures;
  String? sId;
  String? fullName;
  String? email;
  Avatar? avatar;
  int? xp;
  int? level;
  List<Badges>? badges;
  String? bio;
  String? username;
  List<String>? blockedUsers;
  String? id;

  SearchedUser(
      {this.socialLinks,
      this.wallet,
      this.subscription,
      this.subscriptionFeatures,
      this.sId,
      this.fullName,
      this.email,
      this.avatar,
      this.xp,
      this.level,
      this.badges,
      this.bio,
      this.username,
      this.blockedUsers,
      this.id});

  SearchedUser.fromJson(Map<String, dynamic> json) {
    socialLinks = json['socialLinks'] != null
        ? SocialLinks.fromJson(json['socialLinks'])
        : null;
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
    email = json['email'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    xp = json['xp'];
    level = json['level'];
    if (json['badges'] != null) {
      badges = <Badges>[];
      json['badges'].forEach((v) {
        badges!.add(Badges.fromJson(v));
      });
    }
    bio = json['bio'];
    username = json['username'];
    blockedUsers = json['blockedUsers'].cast<String>();
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (socialLinks != null) {
      data['socialLinks'] = socialLinks!.toJson();
    }
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
    data['email'] = email;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['xp'] = xp;
    data['level'] = level;
    if (badges != null) {
      data['badges'] = badges!.map((v) => v.toJson()).toList();
    }
    data['bio'] = bio;
    data['username'] = username;
    data['blockedUsers'] = blockedUsers;
    data['id'] = id;
    return data;
  }
}

class SocialLinks {
  String? linkedin;
  String? twitter;
  String? instagram;
  String? website;

  SocialLinks({this.linkedin, this.twitter, this.instagram, this.website});

  SocialLinks.fromJson(Map<String, dynamic> json) {
    linkedin = json['linkedin'];
    twitter = json['twitter'];
    instagram = json['instagram'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['linkedin'] = linkedin;
    data['twitter'] = twitter;
    data['instagram'] = instagram;
    data['website'] = website;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['coins'] = coins;
    return data;
  }
}

class Subscription {
  String? endDate;
  String? planId;
  String? startDate;
  String? status;

  Subscription({this.endDate, this.planId, this.startDate, this.status});

  Subscription.fromJson(Map<String, dynamic> json) {
    endDate = json['endDate'];
    planId = json['planId'];
    startDate = json['startDate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['endDate'] = endDate;
    data['planId'] = planId;
    data['startDate'] = startDate;
    data['status'] = status;
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
  String? iconUrl;

  Badges({this.sId, this.name, this.iconUrl});

  Badges.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    iconUrl = json['iconUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['iconUrl'] = iconUrl;
    return data;
  }
}
