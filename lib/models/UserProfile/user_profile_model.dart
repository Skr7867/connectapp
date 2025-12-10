class UserProfileModel {
  SocialLinks? socialLinks;
  Settings? settings;
  Wallet? wallet;
  Subscription? subscription;
  Referrals? referrals;
  String? sId;
  String? fullName;
  String? username;
  String? email;
  int? followerCount;
  int? followingCount;
  int? totalPost;
  int? totalLikes;
  Avatar? avatar;
  List<String>? purchasedAvatars;
  List<String>? interests;
  List<String>? enrolledCourses;
  String? role;
  int? xp;
  int? level;
  List<Badges>? badges; // UPDATED HERE ✔
  bool? isPendingCreatorRequest;
  SubscriptionFeatures? subscriptionFeatures;
  int? currentStreak;
  int? maxStreak;
  List<String>? loginHistory;
  bool? isDeleted;
  bool? isSuspended;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? lastLogin;
  int? xpToNextLevel;
  int? nextLevelAt;
  int? completedCourses;
  List<String>? activeDaysInWeek;
  bool? isAlreadyCreator;
  String? bio;

  UserProfileModel({
    this.socialLinks,
    this.settings,
    this.wallet,
    this.subscription,
    this.referrals,
    this.sId,
    this.fullName,
    this.username,
    this.email,
    this.followerCount,
    this.followingCount,
    this.totalPost,
    this.totalLikes,
    this.avatar,
    this.purchasedAvatars,
    this.interests,
    this.enrolledCourses,
    this.role,
    this.xp,
    this.level,
    this.badges,
    this.isPendingCreatorRequest,
    this.subscriptionFeatures,
    this.currentStreak,
    this.maxStreak,
    this.loginHistory,
    this.isDeleted,
    this.isAlreadyCreator,
    this.isSuspended,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.lastLogin,
    this.xpToNextLevel,
    this.nextLevelAt,
    this.completedCourses,
    this.bio,
    this.activeDaysInWeek,
  });

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    socialLinks = json['socialLinks'] != null
        ? SocialLinks.fromJson(json['socialLinks'])
        : null;

    settings =
        json['settings'] != null ? Settings.fromJson(json['settings']) : null;

    wallet = json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null;

    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;

    referrals = json['referrals'] != null
        ? Referrals.fromJson(json['referrals'])
        : null;

    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    followerCount = json['followerCount'];
    followingCount = json['followingCount'];
    totalPost = json['totalPost'];
    totalLikes = json['totalLikes'];
    bio = json['bio'];

    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;

    purchasedAvatars = (json['purchasedAvatars'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    interests =
        (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [];

    enrolledCourses =
        (json['enrolledCourses'] as List?)?.map((e) => e.toString()).toList() ??
            [];

    role = json['role'];
    xp = json['xp'];
    level = json['level'];

    // UPDATED ✔ — using Badges model
    if (json['badges'] != null) {
      badges = <Badges>[];
      json['badges'].forEach((v) {
        badges!.add(Badges.fromJson(v));
      });
    } else {
      badges = [];
    }

    isPendingCreatorRequest = json['isPendingCreatorRequest'];

    subscriptionFeatures = json['subscriptionFeatures'] != null
        ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
        : null;

    currentStreak = json['currentStreak'];
    maxStreak = json['maxStreak'];

    loginHistory =
        (json['loginHistory'] as List?)?.map((e) => e.toString()).toList() ??
            [];

    isDeleted = json['isDeleted'];
    isSuspended = json['isSuspended'];
    isAlreadyCreator = json['isAlreadyCreator'];

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

    lastLogin = json['lastLogin'];
    xpToNextLevel = json['xpToNextLevel'];
    nextLevelAt = json['nextLevelAt'];
    completedCourses = json['completedCourses'];

    activeDaysInWeek = (json['activeDaysInWeek'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (socialLinks != null) data['socialLinks'] = socialLinks!.toJson();

    if (settings != null) data['settings'] = settings!.toJson();

    if (wallet != null) data['wallet'] = wallet!.toJson();

    if (subscription != null) data['subscription'] = subscription!.toJson();

    if (referrals != null) data['referrals'] = referrals!.toJson();

    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    data['totalPost'] = totalPost;
    data['followerCount'] = followerCount;
    data['followingCount'] = followingCount;
    data['totalLikes'] = totalLikes;
    data['bio'] = bio;

    if (avatar != null) data['avatar'] = avatar!.toJson();

    data['purchasedAvatars'] = purchasedAvatars;
    data['interests'] = interests;
    data['enrolledCourses'] = enrolledCourses;
    data['role'] = role;
    data['xp'] = xp;
    data['level'] = level;

    // UPDATED ✔
    if (badges != null) {
      data['badges'] = badges!.map((e) => e.toJson()).toList();
    }

    data['isPendingCreatorRequest'] = isPendingCreatorRequest;

    if (subscriptionFeatures != null)
      data['subscriptionFeatures'] = subscriptionFeatures!.toJson();

    data['currentStreak'] = currentStreak;
    data['maxStreak'] = maxStreak;
    data['loginHistory'] = loginHistory;
    data['isDeleted'] = isDeleted;
    data['isSuspended'] = isSuspended;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['lastLogin'] = lastLogin;
    data['xpToNextLevel'] = xpToNextLevel;
    data['nextLevelAt'] = nextLevelAt;
    data['completedCourses'] = completedCourses;
    data['activeDaysInWeek'] = activeDaysInWeek;

    return data;
  }
}

class Badges {
  String? sId;
  String? name;
  String? description;
  int? xpRequired;
  String? iconUrl;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Badges(
      {this.sId,
      this.name,
      this.description,
      this.xpRequired,
      this.iconUrl,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Badges.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    xpRequired = json['xpRequired'];
    iconUrl = json['iconUrl'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['xpRequired'] = this.xpRequired;
    data['iconUrl'] = this.iconUrl;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class SocialLinks {
  String? instagram;
  String? twitter;
  String? linkedin;
  String? website;

  SocialLinks({this.instagram, this.twitter, this.linkedin, this.website});

  SocialLinks.fromJson(Map<String, dynamic> json) {
    instagram = json['instagram'];
    twitter = json['twitter'];
    linkedin = json['linkedin'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instagram'] = instagram;
    data['twitter'] = twitter;
    data['linkedin'] = linkedin;
    data['website'] = website;
    return data;
  }
}

class Settings {
  Notifications? notifications;
  Appearance? appearance;
  TwoFactorAuth? twoFactorAuth;

  Settings({this.notifications, this.appearance, this.twoFactorAuth});

  Settings.fromJson(Map<String, dynamic> json) {
    notifications = json['notifications'] != null
        ? Notifications.fromJson(json['notifications'])
        : null;
    appearance = json['appearance'] != null
        ? Appearance.fromJson(json['appearance'])
        : null;
    twoFactorAuth = json['twoFactorAuth'] != null
        ? TwoFactorAuth.fromJson(json['twoFactorAuth'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (notifications != null) {
      data['notifications'] = notifications!.toJson();
    }
    if (appearance != null) {
      data['appearance'] = appearance!.toJson();
    }
    if (twoFactorAuth != null) {
      data['twoFactorAuth'] = twoFactorAuth!.toJson();
    }
    return data;
  }
}

class Notifications {
  bool? push;
  bool? email;
  bool? chat;
  bool? spaces;
  bool? courses;

  Notifications({this.push, this.email, this.chat, this.spaces, this.courses});

  Notifications.fromJson(Map<String, dynamic> json) {
    push = json['push'];
    email = json['email'];
    chat = json['chat'];
    spaces = json['spaces'];
    courses = json['courses'];
  }

  Map<String, dynamic> toJson() {
    return {
      'push': push,
      'email': email,
      'chat': chat,
      'spaces': spaces,
      'courses': courses,
    };
  }
}

class Appearance {
  String? theme;
  String? language;
  String? fontSize;

  Appearance({this.theme, this.language, this.fontSize});

  Appearance.fromJson(Map<String, dynamic> json) {
    theme = json['theme'];
    language = json['language'];
    fontSize = json['fontSize'];
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'fontSize': fontSize,
    };
  }
}

class TwoFactorAuth {
  bool? enabled;
  String? method;
  bool? verified;

  TwoFactorAuth({this.enabled, this.method, this.verified});

  TwoFactorAuth.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    method = json['method'];
    verified = json['verified'];
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'method': method,
      'verified': verified,
    };
  }
}

class Wallet {
  int? coins;
  int? totalEarned;
  int? totalSpent;
  String? lastUpdated;

  Wallet({this.coins, this.totalEarned, this.totalSpent, this.lastUpdated});

  Wallet.fromJson(Map<String, dynamic> json) {
    coins = json['coins'];
    totalEarned = json['totalEarned'];
    totalSpent = json['totalSpent'];
    lastUpdated = json['lastUpdated'];
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'lastUpdated': lastUpdated,
    };
  }
}

class Subscription {
  String? planId;
  String? status;
  String? startDate;
  String? endDate;

  Subscription({this.planId, this.status, this.startDate, this.endDate});

  Subscription.fromJson(Map<String, dynamic> json) {
    planId = json['planId'];
    status = json['status'];
    startDate = json['startDate'];
    endDate = json['endDate'];
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

class ReferralUser {
  String? id;
  String? fullName;
  String? email;
  String? avatarUrl;
  String? createdAt;

  ReferralUser({
    this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.createdAt,
  });

  ReferralUser.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    avatarUrl = json['avatar']?['imageUrl'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'avatar': {'imageUrl': avatarUrl},
      'createdAt': createdAt,
    };
  }
}

class Referrals {
  List<ReferralUser>? referredUsers;
  String? referralCode;
  String? referredBy;

  Referrals({this.referredUsers, this.referralCode, this.referredBy});

  Referrals.fromJson(Map<String, dynamic> json) {
    referredBy = json['referredBy'];
    referralCode = json['referralCode'];
    referredUsers = (json['referredUsers'] as List?)
        ?.map((e) => ReferralUser.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'referredBy': referredBy,
      'referralCode': referralCode,
      'referredUsers': referredUsers?.map((e) => e.toJson()).toList(),
    };
  }
}

class Avatar {
  String? sId;
  String? name;
  String? imageUrl;
  bool? isActive;
  int? coins;
  int? iV;

  Avatar(
      {this.sId, this.name, this.imageUrl, this.isActive, this.coins, this.iV});

  Avatar.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    isActive = json['isActive'];
    coins = json['coins'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'coins': coins,
      '__v': iV,
    };
  }
}

class SubscriptionFeatures {
  int? reactionEmoji;
  int? stickerPack;
  int? publicGroup;
  bool? animatedAvatar;
  bool? premiumIcon;
  String? premiumIconUrl;
  bool? sharedLiveLocation;
  int? fileUploadSize;

  SubscriptionFeatures({
    this.reactionEmoji,
    this.stickerPack,
    this.publicGroup,
    this.animatedAvatar,
    this.premiumIcon,
    this.premiumIconUrl,
    this.sharedLiveLocation,
    this.fileUploadSize,
  });

  SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    reactionEmoji = json['reaction_emoji'];
    stickerPack = json['sticker_pack'];
    publicGroup = json['public_group'];
    animatedAvatar = json['animated_avatar'];
    premiumIcon = json['premium_icon'];
    premiumIconUrl = json['premiumIconUrl'];
    sharedLiveLocation = json['shared_live_location'];
    fileUploadSize = json['file_upload_size'];
  }

  Map<String, dynamic> toJson() {
    return {
      'reaction_emoji': reactionEmoji,
      'sticker_pack': stickerPack,
      'public_group': publicGroup,
      'animated_avatar': animatedAvatar,
      'premium_icon': premiumIcon,
      'premiumIconUrl': premiumIconUrl,
      'shared_live_location': sharedLiveLocation,
      'file_upload_size': fileUploadSize,
    };
  }
}

// Placeholder Badge model
class Badge {
  String? name;
  String? description;

  Badge({this.name, this.description});

  Badge.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
