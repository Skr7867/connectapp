import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/view_models/controller/allAvatars/all_avatar_controller.dart';
import 'package:connectapp/view_models/controller/allAvatars/purchase_avatar_controller.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';

import 'package:connectapp/view_models/controller/useravatar/user_avatar_controller.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';

import '../../view_models/controller/userPreferences/user_preferences_screen.dart';

class AllAvatarsScreen extends StatefulWidget {
  const AllAvatarsScreen({super.key});

  @override
  State<AllAvatarsScreen> createState() => _AllAvatarsScreenState();
}

class _AllAvatarsScreenState extends State<AllAvatarsScreen> {
  final AllAvatarController controller = Get.put(AllAvatarController());
  final PurchaseAvatarController purchaseController =
      Get.put(PurchaseAvatarController());
  final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
  final ScrollController _scrollController = ScrollController();
  final userCoins = Get.find<UserProfileController>();
  String? token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await userPreferences.getUser();
      setState(() {
        token = user?.token;
      });
      if (token != null) {
        controller.fetchAvatars(token!, isRefresh: false);
        Get.find<UserAvatarController>().fetchUserAvatars(isRefresh: false);
      } else {
        Get.snackbar(
          'Error',
          'Please log in to view avatars.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!controller.isLoading.value &&
          controller.hasMore.value &&
          token != null) {
        controller.fetchAvatars(token!);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<AllAvatarController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'All Avatars',
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (token != null) {
            await controller.fetchAvatars(token!, isRefresh: false);
            await Get.find<UserAvatarController>()
                .fetchUserAvatars(isRefresh: false);
          } else {
            Get.snackbar(
              'Error',
              'Please log in to refresh avatars.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        child: Obx(() {
          if (controller.isLoading.value && controller.avatars.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.buttonColor,
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.avatars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (token != null) {
                        controller.fetchAvatars(token!, isRefresh: true);
                        Get.find<UserAvatarController>()
                            .fetchUserAvatars(isRefresh: true);
                      } else {
                        Get.snackbar(
                          'Error',
                          'Please log in to retry.',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final activeAvatars = controller.avatars
              .where((avatar) => avatar.isActive == true)
              .toList();

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount:
                activeAvatars.length + (controller.hasMore.value ? 1 : 0),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index >= activeAvatars.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child:
                        CircularProgressIndicator(color: AppColors.buttonColor),
                  ),
                );
              }

              final avatar = activeAvatars[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyColor),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: AppColors.buttonColor, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage: avatar.imageUrl != null
                                ? CachedNetworkImageProvider(avatar.imageUrl!)
                                : null,
                            child: avatar.imageUrl == null
                                ? Image.asset(
                                    ImageAssets.javaIcon,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${avatar.coins ?? 0}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      avatar.name ?? 'Unknown',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: AppFonts.opensansRegular),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      avatar.isActive == true
                          ? 'Premium Avatar'
                          : 'Basic Avatar',
                      style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 12,
                          fontFamily: AppFonts.opensansRegular),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${avatar.coins ?? 0} Connect Coins',
                      style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: AppFonts.opensansRegular),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 3),
                    Obx(() {
                      final isPurchasing = purchaseController
                          .isAvatarPurchasing(avatar.sId.toString());
                      final isPurchased = Get.find<UserAvatarController>()
                          .isAvatarPurchased(avatar.sId.toString());
                      final requiredCoins = avatar.coins ?? 0;

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPurchased ? Colors.grey : Colors.purple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: isPurchasing || isPurchased
                            ? null
                            : () {
                                purchaseController.purchaseAvatar(
                                  avatar.sId.toString(),
                                  requiredCoins,
                                  token,
                                  isPurchased: isPurchased,
                                );
                              },
                        child: Text(
                          isPurchasing
                              ? 'Purchasing...'
                              : isPurchased
                                  ? 'Purchased'
                                  : requiredCoins == 0
                                      ? 'Select'
                                      : 'UNLOCK FOR $requiredCoins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
