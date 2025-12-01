// Model classes
class ProfileResponse {
  final String message;
  final UserProfile profile;

  ProfileResponse({required this.message, required this.profile});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'],
      profile: UserProfile.fromJson(json['profile']),
    );
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final Avatar? avatar;
  final SocialLinks socialLinks;
  final Wallet wallet;
  final int level;
  final int xp;
  int followerCount;
  final int followingCount;
  final bool isPrivate;
  bool isFollowing;
  final bool isFollowedByUser;
  final bool isFollowRequested;
  final bool privateButNotForYou;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatar,
    required this.socialLinks,
    required this.wallet,
    required this.level,
    required this.xp,
    required this.followerCount,
    required this.followingCount,
    required this.isPrivate,
    required this.isFollowing,
    required this.isFollowedByUser,
    required this.isFollowRequested,
    required this.privateButNotForYou,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'],
      fullName: json['fullName'],
      username: json['username'],
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
      socialLinks: SocialLinks.fromJson(json['socialLinks']),
      wallet: Wallet.fromJson(json['wallet']),
      level: json['level'],
      xp: json['xp'],
      followerCount: json['followerCount'],
      followingCount: json['followingCount'],
      isPrivate: json['isPrivate'],
      isFollowing: json['isFollowing'],
      isFollowedByUser: json['isFollowedByUser'],
      isFollowRequested: json['isFollowRequested'],
      privateButNotForYou: json['privateButNotForYou'],
    );
  }
}

class Avatar {
  final String id;
  final String imageUrl;

  Avatar({required this.id, required this.imageUrl});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['_id'],
      imageUrl: json['imageUrl'],
    );
  }
}

class SocialLinks {
  final String instagram;
  final String twitter;
  final String linkedin;
  final String website;

  SocialLinks({
    required this.instagram,
    required this.twitter,
    required this.linkedin,
    required this.website,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
      linkedin: json['linkedin'] ?? '',
      website: json['website'] ?? '',
    );
  }
}

class Wallet {
  final int coins;

  Wallet({required this.coins});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(coins: json['coins']);
  }
}
