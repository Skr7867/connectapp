class ApiUrls {
  static const String baseUrl = 'https://api.connectapp.cc';

  // static const String baseUrl = 'https://connect-backend-qn87.onrender.com';

  static const String signupApi = '$baseUrl/connect/v1/api/user/register';

  static const String allAvatarApi =
      '$baseUrl/connect/v1/api/user/get-all-avatars';

  static const String unreadCountApi =
      '$baseUrl/connect/v1/api/chat/get-all-private-chats';
  static const String translateTextApi =
      '$baseUrl/connect/v1/api/social/translate-text';
  static const String groupUnreadCountApi =
      '$baseUrl/connect/v1/api/creator/course/get-my-chat-groups';

  static const String loginApi = '$baseUrl/connect/v1/api/user/login';

  static const String userProfileApi = '$baseUrl/connect/v1/api/user/profile';

  static const String leaderBoardApi =
      '$baseUrl/connect/v1/api/user/leaderboard';

  static const String chatListApi =
      '$baseUrl/connect/v1/api/chat/get-all-private-chats';

  static const String logoutApi = '$baseUrl/connect/v1/api/user/logout';

  static const String allCoursesApi =
      '$baseUrl/connect/v1/api/course-data/get-all-course';

  static const String allSubscriptionPlanApi =
      '$baseUrl/connect/v1/api/admin/subscription/get-all';
  static const String enrolledCoursesApi =
      '$baseUrl/connect/v1/api/user/course/get-all-enrolled-courses';

  static const String courseProgressApi =
      '$baseUrl/connect/v1/api/user/course/progress';

  static const String allSpacesApi =
      '$baseUrl/connect/v1/api/space/get-all-upcoming-space';
  static const String enrollSpaceApi = '$baseUrl/connect/v1/api/space/enroll';

  static const String joinSpaceApi = '$baseUrl/connect/v1/api/space/join';

  static const String notificationApi =
      '$baseUrl/connect/v1/api/user/get-all-notifications';
  static const String allFollowersApi =
      '$baseUrl/connect/v1/api/social/get-all-followers';
  static const String allFollowingApi =
      '$baseUrl/connect/v1/api/social/get-all-following';
  static const String deleteChatListApi =
      '$baseUrl/connect/v1/api/chat/clear-chat';

  static const String buyCoinsApi =
      '$baseUrl/connect/v1/api/admin/coin-package/get-active-packages';

  static const String transactionApi =
      '$baseUrl/connect/v1/api/transaction/user-transactions';

  static const String coinsTransactionApi =
      '$baseUrl/connect/v1/api/transaction/get-user-coin-transactions';

  static const String showQrApi =
      '$baseUrl/connect/v1/api/user/2fa/authenticator/setup';
  static const String sendOtpApi =
      '$baseUrl/connect/v1/api/user/forgot-password';

  static const String verifyOtpApi =
      '$baseUrl/connect/v1/api/user/verify-reset-otp';

  static const String resetPasswordApi =
      '$baseUrl/connect/v1/api/user/reset-password';

  static const String userAvatarApi =
      '$baseUrl/connect/v1/api/user/get-user-avatars';

  static const String updateProfileAPi =
      '$baseUrl/connect/v1/api/user/update-user-profile';

  static const String verifyUpdateEmailPassword =
      '$baseUrl/connect/v1/api/user/verify-password';
  static const String validateNewEmail =
      '$baseUrl/connect/v1/api/user/validate-new-email';
  static const String verifyOTPEmail =
      '$baseUrl/connect/v1/api/user/verify-email-otp-and-update-email';

  static const String refferalNetworkApi =
      '$baseUrl/connect/v1/api/user/get-referral-hierarchy';
  static const String allUsersApi =
      '$baseUrl/connect/v1/api/user/show-all-users';
  static const String userSocialProfileApi =
      '$baseUrl/connect/v1/api/social/get-user-profile';

  static const String userAllClipsApi =
      '$baseUrl/connect/v1/api/social/clip/user-clips';

  static const String myClipsApi =
      '$baseUrl/connect/v1/api/social/clip/my-clips';

  static const String repostedClipsApi =
      '$baseUrl/connect/v1/api/social/clip/user-reposted-clips';

  static const String getClipsByidApi =
      '$baseUrl/connect/v1/api/social/clip/get-clip-by-id';

  static const String clipRepostedByUser =
      '$baseUrl/connect/v1/api/social/clip/reposted-by-user';

  static const String inventoryAvatarApi =
      '$baseUrl/connect/v1/api/custom-avatar/get-my-inventory';
  static const String createAvatarApi =
      '$baseUrl/connect/v1/api/custom-avatar/create-avatar';

  static const String deleteAvatarApi =
      '$baseUrl/connect/v1/api/custom-avatar/delete-avatar';

  static const String updateAvatarApi =
      '$baseUrl/connect/v1/api/custom-avatar/update-avatar';
  static const String setAvatarOnMarketplaceApi =
      '$baseUrl/connect/v1/api/custom-avatar/set-avatar-on-marketplace';

  static const String marketPlaceAvatarApi =
      '$baseUrl/connect/v1/api/custom-avatar/marketplace-items';

  static const String purchaseAvatarFromMarketPlaceApi =
      '$baseUrl/connect/v1/api/custom-avatar/purchase-custom-avatar';

  static const String purchaseAvatarCollectionApi =
      '$baseUrl/connect/v1/api/custom-avatar/purchase-avatar-collection';

  static const String createNewAvatarsCollectionApi =
      '$baseUrl/connect/v1/api/custom-avatar/create-collection';

  static const String editAvatarsCollectionApi =
      '$baseUrl/connect/v1/api/custom-avatar/update-collection';

  static const String deleteAvatarsCollectionApi =
      '$baseUrl/connect/v1/api/custom-avatar/delete-collection';
  static const String deleteAvatarsCommentApi =
      '$baseUrl/connect/v1/api/social/clip/comment/delete';

  static const String popularCourseApi =
      '$baseUrl/connect/v1/api/user/get-top-courses';

  static const String topReviewApi =
      '$baseUrl/connect/v1/api/user/get-random-top-reviews';
  static const String getCourseById =
      '$baseUrl/connect/v1/api/course-data/get-course-by-id';

  static const String enrollInNewCourseApi =
      '$baseUrl/connect/v1/api/user/course/enroll-course';

  static const String searchCourseApi =
      '$baseUrl/connect/v1/api/user/search-courses?q=';
  static const String topCreatorCourses =
      '$baseUrl/connect/v1/api/user/get-top-creators';
  static const String pendingFollowRequestApi =
      '$baseUrl/connect/v1/api/social/get-pending-follow-requests';
  static const String acceptFollowRequestApi =
      '$baseUrl/connect/v1/api/social/respond-follow-request/';

  //*************************************************from here all api for creator panel*******************************/

  static const String creatorProfileApi =
      '$baseUrl/connect/v1/api/creator/profile';
  static const String createSpaceApi = '$baseUrl/connect/v1/api/space/create';
  static const String fetchCreatorSpaceApi =
      '$baseUrl/connect/v1/api/space/get-creator-space';
  static const String startMeetingsApi = '$baseUrl/connect/v1/api/space/start';

  static const String endMeetingsApi = '$baseUrl/connect/v1/api/space/end';

  static const String deleteMeetingsApi =
      '$baseUrl/connect/v1/api/space/delete';

  static const String getAllCreatorCourses =
      '$baseUrl/connect/v1/api/creator/course/my-courses';

  static const createCourseGroupApi =
      '$baseUrl/connect/v1/api/creator/course/create-course-group';

  static const createCourseApi =
      '$baseUrl/connect/v1/api/creator/course/create-course-request';

  static const editCourseApi =
      '$baseUrl/connect/v1/api/creator/course/update-course';

  static const getCourseSectionApi =
      '$baseUrl/connect/v1/api/course-data/get-course-by-id';

  static const createCourseSectionApi =
      '$baseUrl/connect/v1/api/creator/course/create-section';
}
