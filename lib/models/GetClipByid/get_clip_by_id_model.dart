class GetClipbyidModel {
  String? message;
  Clip? clip;

  GetClipbyidModel({this.message, this.clip});

  GetClipbyidModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    clip = json['clip'] != null ? new Clip.fromJson(json['clip']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.clip != null) {
      data['clip'] = this.clip!.toJson();
    }
    return data;
  }
}

class Clip {
  String? sId;
  UserId? userId;
  String? clipId;
  String? caption;
  List<dynamic>? tags; // FIXED
  String? status;
  bool? isPrivate;
  String? createdAt;
  int? iV;
  String? originalFileName;
  String? processedKey;
  String? processedUrl;
  String? thumbnailKey;
  String? thumbnailUrl;
  int? likeCount;
  int? commentCount;
  int? viewCount;
  bool? isLiked;
  int? totalClipsByUser;
  bool? isReposted;
  List<RepostedByFollowings>? repostedByFollowings;

  Clip.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    clipId = json['clipId'];
    caption = json['caption'];

    tags = json['tags']?.cast<dynamic>(); // FIXED

    status = json['status'];
    isPrivate = json['isPrivate'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    originalFileName = json['originalFileName'];
    processedKey = json['processedKey'];
    processedUrl = json['processedUrl'];
    thumbnailKey = json['thumbnailKey'];
    thumbnailUrl = json['thumbnailUrl'];
    likeCount = json['likeCount'];
    commentCount = json['commentCount'];
    viewCount = json['viewCount'];
    isLiked = json['isLiked'];
    totalClipsByUser = json['totalClipsByUser'];
    isReposted = json['isReposted'];

    if (json['repostedByFollowings'] != null) {
      repostedByFollowings = (json['repostedByFollowings'] as List)
          .map((e) => RepostedByFollowings.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['_id'] = sId;
    if (userId != null) data['userId'] = userId!.toJson();

    data['clipId'] = clipId;
    data['caption'] = caption;

    if (tags != null) data['tags'] = tags; // FIXED

    data['status'] = status;
    data['isPrivate'] = isPrivate;
    data['createdAt'] = createdAt;
    data['__v'] = iV;

    data['originalFileName'] = originalFileName;
    data['processedKey'] = processedKey;
    data['processedUrl'] = processedUrl;
    data['thumbnailKey'] = thumbnailKey;
    data['thumbnailUrl'] = thumbnailUrl;

    data['likeCount'] = likeCount;
    data['commentCount'] = commentCount;
    data['viewCount'] = viewCount;
    data['isLiked'] = isLiked;
    data['totalClipsByUser'] = totalClipsByUser;
    data['isReposted'] = isReposted;

    if (repostedByFollowings != null) {
      data['repostedByFollowings'] =
          repostedByFollowings!.map((v) => v.toJson()).toList();
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
  int? followerCount;
  int? followingCount;

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
      this.followerCount,
      this.followingCount});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar =
        json['avatar'] != null ? new Avatar.fromJson(json['avatar']) : null;
    role = json['role'];
    xp = json['xp'];
    level = json['level'];
    wallet =
        json['wallet'] != null ? new Wallet.fromJson(json['wallet']) : null;
    subscription = json['subscription'] != null
        ? new Subscription.fromJson(json['subscription'])
        : null;
    subscriptionFeatures = json['subscriptionFeatures'] != null
        ? new SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
        : null;
    followerCount = json['followerCount'];
    followingCount = json['followingCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    if (this.avatar != null) {
      data['avatar'] = this.avatar!.toJson();
    }
    data['role'] = this.role;
    data['xp'] = this.xp;
    data['level'] = this.level;
    if (this.wallet != null) {
      data['wallet'] = this.wallet!.toJson();
    }
    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    if (this.subscriptionFeatures != null) {
      data['subscriptionFeatures'] = this.subscriptionFeatures!.toJson();
    }
    data['followerCount'] = this.followerCount;
    data['followingCount'] = this.followingCount;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['imageUrl'] = this.imageUrl;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coins'] = this.coins;
    return data;
  }
}

class Subscription {
  dynamic planId;
  String? status;
  dynamic startDate;
  dynamic endDate;

  Subscription({this.planId, this.status, this.startDate, this.endDate});

  Subscription.fromJson(Map<String, dynamic> json) {
    planId = json['planId'];
    status = json['status'];
    startDate = json['startDate'];
    endDate = json['endDate'];
  }

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
  dynamic premiumIconUrl;

  SubscriptionFeatures({this.premiumIconUrl});

  SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    premiumIconUrl = json['premiumIconUrl'];
  }

  Map<String, dynamic> toJson() {
    return {'premiumIconUrl': premiumIconUrl};
  }
}

class RepostedByFollowings {
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;

  RepostedByFollowings({this.sId, this.fullName, this.username, this.avatar});

  RepostedByFollowings.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar =
        json['avatar'] != null ? new Avatar.fromJson(json['avatar']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    if (this.avatar != null) {
      data['avatar'] = this.avatar!.toJson();
    }
    return data;
  }
}
