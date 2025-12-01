import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/controller/language/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_check_box_rounded/flutter_check_box_rounded.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';

class LanguageScreen extends StatelessWidget {
  LanguageScreen({super.key});

  // Define language titles and subtitles using translations
  final List<String> languageTitles = [
    'english'.tr,
    'hindi'.tr,
  ];

  final List<String> languageSubTitles = [
    'english_subtitle'.tr,
    'hindi_subtitle'.tr,
  ];

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'select_language'.tr, // Use translated string
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              Container(
                height: screenHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: ListView.builder(
                  padding: ResponsivePadding.customPadding(context, top: 2),
                  itemCount: languageTitles.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    return ListTile(
                      title: Text(
                        languageTitles[index], // Use translated title
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      subtitle: Text(
                        languageSubTitles[index], // Use translated subtitle
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 12,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      trailing: Obx(() => CheckBoxRounded(
                            borderColor: AppColors.blackColor,
                            uncheckedColor: AppColors.whiteColor,
                            checkedColor: AppColors.buttonColor,
                            isChecked: controller.selectedIndex.value == index,
                            onTap: (bool? value) {
                              controller.selectLanguage(index);
                            },
                          )),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
