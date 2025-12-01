import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';

import '../../view_models/controller/editAvatarsCollection/edit_avatars_collection_controller.dart';

void showEditCollectionDialog(
  BuildContext context,
  String collectionId,
  String name,
  String description,
  int coins,
  bool isPublishedInitial,
) {
  final TextEditingController nameController =
      TextEditingController(text: name);
  final TextEditingController descriptionController =
      TextEditingController(text: description);
  final TextEditingController coinsController =
      TextEditingController(text: coins.toString());

  bool isPublished = isPublishedInitial;

  // GetX Controller
  final EditAvatarsCollectionController controller =
      Get.put(EditAvatarsCollectionController());

  showDialog(
    barrierColor: AppColors.blackColor.withOpacity(0.7),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Obx(() {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(
                "Edit Collection",
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name
                    Text("Collection Name *", style: _labelStyle(context)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: _inputDecoration(
                        context,
                        "Enter collection name",
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Description
                    Text("Description", style: _labelStyle(context)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        context,
                        "Enter description",
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Coins
                    Text("Price (Coins)", style: _labelStyle(context)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: coinsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.monetization_on),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Publish Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: isPublished,
                          onChanged: (value) {
                            setState(() {
                              isPublished = value ?? true;
                            });
                          },
                        ),
                        Text(
                          "Publish Collection",
                          style: _labelStyle(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Actions
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: _labelStyle(context),
                  ),
                ),

                /// Save Button
                ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final success = await controller.editCollection(
                            collectionId: collectionId,
                            name: nameController.text,
                            description: descriptionController.text,
                            coins: int.tryParse(coinsController.text) ?? 0,
                            isPublished: isPublished,
                          );

                          if (success) {
                            Navigator.pop(context); // close dialog
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blackColor,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Save Changes",
                          style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor,
                          ),
                        ),
                ),
              ],
            );
          });
        },
      );
    },
  );
}

TextStyle _labelStyle(BuildContext context) => TextStyle(
      fontFamily: AppFonts.opensansRegular,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

InputDecoration _inputDecoration(BuildContext context, String hint) =>
    InputDecoration(
      border: const OutlineInputBorder(),
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: AppFonts.opensansRegular,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
