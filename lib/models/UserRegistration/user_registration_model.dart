// Request Model (for registration)
class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String? referralCode;
  final String? username;

  RegisterRequestModel({
    required this.username,
    required this.fullName,
    required this.email,
    required this.password,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'username': username,
      'referralCode': referralCode,
    };
  }
}

class RegisterResponseModel {
  final String message;
  final String token;
  final UserModel user;

  RegisterResponseModel({
    required this.message,
    required this.token,
    required this.user,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

// User Model
class UserModel {
  final String username;
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String avatar;
  final List<String> interests;
  final List<String> enrolledCourses;
  final String role;
  final int xp;
  final int level;
  final List<String> badges;
  final SettingsModel settings;
  final ReferralsModel referrals;
  final SubscriptionModel subscription;
  final int currentStreak;
  final int maxStreak;
  final List<String> loginHistory;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final int v;

  UserModel({
    required this.username,
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.avatar,
    required this.interests,
    required this.enrolledCourses,
    required this.role,
    required this.xp,
    required this.level,
    required this.badges,
    required this.settings,
    required this.referrals,
    required this.subscription,
    required this.currentStreak,
    required this.maxStreak,
    required this.loginHistory,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['_username'].toString(),
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      role: json['role']?.toString() ?? '',
      xp: json['xp']?.toInt() ?? 0,
      level: json['level']?.toInt() ?? 1,
      badges: List<String>.from(json['badges'] ?? []),
      settings: SettingsModel.fromJson(json['settings'] ?? {}),
      referrals: ReferralsModel.fromJson(json['referrals'] ?? {}),
      subscription: SubscriptionModel.fromJson(json['subscription'] ?? {}),
      currentStreak: json['currentStreak']?.toInt() ?? 0,
      maxStreak: json['maxStreak']?.toInt() ?? 0,
      loginHistory: List<String>.from(json['loginHistory'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v']?.toInt() ?? 0,
    );
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
      notifications: NotificationsModel.fromJson(json['notifications'] ?? {}),
      appearance: AppearanceModel.fromJson(json['appearance'] ?? {}),
      twoFactorAuth: TwoFactorAuthModel.fromJson(json['twoFactorAuth'] ?? {}),
    );
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
}

// Subscription Model
class SubscriptionModel {
  final String status;

  SubscriptionModel({
    required this.status,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      status: json['status']?.toString() ?? 'Inactive',
    );
  }
}
