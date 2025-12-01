import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/response/status.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/controller/allusers/all_users_controller.dart';
import '../../view_models/controller/searchUser/search_user_controller.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AllUsersController controller = Get.put(AllUsersController());
    final SearchUsersController searchUsersController =
        Get.put(SearchUsersController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Explore Community',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Search box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
                      cursorHeight: 25,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          searchUsersController.searchUsers(value);
                        } else {
                          searchUsersController.users.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Search user by name, username ...",
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Users List
            Expanded(
              child: Obx(() {
                if (searchUsersController.isLoading.value) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ));
                }

                final isSearching = searchUsersController.users.isNotEmpty;

                final List usersToShow = isSearching
                    ? searchUsersController.users
                    : controller.users;

                if (!isSearching &&
                    controller.rxRequestStatus.value == Status.LOADING) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ));
                }

                if (!isSearching &&
                    controller.rxRequestStatus.value == Status.ERROR) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.error.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => controller.fetchUsers(),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                color: AppColors.whiteColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (usersToShow.isEmpty) {
                  return Center(
                      child: Text(
                    'No users found',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular),
                  ));
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshUsers,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: usersToShow.length,
                    itemBuilder: (context, index) {
                      final user = usersToShow[index];
                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            RouteName.clipProfieScreen,
                            arguments: user.id,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.greyColor),
                          ),
                          child: Row(
                            children: [
                              // Avatar + Level
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: user.avatar?.imageUrl ?? '',
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      radius: 28,
                                      backgroundImage: imageProvider,
                                    ),
                                    placeholder: (context, url) => CircleAvatar(
                                      radius: 28,
                                      backgroundImage: const AssetImage(
                                          ImageAssets.profilePic),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                      radius: 28,
                                      backgroundImage: const AssetImage(
                                          ImageAssets.profilePic),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.deepPurple,
                                      child: Text(
                                        user.level.toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppFonts.helveticaBold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              /// Name, Username & XP
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppFonts.helveticaBold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: user.subscription.status ==
                                                'Inactive'
                                            ? AppColors.greyColor
                                                .withOpacity(0.2)
                                            : AppColors.yellowColor,
                                      ),
                                      child: Text(
                                        user.username != null
                                            ? '@${user.username}'
                                            : '@unknown',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: AppFonts.helveticaBold,
                                          color: user.subscription.status ==
                                                  'Inactive'
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${user.xp ?? 0} XP',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// Coins + Message Icon
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${user.wallet?.coins ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Image.asset(
                                        ImageAssets.coins,
                                        height: 20,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Icon(Icons.chat_bubble_outline,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
