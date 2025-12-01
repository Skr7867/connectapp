import 'package:connectapp/data/response/status.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view/membership/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/controller/allsubscriptionplan/buy_coins_controller.dart';
import '../../view_models/controller/profile/user_profile_controller.dart';

class BuyCoinsScreen extends StatelessWidget {
  const BuyCoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userCoins = Get.find<UserProfileController>();
    final BuyCoinsController controller = Get.put(BuyCoinsController());
    final PaymentController paymentController = Get.put(PaymentController());
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Coins Packages',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteName.walletScreen);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.whiteColor),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wallet,
                            color: AppColors.whiteColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Your Current Balance: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                                color: AppColors.whiteColor),
                          ),
                          Obx(() {
                            switch (userCoins.rxRequestStatus.value) {
                              case Status.LOADING:
                                return Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: AppFonts.opensansRegular,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                );
                              case Status.ERROR:
                                return const Text(
                                  'No Coins',
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                );
                              case Status.COMPLETED:
                                return Text(
                                  '${userCoins.userList.value.wallet!.coins.toString()} coins',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontFamily: AppFonts.opensansRegular,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteColor,
                                  ),
                                );
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.rxRequestStatus.value == Status.LOADING) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (controller.rxRequestStatus.value == Status.ERROR) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            controller.error.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: controller.fetchCoinsPackages,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          controller.coinsPackages.value.packages?.length ?? 0,
                      itemBuilder: (context, index) {
                        final package =
                            controller.coinsPackages.value.packages![index];
                        return Column(
                          children: [
                            CoinPackageCard(
                              title: package.title ?? 'Unknown Package',
                              coins: package.coins ?? 0,
                              description:
                                  package.description ?? 'No description',
                              price: package.price ?? 0.0,
                              isActive: package.isActive ?? false,
                              onGetNow: () {
                                paymentController.makePayment(
                                  packageId: package.sId!,
                                  amount: package.price!,
                                  currency: 'usd',
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    );
                  }
                }),
                Container(
                  height: orientation == Orientation.portrait
                      ? screenHeight * 0.33
                      : screenHeight * 0.5,
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.greyColor),
                  ),
                  child: Padding(
                    padding: ResponsivePadding.customPadding(context,
                        left: 3, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What can you do with coins?',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          '✭ Unlock premium content and courses',
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          '✭ Get exclusive avatars and rewards',
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          '✭ Access members-only communities',
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          '✭ Early access to new features',
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          '✭ Special discounts on future purchases',
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: controller.refreshCoinsPackages,
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}

class CoinPackageCard extends StatelessWidget {
  final String title;
  final int coins;
  final String description;
  final double price;
  final bool isActive;
  final VoidCallback onGetNow;

  const CoinPackageCard({
    super.key,
    required this.title,
    required this.coins,
    required this.description,
    required this.price,
    required this.isActive,
    required this.onGetNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text(isActive ? "ACTIVE" : "INACTIVE"),
                backgroundColor: isActive ? Colors.blueAccent : Colors.grey,
                labelStyle: const TextStyle(
                    color: Colors.white, fontFamily: AppFonts.opensansRegular),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "BEST VALUE",
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular),
          ),
          Text(
            '$coins coins',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontFamily: AppFonts.opensansRegular),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontFamily: AppFonts.opensansRegular),
          ),
          const SizedBox(height: 10),
          Text(
            '⚡ Only \$${price.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isActive ? onGetNow : null,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  overlayColor: AppColors.buttonColor),
              child: const Text(
                "→ Add Coins ",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
