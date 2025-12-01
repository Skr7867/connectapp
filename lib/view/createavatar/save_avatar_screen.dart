import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../utils/utils.dart';
import '../../view_models/controller/createAvatar/create_avatar_controller.dart';

class SaveAvatarPage extends StatelessWidget {
  final String glbUrl;
  final String pngUrl;

  const SaveAvatarPage({super.key, required this.glbUrl, required this.pngUrl});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final CreateAvatarController controller = Get.put(CreateAvatarController());

    // Text controllers for user input
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Save Avatar',
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Your Avatar is ready!",
                  style: TextStyle(
                    fontSize: 30,
                    color: AppColors.greenColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.blackColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.network(
                    pngUrl,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Text("3D Model URL: $glbUrl"),
              // Text("2D Preview URL: $pngUrl"),
              // const SizedBox(height: 10),
              const Text('Name'),
              CustomTextField(
                controller: nameController,
                fillColor: AppColors.textfieldColor,
                hintText: 'Enter Avatar Name',
              ),
              const SizedBox(height: 20),
              const Text('Description'),
              CustomTextField(
                controller: descriptionController,
                fillColor: AppColors.textfieldColor,
                hintText: 'Enter Avatar description',
              ),
              const SizedBox(height: 60),

              Center(
                child: Obx(
                  () => RoundButton(
                    loading: controller.isLoading.value,
                    buttonColor: AppColors.blackColor,
                    title: 'Save Avatar',
                    onPress: () async {
                      if (nameController.text.trim().isEmpty) {
                        Utils.snackBar(
                          'Please enter an avatar name',
                          'Failed ',
                        );
                        return;
                      }
                      final success = await controller.createAvatar(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        avatar2dUrl: pngUrl,
                        avatar3dUrl: glbUrl,
                      );
                      if (success) {
                        // Clear input fields
                        nameController.clear();
                        descriptionController.clear();
                        Get.toNamed(RouteName.inventoryAvatarScreen);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
