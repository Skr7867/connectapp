import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/controller/createNewAvatarsCollection/create_new_avatars_collection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../view_models/controller/inventoryAvatar/inventory_avatar_controller.dart';

class CreateNewCollectionAvatarsScreen extends StatelessWidget {
  const CreateNewCollectionAvatarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Collection controller
    final collectionController =
        Get.put(CreateNewAvatarsCollectionController());
    // Avatars list controller
    final inventoryController = Get.put(InventoryAvatarController());

    final avatars =
        inventoryController.inventoryAvatarModel.value?.inventory?.avatars ??
            [];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Create New Collection',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: ResponsivePadding.symmetricPadding(context, horizontal: 4),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

                /// Collection Name
                Text(
                  'Collection Name*',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                CustomTextField(
                  controller: collectionController.avatarsCollectionName.value,
                  fillColor: AppColors.textfieldColor,
                  hintText: 'Enter Collection Name',
                ),

                const SizedBox(height: 15),

                /// Collection Description
                Text(
                  'Collection Description',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                CustomTextField(
                  controller: collectionController.avatarsDescriptionName.value,
                  fillColor: AppColors.textfieldColor,
                  hintText: 'Enter Collection Description',
                ),

                const SizedBox(height: 15),

                /// Price
                Text(
                  'Price (Coins)',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                CustomTextField(
                  controller: collectionController.collectionPrice.value,
                  fillColor: AppColors.textfieldColor,
                  keyboardType: TextInputType.number,
                  hintText: 'Enter Collection Price',
                ),

                /// Publish Checkbox
                Row(
                  children: [
                    Obx(() => Checkbox(
                          activeColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          value: collectionController.isTermsAccepted.value,
                          onChanged: (value) {
                            collectionController.isTermsAccepted.value =
                                value ?? false;
                          },
                        )),
                    Text(
                      'Publish Collection',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),

                /// Avatar Grid
                SizedBox(
                  height: 400,
                  child: MasonryGridView.count(
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemCount: avatars.length,
                    itemBuilder: (BuildContext context, int index) {
                      final avatar = avatars[index];
                      final avatarId = avatar.sId ?? index.toString();

                      return Obx(() {
                        final isSelected = collectionController
                            .selectedAvatarIds
                            .contains(avatarId);

                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              collectionController.selectedAvatarIds
                                  .remove(avatarId);
                            } else {
                              collectionController.selectedAvatarIds
                                  .add(avatarId);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.greenColor
                                    : AppColors.greyColor,
                                width: isSelected ? 2 : 1,
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
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        size: 60,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 4),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            avatar.name ?? "Unnamed",
                                            style: const TextStyle(
                                              color: Colors.pink,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  AppFonts.opensansRegular,
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
                                              fontFamily:
                                                  AppFonts.opensansRegular,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.green,
                                      child: const Icon(Icons.check,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Obx(
                  () => Center(
                    child: RoundButton(
                      loading: collectionController.isLoading.value,
                      buttonColor: AppColors.blackColor,
                      title: 'Save Collection',
                      onPress: () {
                        collectionController.createCollection();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
