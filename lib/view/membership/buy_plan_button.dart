import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../res/fonts/app_fonts.dart';
import '../../view_models/controller/allsubscriptionplan/plan_purchase_controller.dart';
import '../../view_models/controller/profile/user_profile_controller.dart';

class BuyPlanButton extends StatelessWidget {
  final String planId;
  final int coinsRequired;

  const BuyPlanButton({
    super.key,
    required this.planId,
    required this.coinsRequired,
  });

  @override
  Widget build(BuildContext context) {
    final PlanPurchaseController controller =
        Get.find<PlanPurchaseController>();
    final UserProfileController userProfileController =
        Get.find<UserProfileController>();

    return Obx(() {
      final isPaying = controller.isPaying[planId] ?? false;
      final isPurchased = controller.purchasedPlans.contains(planId);
      final hasActiveSubscription =
          userProfileController.userList.value.subscription!.status == 'Active';

      final isDisabled = isPaying || isPurchased || hasActiveSubscription;

      return Tooltip(
        message: isDisabled
            ? (isPurchased
                ? 'Plan already purchased'
                : isPaying
                    ? 'Processing purchase...'
                    : 'You already have an active subscription')
            : 'Purchase this plan',
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled ? Colors.grey : Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 100),
            disabledBackgroundColor: Colors.grey[400],
          ),
          onPressed: isDisabled
              ? null
              : () {
                  controller.processPayment(planId, coinsRequired,
                      isPremiumPlus: false);
                },
          child: isPaying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isPurchased ? "Purchased" : "Choose Plan",
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }
}
