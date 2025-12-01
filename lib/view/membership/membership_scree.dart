import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/controller/allsubscriptionplan/plan_purchase_controller.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/response/status.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/controller/allsubscriptionplan/all_subscription_plan_controller.dart';
import 'buy_plan_button.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final AllSubscriptionPlanController membershipPlan =
        Get.put(AllSubscriptionPlanController());
    Get.put(PlanPurchaseController());
    final membershipController = Get.put(UserProfileController());
    String? endDateStr =
        membershipController.userList.value.subscription!.endDate;

    String formattedDate = '';

    if (endDateStr != null && endDateStr.isNotEmpty) {
      DateTime parsedDate = DateTime.parse(endDateStr);
      formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    }
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'Membership & Subscription',
      ),
      body: Container(
        height: screenHeight,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Membership & Subscription
                Center(
                  child: Text(
                    "Current Plan",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Current Plan Box
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 60),
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.crown,
                            color: const Color.fromARGB(255, 235, 159, 45),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Current Plans',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            padding: ResponsivePadding.symmetricPadding(context,
                                horizontal: 2, vertical: 0.2),
                            decoration: BoxDecoration(
                              color: AppColors.greenColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              membershipController
                                  .userList.value.subscription!.status
                                  .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Active Plan : ',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 16,
                            ),
                          ),
                          (membershipController
                                          .userList
                                          .value
                                          .subscriptionFeatures
                                          ?.premiumIconUrl !=
                                      null &&
                                  membershipController
                                      .userList
                                      .value
                                      .subscriptionFeatures!
                                      .premiumIconUrl!
                                      .isNotEmpty)
                              ? Image.network(
                                  membershipController.userList.value
                                      .subscriptionFeatures!.premiumIconUrl!,
                                  width: screenWidth * 0.05,
                                  height: screenHeight * 0.02,
                                  fit: BoxFit.cover,
                                )
                              : Text(
                                  "No Active Plan",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.opensansRegular,
                                    fontSize: 13,
                                  ),
                                )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (formattedDate.isNotEmpty)
                            ? 'Renewal date : $formattedDate'
                            : 'Renewal Date : No active plan',
                        style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                //****************************************Your Plan feature container**************************** */
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greenColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.greenColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.crown,
                                color: AppColors.whiteColor, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              "My Plan",
                              style: TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.crown,
                            color: AppColors.greenColor,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Premium Plan",
                            style: TextStyle(
                              fontFamily: AppFonts.helveticaBold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [],
                      ),

                      // Features Title
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.sprayCanSparkles,
                            color: const Color.fromARGB(255, 235, 159, 45),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Features",
                            style: TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      //  Dynamic Features List
                      if (membershipController
                              .userList.value.subscriptionFeatures !=
                          null) ...[
                        _buildFeatureRowtext(
                          "Reaction Emojis",
                          membershipController.userList.value
                              .subscriptionFeatures!.reactionEmoji
                              .toString(),
                          context,
                        ),
                        _buildFeatureRowtext(
                          "Sticker Packs",
                          membershipController
                              .userList.value.subscriptionFeatures!.stickerPack
                              .toString(),
                          context,
                        ),
                        _buildFeatureRowtext(
                          "Public Groups",
                          membershipController
                              .userList.value.subscriptionFeatures!.publicGroup
                              .toString(),
                          context,
                        ),
                        _buildFeatureRowtext(
                          "File Upload Size",
                          "${membershipController.userList.value.subscriptionFeatures!.fileUploadSize} MB",
                          context,
                        ),
                        _buildFeatureRow(
                          "Animated Avatar",
                          membershipController.userList.value
                                  .subscriptionFeatures!.animatedAvatar ==
                              true,
                          context,
                        ),
                        _buildFeatureRow(
                          "Premium Icon",
                          membershipController.userList.value
                                  .subscriptionFeatures!.premiumIcon ==
                              true,
                          context,
                        ),
                        _buildFeatureRow(
                          "Shared Live Location",
                          membershipController.userList.value
                                  .subscriptionFeatures!.sharedLiveLocation ==
                              true,
                          context,
                        ),
                      ],

                      const SizedBox(height: 20),

                      //  Active Plan Button
                      SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Active Plan",
                            style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // *************************************************Available Plans************************************//

                SizedBox(height: screenHeight * 0.03),
                Text(
                  "Available Plans",
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),

                /// Dynamic Plans from API
                Obx(() {
                  if (membershipPlan.rxRequestStatus.value == Status.LOADING) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (membershipPlan.rxRequestStatus.value == Status.ERROR) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            membershipPlan.error.value,
                            style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => membershipPlan.refreshApi(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (membershipPlan.userList.value == null ||
                      membershipPlan.userList.value!.data == null ||
                      membershipPlan.userList.value!.data!.isEmpty) {
                    return const Center(child: Text('No plans available'));
                  }

                  // Filter plans to show only those with membershipType: "User"
                  final userPlans = membershipPlan.userList.value!.data!
                      .asMap()
                      .entries
                      .where((entry) => entry.value.membershipType == "User")
                      .toList();

                  if (userPlans.isEmpty) {
                    return Center(
                        child: Text(
                      'No user plans available',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ));
                  }

                  return Column(
                    children: userPlans.map((entry) {
                      final index = entry.key;
                      final plan = entry.value;
                      final planId = plan.sId ?? 'unknown_$index';
                      final coinsRequired = plan.coins ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: plan.isPopular == true
                                  ? Colors.amber
                                  : Colors.deepPurple,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    plan.name ?? 'Unknown Plan',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.opensansRegular,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.06),
                                  if (plan.isPopular == true)
                                    Container(
                                      padding:
                                          ResponsivePadding.symmetricPadding(
                                              context,
                                              horizontal: 2,
                                              vertical: 0.2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Popular",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppFonts.opensansRegular,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    plan.coins != null
                                        ? "${plan.coins!}"
                                        : "Unknown Price",
                                    style: TextStyle(
                                      fontFamily: AppFonts.helveticaMedium,
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  Image.asset(
                                    ImageAssets.coins,
                                    height: 20,
                                  ),
                                ],
                              ),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                      color: Colors.yellow.withOpacity(0.4)),
                                  child: Text(
                                    plan.duration ?? 'Unknown Duration',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontFamily: AppFonts.opensansRegular,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.sprayCanSparkles,
                                    color:
                                        const Color.fromARGB(255, 235, 159, 45),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Features',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        fontFamily: AppFonts.helveticaBold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  )
                                ],
                              ),
                              SizedBox(height: 4),
                              if (plan.features != null) ...[
                                _buildFeatureRowtext(
                                  "Reaction Emojis",
                                  plan.features!.reactionEmoji?.toString() ??
                                      '0',
                                  context,
                                ),
                                _buildFeatureRowtext(
                                  "Sticker Packs",
                                  plan.features!.stickerPack?.toString() ?? '0',
                                  context,
                                ),
                                _buildFeatureRowtext(
                                  "Public Groups",
                                  plan.features!.publicGroup?.toString() ?? '0',
                                  context,
                                ),
                                _buildFeatureRow(
                                  "Animated Avatar",
                                  plan.features!.animatedAvatar == true,
                                  context,
                                ),
                                _buildFeatureRow(
                                  "Premium Icon",
                                  plan.features!.premiumIcon == true,
                                  context,
                                ),
                                _buildFeatureRow(
                                  "Shared Live Location",
                                  plan.features!.sharedLiveLocation == true,
                                  context,
                                ),
                                _buildFeatureRowtext(
                                  "File Upload Size",
                                  "${plan.features!.fileUploadSize ?? 0} MB",
                                  context,
                                ),
                              ],
                              const SizedBox(height: 16),
                              Center(
                                  child: BuyPlanButton(
                                planId: planId,
                                coinsRequired: coinsRequired,
                              )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    String title,
    bool isEnabled,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(
            Icons.check_box,
            color: Colors.green,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isEnabled ? Icons.check_box : Icons.close,
            color: isEnabled ? Colors.green : Colors.red,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRowtext(
      String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(
            Icons.check_box,
            color: Colors.green,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "$title: $value",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
        ],
      ),
    );
  }
}
