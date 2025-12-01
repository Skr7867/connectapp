class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Response Model (for login response)
class LoginResponseModel {
  final String message;
  final String token;
  final LoginUserModel user;

  LoginResponseModel({
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    String message;
    if (json['message'] is String) {
      message = json['message'] as String;
    } else if (json['message'] is Map) {
      final messageMap = json['message'] as Map;
      message = messageMap['text']?.toString() ??
          messageMap['error']?.toString() ??
          messageMap['message']?.toString() ??
          'Unknown message';
    } else {
      message = json['message']?.toString() ?? 'Unknown message';
    }

    return LoginResponseModel(
      message: message,
      token: json['token']?.toString() ?? '',
      user: LoginUserModel.fromJson(
          json['user'] is Map<String, dynamic> ? json['user'] : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'user': user.toJson(),
    };
  }
}

// User Model (for login response)
class LoginUserModel {
  final String id;
  final String fullName;
  final String email;
  final AvatarModel avatar;
  final List<String> interests;
  final List<String> enrolledCourses;
  final String role;
  final int xp;
  final int level;
  final List<BadgeModel> badges;
  final SettingsModel settings;
  final ReferralsModel referrals;
  final WalletModel wallet;
  final SubscriptionModel subscription;
  final int currentStreak;
  final int maxStreak;
  final List<String> loginHistory;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String lastLogin;
  final bool isPendingCreatorRequest;

  LoginUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatar,
    required this.interests,
    required this.enrolledCourses,
    required this.role,
    required this.xp,
    required this.level,
    required this.badges,
    required this.settings,
    required this.referrals,
    required this.wallet,
    required this.subscription,
    required this.currentStreak,
    required this.maxStreak,
    required this.loginHistory,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.lastLogin,
    required this.isPendingCreatorRequest,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '', // Check both _id and id
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: AvatarModel.fromJson(json['avatar'] is Map ? json['avatar'] : {}),
      interests: List<String>.from(json['interests'] ?? []),
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      role: json['role']?.toString() ?? '',
      xp: json['xp']?.toInt() ?? 0,
      level: json['level']?.toInt() ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => BadgeModel.fromJson(
                  e is Map ? Map<String, dynamic>.from(e) : {}))
              .toList() ??
          [],
      settings: SettingsModel.fromJson(
          json['settings'] is Map ? json['settings'] : {}),
      referrals: ReferralsModel.fromJson(
          json['referrals'] is Map ? json['referrals'] : {}),
      wallet: WalletModel.fromJson(json['wallet'] is Map ? json['wallet'] : {}),
      subscription: SubscriptionModel.fromJson(
          json['subscription'] is Map ? json['subscription'] : {}),
      currentStreak: json['currentStreak']?.toInt() ?? 0,
      maxStreak: json['maxStreak']?.toInt() ?? 0,
      loginHistory: List<String>.from(json['loginHistory'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v']?.toInt() ?? 0,
      lastLogin: json['lastLogin']?.toString() ?? '',
      isPendingCreatorRequest: json['isPendingCreatorRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'avatar': avatar.toJson(),
      'interests': interests,
      'enrolledCourses': enrolledCourses,
      'role': role,
      'xp': xp,
      'level': level,
      'badges': badges.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
      'referrals': referrals.toJson(),
      'wallet': wallet.toJson(),
      'subscription': subscription.toJson(),
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'loginHistory': loginHistory,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'lastLogin': lastLogin,
      'isPendingCreatorRequest': isPendingCreatorRequest,
    };
  }
}

// Avatar Model
class AvatarModel {
  final String id;
  final String name;
  final String imageUrl;
  final bool isActive;
  final int v;

  AvatarModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isActive,
    required this.v,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      v: json['__v']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'imageUrl': imageUrl,
      'isActive': isActive,
      '__v': v,
    };
  }
}

// Badge Model
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final int xpRequired;
  final String iconUrl;
  final String createdAt;
  final String updatedAt;
  final int v;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.xpRequired,
    required this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      xpRequired: json['xpRequired']?.toInt() ?? 0,
      iconUrl: json['iconUrl']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'xpRequired': xpRequired,
      'iconUrl': iconUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

// Settings Model
class SettingsModel {
  final NotificationsModel notifications;
  final AppearanceModel appearance;
  final TwoFactorAuthModel twoFactorAuth;

  SettingsModel({
    required this.notifications,
    required this.appearance,
    required this.twoFactorAuth,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notifications: NotificationsModel.fromJson(
          json['notifications'] is Map ? json['notifications'] : {}),
      appearance: AppearanceModel.fromJson(
          json['appearance'] is Map ? json['appearance'] : {}),
      twoFactorAuth: TwoFactorAuthModel.fromJson(
          json['twoFactorAuth'] is Map ? json['twoFactorAuth'] : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.toJson(),
      'appearance': appearance.toJson(),
      'twoFactorAuth': twoFactorAuth.toJson(),
    };
  }
}

// Notifications Model
class NotificationsModel {
  final bool push;
  final bool email;
  final bool chat;
  final bool spaces;
  final bool courses;

  NotificationsModel({
    required this.push,
    required this.email,
    required this.chat,
    required this.spaces,
    required this.courses,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      push: json['push'] ?? true,
      email: json['email'] ?? true,
      chat: json['chat'] ?? true,
      spaces: json['spaces'] ?? true,
      courses: json['courses'] ?? true,
    );
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

// Appearance Model
class AppearanceModel {
  final String theme;
  final String language;
  final String fontSize;

  AppearanceModel({
    required this.theme,
    required this.language,
    required this.fontSize,
  });

  factory AppearanceModel.fromJson(Map<String, dynamic> json) {
    return AppearanceModel(
      theme: json['theme']?.toString() ?? 'light',
      language: json['language']?.toString() ?? 'en',
      fontSize: json['fontSize']?.toString() ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'fontSize': fontSize,
    };
  }
}

// Two-Factor Authentication Model
class TwoFactorAuthModel {
  final bool enabled;
  final String method;
  final bool verified;

  TwoFactorAuthModel({
    required this.enabled,
    required this.method,
    required this.verified,
  });

  factory TwoFactorAuthModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorAuthModel(
      enabled: json['enabled'] ?? false,
      method: json['method']?.toString() ?? 'authenticator',
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'method': method,
      'verified': verified,
    };
  }
}

// Referrals Model
class ReferralsModel {
  final List<String> referredUsers;

  ReferralsModel({
    required this.referredUsers,
  });

  factory ReferralsModel.fromJson(Map<String, dynamic> json) {
    return ReferralsModel(
      referredUsers: List<String>.from(json['referredUsers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referredUsers': referredUsers,
    };
  }
}

// Wallet Model
class WalletModel {
  final double balance;
  final String lastUpdated;
  final double totalEarned;
  final double totalSpent;
  final int coins;

  WalletModel({
    required this.balance,
    required this.lastUpdated,
    required this.totalEarned,
    required this.totalSpent,
    required this.coins,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated']?.toString() ?? '',
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      coins: json['coins']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'lastUpdated': lastUpdated,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'coins': coins,
    };
  }
}

// Subscription Model
class SubscriptionModel {
  final String status;
  final String planId;
  final String startDate;
  final String endDate;

  SubscriptionModel({
    required this.status,
    required this.planId,
    required this.startDate,
    required this.endDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      status: json['status']?.toString() ?? 'Inactive',
      planId: json['planId']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'planId': planId,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
