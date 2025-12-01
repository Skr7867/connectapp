import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/UserLogin/user_login_model.dart';
import '../../../models/UserProfile/user_profile_model.dart';

class UserPreferencesViewmodel {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save LoginResponseModel
  Future<bool> saveUser(LoginResponseModel responseModel) async {
    await init();
    final responseJson = jsonEncode({
      'message': responseModel.message.toString(),
      'token': responseModel.token,
      'user': _userToJson(responseModel.user),
    });

    await _prefs!.setString('user_data', responseJson);

    return true;
  }

  // Get LoginResponseModel
  Future<LoginResponseModel?> getUser() async {
    await init();
    final String? userData = _prefs!.getString('user_data');

    if (userData == null) {
      return null;
    }

    try {
      final Map<String, dynamic> userJson = jsonDecode(userData);
      final user = LoginResponseModel.fromJson(userJson);

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    final user = await getUser();
    return user?.token;
  }

  Future<bool> removeUser() async {
    await init();
    await _prefs!.remove('user_data');

    return true;
  }

  Future<bool> saveUserProfile(UserProfileModel profileModel) async {
    await init();
    final profileJson = jsonEncode(profileModel.toJson());

    await _prefs!.setString('profile_data', profileJson);

    return true;
  }

  Future<UserProfileModel?> getUserProfile() async {
    await init();
    final String? profileData = _prefs!.getString('profile_data');

    if (profileData == null) {
      return null;
    }

    try {
      final Map<String, dynamic> profileJson = jsonDecode(profileData);
      final profile = UserProfileModel.fromJson(profileJson);

      return profile;
    } catch (e) {
      return null;
    }
  }

  // Remove UserProfileModel
  Future<bool> removeUserProfile() async {
    await init();
    await _prefs!.remove('profile_data');

    return true;
  }

  // Clear all user-related data
  Future<bool> clearAll() async {
    await init();
    await _prefs!.remove('user_data');
    await _prefs!.remove('profile_data');
    await _prefs!.remove('userToken');
    await _prefs!.remove('tempToken');
    await _prefs!.remove('2faMethod');
    await _prefs!.remove('loggedOut');

    return true;
  }

  // Helper method for LoginUserModel
  Map<String, dynamic> _userToJson(LoginUserModel user) {
    return {
      '_id': user.id,
      'fullName': user.fullName,
      'email': user.email,
      'avatar': {
        '_id': user.avatar.id,
        'name': user.avatar.name,
        'imageUrl': user.avatar.imageUrl,
        'isActive': user.avatar.isActive,
        '__v': user.avatar.v,
      },
      'interests': user.interests,
      'enrolledCourses': user.enrolledCourses,
      'role': user.role,
      'xp': user.xp,
      'level': user.level,
      'badges': user.badges,
      'settings': {
        'notifications': {
          'push': user.settings.notifications.push,
          'email': user.settings.notifications.email,
          'chat': user.settings.notifications.chat,
          'spaces': user.settings.notifications.spaces,
          'courses': user.settings.notifications.courses,
        },
        'appearance': {
          'theme': user.settings.appearance.theme,
          'language': user.settings.appearance.language,
          'fontSize': user.settings.appearance.fontSize,
        },
        'twoFactorAuth': {
          'enabled': user.settings.twoFactorAuth.enabled,
          'method': user.settings.twoFactorAuth.method,
          'verified': user.settings.twoFactorAuth.verified,
        },
      },
      'referrals': {
        'referredUsers': user.referrals.referredUsers,
      },
      'subscription': {
        'status': user.subscription.status,
      },
      'currentStreak': user.currentStreak,
      'maxStreak': user.maxStreak,
      'loginHistory': user.loginHistory,
      'isDeleted': user.isDeleted,
      'createdAt': user.createdAt,
      'updatedAt': user.updatedAt,
      '__v': user.v,
      'lastLogin': user.lastLogin,
    };
  }
}
