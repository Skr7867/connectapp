import 'package:connectapp/models/UserLogin/user_login_model.dart';



class UserSession {
  // Singleton setup
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // Store the user model
  LoginResponseModel? _user;
  void setUser(LoginResponseModel user) {
    _user = user;
  }

  LoginResponseModel? get user => _user;

  // Get token directly
  String? get token => _user?.token;
  String? get userId => _user!.user.id; // Add more shortcuts as needed
}
