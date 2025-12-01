class LeaderboardResponseModel {
  final List<LeaderboardUserModel> leaderboard;
  final CurrentUserModel currentUser;

  LeaderboardResponseModel({
    List<LeaderboardUserModel>? leaderboard,
    CurrentUserModel? currentUser,
  })  : leaderboard = leaderboard ?? [],
        currentUser = currentUser ?? CurrentUserModel();

  factory LeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponseModel(
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((item) =>
                  LeaderboardUserModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      currentUser: CurrentUserModel.fromJson(json['currentUser'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaderboard': leaderboard.map((user) => user.toJson()).toList(),
      'currentUser': currentUser.toJson(),
    };
  }
}

class LeaderboardUserModel {
  final String id;
  final String fullName;
  final AvatarModel avatar;
  final int xp;
  final int level;
  final int rank;

  LeaderboardUserModel({
    String? id,
    String? fullName,
    AvatarModel? avatar,
    int? xp,
    int? level,
    int? rank,
  })  : id = id ?? '',
        fullName = fullName ?? '',
        avatar = avatar ?? AvatarModel(),
        xp = xp ?? 0,
        level = level ?? 0,
        rank = rank ?? 0;

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatar: AvatarModel.fromJson(json['avatar'] ?? {}),
      xp: json['xp']?.toInt() ?? 0,
      level: json['level']?.toInt() ?? 0,
      rank: json['rank']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'avatar': avatar.toJson(),
      'xp': xp,
      'level': level,
      'rank': rank,
    };
  }
}

class AvatarModel {
  final String id;
  final String imageUrl;

  AvatarModel({
    String? id,
    String? imageUrl,
  })  : id = id ?? '',
        imageUrl = imageUrl ?? '';

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['_id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
    };
  }
}

class CurrentUserModel {
  final String id;
  final String fullName;
  final String avatar; // Avatar is a string (ID) in currentUser
  final int xp;
  final int level;
  final int rank;

  CurrentUserModel({
    String? id,
    String? fullName,
    String? avatar,
    int? xp,
    int? level,
    int? rank,
  })  : id = id ?? '',
        fullName = fullName ?? '',
        avatar = avatar ?? '',
        xp = xp ?? 0,
        level = level ?? 0,
        rank = rank ?? 0;

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      xp: json['xp']?.toInt() ?? 0,
      level: json['level']?.toInt() ?? 0,
      rank: json['rank']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'avatar': avatar,
      'xp': xp,
      'level': level,
      'rank': rank,
    };
  }
}
