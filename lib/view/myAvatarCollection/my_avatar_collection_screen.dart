import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/view/myAvatarCollection/dialog_box_screen.dart';
import 'package:connectapp/view_models/controller/deleteAvatarsCollection/delete_avatars_collection_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import '../../res/color/app_colors.dart';
import '../../res/component/round_button.dart';
import '../../res/custom_widgets/custome_appbar.dart';
import '../../view_models/controller/inventoryAvatar/inventory_avatar_controller.dart';

class MyAvatarCollectionScreen extends StatelessWidget {
  const MyAvatarCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryAvatarController controller =
        Get.put(InventoryAvatarController());

    final deleteCollection = Get.put(DeleteAvatarsCollectionController());

    controller.fetchInventoryAvatars();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Avatars Collection',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            );
          }

          final collections =
              controller.inventoryAvatarModel.value?.inventory?.collection ??
                  [];

          if (collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.greyColor,
                    child: Icon(
                      size: 40,
                      Icons.groups_sharp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No Collection Yet',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create your first collection to organize your avatars',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  SizedBox(height: 50),
                  RoundButton(
                    width: 170,
                    buttonColor: AppColors.blackColor,
                    title: 'Back to Dashboard',
                    onPress: () {
                      Get.back();
                    },
                  )
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.59,
            ),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              final avatars = collection.avatars ?? [];

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: avatars.isNotEmpty
                              ? Image.network(
                                  avatars.first.avatar2dUrl ?? "",
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 120,
                                  color: AppColors.greyColor,
                                  child: const Icon(Icons.image, size: 40),
                                ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Row(
                            children: [
                              _circleIconButton(
                                icon: Icons.edit,
                                color: Colors.white,
                                onTap: () {
                                  showEditCollectionDialog(
                                    context,
                                    collection.sId ?? "",
                                    collection.name ?? "",
                                    collection.description ?? "",
                                    collection.coins ?? 0,
                                    collection.isPublished ?? true,
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              _circleIconButton(
                                icon: Icons.delete,
                                color: Colors.redAccent,
                                onTap: () {
                                  deleteCollection.deleteAvatarCollection(
                                      collection.sId.toString());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    //Title, Description, Coins
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collection.name ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.opensansRegular,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  collection.description ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Coins Badge
                        ],
                      ),
                    ),

                    /// --- Avatar preview
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${avatars.length} avatars",
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: avatars.length,
                              itemBuilder: (context, i) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color:
                                        const Color.fromARGB(255, 77, 136, 165),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      avatars[i].avatar2dUrl ?? "",
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    Padding(
                      padding: ResponsivePadding.customPadding(context,
                          left: 27, bottom: 1),
                      child: Container(
                        // width: 70,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          // color: Colors.yellow.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on,
                                  size: 14, color: Colors.red),
                              const SizedBox(width: 2),
                              Text(
                                "${collection.coins ?? 0}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: AppFonts.helveticaMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// helper for circular icon buttons
  Widget _circleIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.blackColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
