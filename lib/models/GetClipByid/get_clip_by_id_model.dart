class GetClipbyidModel {
  String? message;
  Clip? clip;

  GetClipbyidModel({this.message, this.clip});

  GetClipbyidModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    clip = json['clip'] != null ? Clip.fromJson(json['clip']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    if (clip != null) {
      data['clip'] = clip!.toJson();
    }
    return data;
  }
}

class Clip {
  String? sId;
  UserId? userId;
  String? clipId;
  String? caption;
  List<dynamic>? tags;
  String? status;
  bool? isPrivate;
  String? createdAt;
  int? iV;
  String? originalFileName;
  String? processedKey;
  String? processedUrl;
  String? thumbnailKey;
  String? thumbnailUrl;
  int? commentCount;
  int? likeCount;
  bool? isLiked;
  int? totalClipsByUser;
  bool? isReposted;
  List<dynamic>? repostedByFollowings;

  Clip({
    this.sId,
    this.userId,
    this.clipId,
    this.caption,
    this.tags,
    this.status,
    this.isPrivate,
    this.createdAt,
    this.iV,
    this.originalFileName,
    this.processedKey,
    this.processedUrl,
    this.thumbnailKey,
    this.thumbnailUrl,
    this.commentCount,
    this.likeCount,
    this.isLiked,
    this.totalClipsByUser,
    this.isReposted,
    this.repostedByFollowings,
  });

  Clip.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    clipId = json['clipId'];
    caption = json['caption'];
    tags = json['tags'] ?? [];
    status = json['status'];
    isPrivate = json['isPrivate'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    originalFileName = json['originalFileName'];
    processedKey = json['processedKey'];
    processedUrl = json['processedUrl'];
    thumbnailKey = json['thumbnailKey'];
    thumbnailUrl = json['thumbnailUrl'];
    commentCount = json['commentCount'];
    likeCount = json['likeCount'];
    isLiked = json['isLiked'];
    totalClipsByUser = json['totalClipsByUser'];
    isReposted = json['isReposted'];
    repostedByFollowings = json['repostedByFollowings'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['clipId'] = clipId;
    data['caption'] = caption;
    if (tags != null) {
      data['tags'] = tags;
    }
    data['status'] = status;
    data['isPrivate'] = isPrivate;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['originalFileName'] = originalFileName;
    data['processedKey'] = processedKey;
    data['processedUrl'] = processedUrl;
    data['thumbnailKey'] = thumbnailKey;
    data['thumbnailUrl'] = thumbnailUrl;
    data['commentCount'] = commentCount;
    data['likeCount'] = likeCount;
    data['isLiked'] = isLiked;
    data['totalClipsByUser'] = totalClipsByUser;
    data['isReposted'] = isReposted;
    if (repostedByFollowings != null) {
      data['repostedByFollowings'] = repostedByFollowings;
    }
    return data;
  }
}

class UserId {
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;
  String? role;
  int? xp;
  int? level;
  Wallet? wallet;
  Subscription? subscription;
  SubscriptionFeatures? subscriptionFeatures;
  int? followingCount;
  int? followerCount;

  UserId(
      {this.sId,
      this.fullName,
      this.username,
      this.avatar,
      this.role,
      this.xp,
      this.level,
      this.wallet,
      this.subscription,
      this.subscriptionFeatures,
      this.followingCount,
      this.followerCount});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    role = json['role'];
    xp = json['xp'];
    level = json['level'];
    wallet = json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null;
    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;
    subscriptionFeatures = json['subscriptionFeatures'] != null
        ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
        : null;
    followingCount = json['followingCount'];
    followerCount = json['followerCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['role'] = role;
    data['xp'] = xp;
    data['level'] = level;
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    if (subscriptionFeatures != null) {
      data['subscriptionFeatures'] = subscriptionFeatures!.toJson();
    }
    data['followingCount'] = followingCount;
    data['followerCount'] = followerCount;
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
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['imageUrl'] = imageUrl;
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
    final Map<String, dynamic> data = {};
    data['coins'] = coins;
    return data;
  }
}

class Subscription {
  String? status;

  Subscription({this.status});

  Subscription.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    return data;
  }
}

class SubscriptionFeatures {
  String? premiumIconUrl; // ✅ FIXED: was Null? now String?

  SubscriptionFeatures({this.premiumIconUrl});

  SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    premiumIconUrl = json['premiumIconUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['premiumIconUrl'] = premiumIconUrl;
    return data;
  }
}
