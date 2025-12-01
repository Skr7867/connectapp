import 'package:get/get.dart';
import '../../../models/UserLogin/user_login_model.dart';
import '../userPreferences/user_preferences_screen.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  final RxString id = ''.obs;
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final Rx<AvatarModel> avatar = AvatarModel(
    id: '',
    name: '',
    imageUrl: '',
    isActive: true,
    v: 0,
  ).obs;
  final RxList<String> interests = <String>[].obs;
  final RxList<String> enrolledCourses = <String>[].obs;
  final RxString role = ''.obs;
  final RxInt xp = 0.obs;
  final RxInt level = 0.obs;
  final RxList<String> badges = <String>[].obs;
  final Rx<SettingsModel> settings = SettingsModel(
    notifications: NotificationsModel(
      push: true,
      email: true,
      chat: true,
      spaces: true,
      courses: true,
    ),
    appearance: AppearanceModel(
      theme: 'light',
      language: 'en',
      fontSize: 'medium',
    ),
    twoFactorAuth: TwoFactorAuthModel(
      enabled: false,
      method: 'authenticator',
      verified: false,
    ),
  ).obs;
  final Rx<ReferralsModel> referrals = ReferralsModel(referredUsers: []).obs;
  // final Rx<SubscriptionModel> subscription =
  //     SubscriptionModel(status: 'Inactive').obs;
  final RxInt currentStreak = 0.obs;
  final RxInt maxStreak = 0.obs;
  final RxList<String> loginHistory = <String>[].obs;
  final RxBool isDeleted = false.obs;
  final RxString createdAt = ''.obs;
  final RxString updatedAt = ''.obs;
  final RxInt v = 0.obs;
  final RxString lastLogin = ''.obs;

  // Instance of UserPreferencesViewmodel
  final userPref = UserPreferencesViewmodel();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // Fetch all user data and update reactive variables
  Future<void> loadUserData() async {
    final userData = await userPref.getUser();
    if (userData != null) {
      final user = userData.user;
      id.value = user.id;
      fullName.value = user.fullName;
      email.value = user.email;
      avatar.value = user.avatar;
      interests.assignAll(user.interests);
      enrolledCourses.assignAll(user.enrolledCourses);
      role.value = user.role;
      xp.value = user.xp;
      level.value = user.level;
      // badges.assignAll(user.badges);
      settings.value = user.settings;
      referrals.value = user.referrals;
      // subscription.value = user.subscription;
      currentStreak.value = user.currentStreak;
      maxStreak.value = user.maxStreak;
      loginHistory.assignAll(user.loginHistory);
      isDeleted.value = user.isDeleted;
      createdAt.value = user.createdAt;
      updatedAt.value = user.updatedAt;
      v.value = user.v;
      lastLogin.value = user.lastLogin;
    } else {
      fullName.value = 'Guest';
      email.value = 'noEmail';
    }
  }
}
