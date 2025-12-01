class UserSocialProfileModel {
  final String message;
  final Profile profile;

  UserSocialProfileModel({
    required this.message,
    required this.profile,
  });

  factory UserSocialProfileModel.fromJson(Map<String, dynamic> json) {
    return UserSocialProfileModel(
      message: json['message'] ?? '',
      profile: Profile.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'profile': profile.toJson(),
    };
  }
}

class Profile {
  final String id;
  final String fullName;
  final String username;
  final Avatar? avatar;
  final String? bio;
  final String role;
  final Subscription subscription;
  final String? premiumIconUrl;
  final Map<String, dynamic> socialLinks;
  final Wallet wallet;
  final int level;
  final int xp;
  final int followerCount;
  final int followingCount;
  final int totalPost;
  final bool isPrivate;
  late final bool isFollowing;
  final bool isFollowedByUser;
  final bool isFollowRequested;
  final bool privateButNotForYou;

  Profile({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatar,
    this.bio,
    required this.role,
    required this.subscription,
    this.premiumIconUrl,
    required this.socialLinks,
    required this.wallet,
    required this.level,
    required this.xp,
    required this.followerCount,
    required this.followingCount,
    required this.totalPost,
    required this.isPrivate,
    required this.isFollowing,
    required this.isFollowedByUser,
    required this.isFollowRequested,
    required this.privateButNotForYou,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
      bio: json['bio'],
      role: json['role'] ?? '',
      subscription: Subscription.fromJson(json['subscription']),
      premiumIconUrl: json['premiumIconUrl'],
      socialLinks: json['socialLinks'] ?? {},
      wallet: Wallet.fromJson(json['wallet']),
      level: json['level'] ?? 0,
      xp: json['xp'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      totalPost: json['totalPost'] ?? 0,
      isPrivate: json['isPrivate'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      isFollowedByUser: json['isFollowedByUser'] ?? false,
      isFollowRequested: json['isFollowRequested'] ?? false,
      privateButNotForYou: json['privateButNotForYou'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'username': username,
      'avatar': avatar?.toJson(),
      'bio': bio,
      'role': role,
      'subscription': subscription.toJson(),
      'premiumIconUrl': premiumIconUrl,
      'socialLinks': socialLinks,
      'wallet': wallet.toJson(),
      'level': level,
      'xp': xp,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'totalPost': totalPost,
      'isPrivate': isPrivate,
      'isFollowing': isFollowing,
      'isFollowedByUser': isFollowedByUser,
      'isFollowRequested': isFollowRequested,
      'privateButNotForYou': privateButNotForYou,
    };
  }
}

class Subscription {
  final String status;

  Subscription({required this.status});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      status: json['status'] ?? 'Inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class Avatar {
  final String id;
  final String imageUrl;

  Avatar({
    required this.id,
    required this.imageUrl,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['_id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
    };
  }
}

class Wallet {
  final int coins;

  Wallet({required this.coins});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      coins: json['coins'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
    };
  }
}
