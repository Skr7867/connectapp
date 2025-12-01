import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({super.key});

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'terms_and_service'.tr,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSection('acceptance'.tr, 'acceptance1'.tr),
              Divider(color: Colors.grey[400], height: 30),
              buildSection('user_account'.tr, 'user_account1'.tr),
              Divider(color: Colors.grey[400], height: 30),
              buildSection('x_p_points'.tr, 'x_p_points1'.tr),
              Divider(color: Colors.grey[400], height: 30),
              buildSection('', 'x_p_points2'.tr),

              // New Sections from Image:
              buildSection('use_of_the_app'.tr, 'terms_desc'.tr),
              Divider(color: Colors.grey[400], height: 30),
              buildSection('content_ownership'.tr, 'content_desc'.tr),
              Divider(color: Colors.grey[400], height: 30),
              buildSection('modification_update'.tr, 'modification_desc'.tr),
              Divider(color: Colors.grey[400], height: 30),
              buildSection('termination'.tr, 'termination_desc'.tr),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
