import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';

import 'package:connectapp/view_models/controller/useravatar/user_avatar_controller.dart';

import '../../view_models/controller/userPreferences/user_preferences_screen.dart';

class UserAvatarScreen extends StatelessWidget {
  const UserAvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final UserAvatarController userAvatarController =
        Get.put(UserAvatarController());
    final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Users Avatars',
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final user = await userPreferences.getUser();
          final token = user?.token;
          if (token != null) {
            await userAvatarController.fetchUserAvatars(isRefresh: true);
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
          if (userAvatarController.isLoading.value &&
              userAvatarController.purchasedAvatars.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.buttonColor,
              ),
            );
          }

          if (userAvatarController.errorMessage.value.isNotEmpty &&
              userAvatarController.purchasedAvatars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userAvatarController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final user = await userPreferences.getUser();
                      final token = user?.token;
                      if (token != null) {
                        await userAvatarController.fetchUserAvatars(
                            isRefresh: true);
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

          if (userAvatarController.purchasedAvatars.isEmpty) {
            return const Center(
              child: Text(
                'No purchased avatars found.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: AppFonts.opensansRegular,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: userAvatarController.purchasedAvatars.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final avatar = userAvatarController.purchasedAvatars[index];
              final isCurrentAvatar =
                  userAvatarController.currentAvatar.value?.sId == avatar.sId;

              return GestureDetector(
                onTap: userAvatarController.isUpdating.value
                    ? null
                    : () async {
                        await userAvatarController
                            .updateCurrentAvatar(avatar.sId!);
                      },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: isCurrentAvatar
                        ? Border.all(
                            color: Colors.green,
                          )
                        : Border.all(color: AppColors.greyColor),
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
                                color: isCurrentAvatar
                                    ? Colors.green
                                    : AppColors.greyColor,
                                width: 2,
                              ),
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
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isCurrentAvatar ? 'Current Avatar' : 'Purchased Avatar',
                        style: TextStyle(
                            color: AppColors.greenColor,
                            fontSize: 12,
                            fontFamily: AppFonts.opensansRegular),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${avatar.coins ?? 0} Connect Coins',
                        style: TextStyle(
                            color: AppColors.greenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
