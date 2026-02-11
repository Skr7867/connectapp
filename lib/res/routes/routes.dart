import 'package:connectapp/view/CREATORPANEL/AddLession/add_lession_screen.dart';
import 'package:connectapp/view/CREATORPANEL/CreateCourseScreen/create_course_screen.dart';
import 'package:connectapp/view/CREATORPANEL/CreateCourseSection/create_course_section_screen.dart';
import 'package:connectapp/view/CREATORPANEL/CreatorCourses/creator_course_screen.dart';
import 'package:connectapp/view/CREATORPANEL/CreatorMembership/creator_membership_screen.dart';
import 'package:connectapp/view/CREATORPANEL/EditCourse/edit_course_screen.dart';
import 'package:connectapp/view/CREATORPANEL/HomeScreen/creator_home_screen.dart';
import 'package:connectapp/view/CREATORPANEL/creatorbottomnavbar/creator_bottom_nav_bar.dart';
import 'package:connectapp/view/Q&A%20Session/quiz_screen.dart';
import 'package:connectapp/view/allAvatars/all_avatars_screen.dart';
import 'package:connectapp/view/allAvatars/user_avatar_screen.dart';
import 'package:connectapp/view/allusers/all_users_screen.dart';
import 'package:connectapp/view/auth/login_authenticator.dart';
import 'package:connectapp/view/auth/login_screen.dart';
import 'package:connectapp/view/auth/otp_verification_screen.dart';
import 'package:connectapp/view/auth/set_password_screen.dart';
import 'package:connectapp/view/auth/signup_screen.dart';
import 'package:connectapp/view/clip/screens/reel_upload_screen.dart';
import 'package:connectapp/view/courses/contentOfLession/content_lession.dart';
import 'package:connectapp/view/courses/course_video_screen.dart';
import 'package:connectapp/view/courses/new_course_design_screen.dart';
import 'package:connectapp/view/courses/popular_courses_screen.dart';
import 'package:connectapp/view/courses/view_details_of_courses.dart';
import 'package:connectapp/view/createNewCollectionOfAvatars/create_new_collection_avatars_screen.dart';
import 'package:connectapp/view/crypto/crypto_screen.dart';
import 'package:connectapp/view/enrolledcourses/enrolled_courses_screen.dart';
import 'package:connectapp/view/forgetpassword/create_new_password_screen.dart';
import 'package:connectapp/view/forgetpassword/forget_password_otp_verification.dart';
import 'package:connectapp/view/forgetpassword/forget_password_screen.dart';
import 'package:connectapp/view/game/game_screen.dart';
import 'package:connectapp/view/help&Support/contact_us_screen.dart';
import 'package:connectapp/view/help&Support/privacy_policy_screen.dart';
import 'package:connectapp/view/help&Support/report_an_issue_screen.dart';
import 'package:connectapp/view/help&Support/terms_and_condition_screen.dart';
import 'package:connectapp/view/inventoryAvatar/inventory_avatar_screen.dart';
import 'package:connectapp/view/language/language_screen.dart';
import 'package:connectapp/view/membership/buy_coins_screen.dart';
import 'package:connectapp/view/membership/membership_scree.dart';
import 'package:connectapp/view/message/chat_profile.dart';
import 'package:connectapp/view/message/chat_screen.dart';
import 'package:connectapp/view/myAvatarCollection/my_avatar_collection_screen.dart';
import 'package:connectapp/view/myMarketPlaceAvatar/my_market_place_avatar_screen.dart';
import 'package:connectapp/view/networkWrapper/network_base_page.dart';
import 'package:connectapp/view/notification/notification_screen.dart';
import 'package:connectapp/view/pendingFollowRequest/pending_follow_request_screen.dart';
import 'package:connectapp/view/settings/2FA/qr_code_screen.dart';
import 'package:connectapp/view/settings/2FA/two_factor_auth_screen.dart';
import 'package:connectapp/view/settings/2FA/two_factor_disable_screen.dart';
import 'package:connectapp/view/settings/change_pasword_screen.dart';
import 'package:connectapp/view/settings/settings_screen.dart';
import 'package:connectapp/view/spaces/join_meeting_screen.dart';
import 'package:connectapp/view/spaces/meeting_details_screen.dart';
import 'package:connectapp/view/spaces/new_meetings_screen.dart';
import 'package:connectapp/view/spaces/spaces_screen.dart';
import 'package:connectapp/view/userSelfProfile/edit_profile_screen.dart';
import 'package:connectapp/view/userSelfProfile/editemail/enter_password.dart';
import 'package:connectapp/view/userSelfProfile/user_profile_screen.dart';
import 'package:connectapp/view/userSelfProfile/widgets/clip_play_screen.dart';
import 'package:connectapp/view/userSelfProfile/widgets/full_profile_screen.dart';
import 'package:connectapp/view/wallet/wallet_screen.dart';
import 'package:get/get.dart';
import '../../view/CREATORPANEL/CourseManagement/course_management_screen.dart';
import '../../view/allFollowers/all_followers_screen.dart';
import '../../view/bottomnavbar/bottom_navigation_bar.dart';
import '../../view/createavatar/avatar_creator_screen.dart';
import '../../view/homescreen/home_screen.dart';
import '../../view/homescreen/streakExplore/streak_explore_screen.dart';
import '../../view/refferalNetworkScreen/Refferal_network_screen.dart';
import '../../view/settings/2FA/authenticator_verification_screen.dart';
import '../../view/settings/2FA/security_setting_screen.dart';
import '../../view/settings/2FA/two_factor_setup_screen.dart';
import '../../view/spaces/creator_meeting_details_screen.dart';
import '../../view/splashscreen/splash_screen.dart';
import '../../view/usersocialprofile/user_social_profile_screen.dart';
import 'routes_name.dart';

class AppRoutes {
  static appRoutes() => [
        GetPage(
          name: RouteName.splashScreen,
          page: () => NetworkBasePage(child: SplashScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.homeScreen,
          page: () => NetworkBasePage(child: HomeScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.notificationScreen,
          page: () => NetworkBasePage(child: NotificationScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.settingScreen,
          page: () => NetworkBasePage(child: SettingsScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.messageScreen,
          page: () => NetworkBasePage(child: ChatScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.bottomNavbar,
          page: () => NetworkBasePage(child: BottomnavBar()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.chatscreen,
          page: () => NetworkBasePage(child: ChatScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.chatProfileScreen,
          page: () => NetworkBasePage(child: ChatProfileScreen()),
          transitionDuration: Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.editProfileScreen,
          page: () => NetworkBasePage(child: EditProfileScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.courseVideoScreen,
          page: () => NetworkBasePage(child: CourseVideoScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.membershipPlan,
          page: () => NetworkBasePage(child: MembershipScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.profileScreen,
          page: () => NetworkBasePage(child: UserProfileScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.newMeetingScreen,
          page: () => NetworkBasePage(child: SpacesScreen()),
          transitionDuration: Duration(microseconds: 500),
        ),
        GetPage(
          name: RouteName.meetingDetailScreen,
          page: () => NetworkBasePage(child: MeetingDetailsScreen()),
        ),
        GetPage(
          name: RouteName.joinMeeting,
          page: () => NetworkBasePage(child: JoinMeetingScreen()),
        ),
        GetPage(
          name: RouteName.loginScreen,
          page: () => NetworkBasePage(child: LoginScreen()),
        ),
        GetPage(
          name: RouteName.loginAuthenticator,
          page: () => LoginAuthenticator(),
        ),
        GetPage(
          name: RouteName.signupScreen,
          page: () => NetworkBasePage(child: SignupScreen()),
        ),
        GetPage(
          name: RouteName.otpVerification,
          page: () => NetworkBasePage(child: OtpVerificationScreen()),
        ),
        GetPage(
          name: RouteName.forgetPassword,
          page: () => NetworkBasePage(child: ForgetPasswordScreen()),
        ),
        GetPage(
          name: RouteName.forgetPasswordOtpVerification,
          page: () => NetworkBasePage(child: ForgetPasswordOtpVerification()),
        ),
        GetPage(
          name: RouteName.createNewPassword,
          page: () => NetworkBasePage(child: CreateNewPasswordScreen()),
        ),
        GetPage(
          name: RouteName.privacyPolicy,
          page: () => NetworkBasePage(child: PrivacyPolicyScreen()),
        ),
        GetPage(
          name: RouteName.termsAndCondition,
          page: () => NetworkBasePage(child: TermsAndConditionScreen()),
        ),
        GetPage(
          name: RouteName.contactUsScreen,
          page: () => NetworkBasePage(child: ContactUsScreen()),
        ),
        GetPage(
          name: RouteName.reportAndIssue,
          page: () => NetworkBasePage(child: ReportAnIssueScreen()),
        ),
        GetPage(
          name: RouteName.languageScreen,
          page: () => NetworkBasePage(child: LanguageScreen()),
        ),
        GetPage(
          name: RouteName.changePassword,
          page: () => NetworkBasePage(child: ChangePaswordScreen()),
        ),
        GetPage(
          name: RouteName.quizScreen,
          page: () => NetworkBasePage(child: QuizScreen()),
        ),
        GetPage(
          name: RouteName.streakExploreScreen,
          page: () => NetworkBasePage(child: StreakExploreScreen()),
        ),
        GetPage(
          name: RouteName.contentLession,
          page: () => NetworkBasePage(child: ContentLessonScreen()),
        ),
        GetPage(
          name: RouteName.enrolledCourses,
          page: () => NetworkBasePage(child: EnrolledCoursesScreen()),
        ),
        GetPage(
          name: RouteName.buyCoinsScreen,
          page: () => NetworkBasePage(child: BuyCoinsScreen()),
        ),
        GetPage(
          name: RouteName.walletScreen,
          page: () => NetworkBasePage(child: WalletScreen()),
        ),
        GetPage(
          name: RouteName.securitySettingScreen,
          page: () => NetworkBasePage(child: SecuritySettingScreen()),
        ),
        GetPage(
          name: RouteName.twoFactorSetupScreen,
          page: () => NetworkBasePage(child: TwoFactorSetupScreen()),
        ),
        GetPage(
          name: RouteName.twoFactorAuthScreen,
          page: () => NetworkBasePage(child: TwoFactorAuthScreen()),
        ),
        GetPage(
          name: RouteName.authenticatorVerification,
          page: () => NetworkBasePage(child: AuthenticatorVerificationScreen()),
        ),
        GetPage(
          name: RouteName.qrCodeScreen,
          page: () => NetworkBasePage(child: QrCodeScreen()),
        ),
        GetPage(
          name: RouteName.reelsScreen,
          page: () => NetworkBasePage(child: ReelsPage()),
        ),
        GetPage(
          name: RouteName.disableTwoFa,
          page: () => NetworkBasePage(child: TwoFactorDisableScreen()),
        ),
        GetPage(
          name: RouteName.allAvatarsScreen,
          page: () => NetworkBasePage(child: AllAvatarsScreen()),
        ),
        GetPage(
          name: RouteName.usersAvatarScreen,
          page: () => NetworkBasePage(child: UserAvatarScreen()),
        ),
        GetPage(
          name: RouteName.updatEmailPassword,
          page: () => NetworkBasePage(child: EnterPassword()),
        ),
        GetPage(
          name: RouteName.setPasswordScreen,
          page: () => NetworkBasePage(child: SetPasswordScreen()),
        ),
        GetPage(
          name: RouteName.cryptoScreen,
          page: () => NetworkBasePage(child: CryptoScreen()),
        ),
        GetPage(
          name: RouteName.gamesScreen,
          page: () => NetworkBasePage(child: GameScreen()),
        ),
        GetPage(
          name: RouteName.avatarCreatorScreen,
          page: () => NetworkBasePage(child: AvatarCreatorScreen()),
          // page: () => AvatarStudio(),
        ),
        GetPage(
          name: RouteName.clipProfieScreen,
          page: () => NetworkBasePage(child: UserSocialProfileScreen()),
        ),
        GetPage(
          name: RouteName.allUsersScreen,
          page: () => NetworkBasePage(child: AllUsersScreen()),
        ),
        GetPage(
          name: RouteName.clipPlayScreen,
          page: () => NetworkBasePage(child: ClipPlayScreen()),
        ),

        GetPage(
          name: RouteName.inventoryAvatarScreen,
          page: () => NetworkBasePage(child: InventoryAvatarScreen()),
        ),
        GetPage(
          name: RouteName.myAvatarCollection,
          page: () => NetworkBasePage(child: MyAvatarCollectionScreen()),
        ),
        GetPage(
          name: RouteName.myMarketPlaceAvatar,
          page: () => NetworkBasePage(child: MyMarketPlaceAvatarScreen()),
        ),
        GetPage(
          name: RouteName.createNewAvatarsCollectionScreen,
          page: () =>
              NetworkBasePage(child: CreateNewCollectionAvatarsScreen()),
        ),
        GetPage(
          name: RouteName.creatorMettingsDetailsScreen,
          page: () => NetworkBasePage(child: CreatorMeetingDetailsScreen()),
        ),
        GetPage(
          name: RouteName.newCourseScreen,
          page: () => NetworkBasePage(child: NewCourseDesignScreen()),
        ),
        GetPage(
          name: RouteName.popularCoursesScreen,
          page: () => NetworkBasePage(child: PopularCoursesScreen()),
        ),
        GetPage(
          name: RouteName.viewDetailsOfCourses,
          page: () => NetworkBasePage(child: ViewDetailsOfCourses()),
        ),

        GetPage(
          name: RouteName.reelsPage,
          page: () => NetworkBasePage(child: ReelsPage()),
        ),
        GetPage(
          name: RouteName.allFollowersScreen,
          page: () => NetworkBasePage(child: FollowersFollowingScreen()),
        ),
        GetPage(
          name: RouteName.pendingFollowRequestScreen,
          page: () => NetworkBasePage(child: PendingFollowRequestScreen()),
        ),
        GetPage(
          name: RouteName.fullProfileScreen,
          page: () => NetworkBasePage(child: FullProfileScreen()),
        ),

        //************************************from here all routes for the creator panel********** */
        GetPage(
          name: RouteName.creatorHomeScreen,
          page: () => NetworkBasePage(child: CreatorHomeScreen()),
        ),

        GetPage(
          name: RouteName.creatorBottomBar,
          page: () => NetworkBasePage(child: CreatorBottomNavBar()),
        ),
        GetPage(
          name: RouteName.creatorCourses,
          page: () => NetworkBasePage(child: CreatorCourseScreen()),
        ),
        GetPage(
          name: RouteName.createSpaceScreen,
          page: () => NetworkBasePage(child: NewMeetingScreen()),
        ),
        GetPage(
          name: RouteName.createCourseScreen,
          page: () => NetworkBasePage(child: CreateCourseScreen()),
        ),
        GetPage(
          name: RouteName.creatorCourseManagementScreen,
          page: () => NetworkBasePage(child: CourseManagementScreen()),
        ),
        GetPage(
          name: RouteName.createCourseSectionScreen,
          page: () => CreateCourseSectionScreen(),
        ),

        GetPage(
          name: RouteName.editCourseScreen,
          page: () => NetworkBasePage(child: EditCourseScreen()),
        ),
        GetPage(
          name: RouteName.addLessionScreen,
          page: () => NetworkBasePage(child: AddLessonScreen()),
        ),

        GetPage(
          name: RouteName.treeScreen,
          page: () => NetworkBasePage(child: ReferralNetworkScreen()),
        ),
        GetPage(
          name: RouteName.creatorMembershipScreen,
          page: () => NetworkBasePage(child: CreatorMembershipScreen()),
        ),
      ];
}
