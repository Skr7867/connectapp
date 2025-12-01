import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../view_models/controller/addToMarket/add_to_market_controller.dart';
import '../../view_models/controller/deleteAvatar/delete_avatar_controller.dart';
import '../../view_models/controller/inventoryAvatar/inventory_avatar_controller.dart';
import '../../view_models/controller/updateAvatar/update_avatar_controller.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';

class InventoryAvatarScreen extends StatelessWidget {
  const InventoryAvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryAvatarController controller =
        Get.put(InventoryAvatarController());

    controller.fetchInventoryAvatars();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Avatars',
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: SizedBox(
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed(RouteName.createNewAvatarsCollectionScreen);
          },
          label: const Text(
            "Create Collection",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          backgroundColor: Colors.purple,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          );
        }

        final avatars =
            controller.inventoryAvatarModel.value?.inventory?.avatars ?? [];

        if (avatars.isEmpty) {
          return Center(
            child: Text(
              "No avatars found",
              style: TextStyle(
                fontFamily: AppFonts.helveticaMedium,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: avatars.length,
          itemBuilder: (BuildContext context, int index) {
            final avatar = avatars[index];
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.greyColor.withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        avatar.avatar2dUrl ?? "",
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // color: AppColors.blackColor,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                avatar.name ?? "Unnamed",
                                style: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                avatar.description ?? "",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.greenColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editAvatar(context, avatar);
                            break;
                          case 'add_to_marketplace':
                            _addToMarketplace(context, avatar);
                            break;
                          case 'delete':
                            _deleteAvatar(context, avatar);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem<String>(
                          value: 'add_to_marketplace',
                          child: Text('Add to Marketplace'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _editAvatar(BuildContext context, dynamic avatar) {
    final UpdateAvatarController controller = Get.put(UpdateAvatarController());
    final TextEditingController nameController =
        TextEditingController(text: avatar.name ?? '');
    final TextEditingController coinsController = TextEditingController();
    final TextEditingController descriptionController =
        TextEditingController(text: avatar.description ?? '');

    Get.defaultDialog(
      title: "Edit Avatar",
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: coinsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Coins",
              border: OutlineInputBorder(),
              hintText: 'Enter your price',
            ),
          ),
        ],
      ),
      textCancel: "Cancel",
      textConfirm: "Save",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final updatedName = nameController.text.trim();
        final updatedDesc = descriptionController.text.trim();
        final updatedCoins = int.tryParse(coinsController.text.trim()) ?? 0;

        final success = await controller.updateAvatar(
          avatarId: avatar.sId,
          name: updatedName,
          description: updatedDesc,
          coins: updatedCoins,
        );

        if (success) {
          Get.back();
        }
      },
    );
  }

  void _addToMarketplace(BuildContext context, dynamic avatar) {
    final MarketplaceAvatarController controller =
        Get.put(MarketplaceAvatarController());

    final TextEditingController priceController = TextEditingController();

    Get.defaultDialog(
      title: "Add to Marketplace",
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.opensansRegular,
        fontSize: 20,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Do you want to add this avatar to the marketplace?',
            style: TextStyle(
              fontSize: 15,
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("NO"),
        ),
        const SizedBox(width: 80),
        ElevatedButton(
          onPressed: () async {
            final price = int.tryParse(priceController.text.trim()) ?? 0;

            final success = await controller.setAvatarOnMarketplace(
              avatarId: avatar.sId!,
              price: price,
            );

            if (success) {
              Get.back();
            }
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.blackColor),
          child: const Text("YES"),
        ),
      ],
    );
  }

  void _deleteAvatar(BuildContext context, dynamic avatar) async {
    final DeleteAvatarController controller = Get.put(DeleteAvatarController());
    final success = await controller.deleteAvatar(avatar.sId);
    Get.find<InventoryAvatarController>().fetchInventoryAvatars();
    if (success) {
      Get.find<InventoryAvatarController>().fetchInventoryAvatars();
    }
  }
}
