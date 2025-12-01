import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../res/color/app_colors.dart';

class ReportAnIssueScreen extends StatefulWidget {
  const ReportAnIssueScreen({super.key});

  @override
  State<ReportAnIssueScreen> createState() => _ReportAnIssueScreenState();
}

class _ReportAnIssueScreenState extends State<ReportAnIssueScreen> {
  String? selectedIssue;
  final TextEditingController descriptionController = TextEditingController();

  final List<String> issueList = [
    'payment_failed'.tr,
    'payment_deducted_no_confirmation'.tr,
    'app_crash_checkout'.tr,
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'report_an_issue'.tr,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'issue_desc'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'select_issue_type'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textfieldColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  dropdownColor: Theme.of(context).textTheme.bodyLarge?.color,
                  value: selectedIssue,
                  hint: Text(
                    'select_issue'.tr,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  iconEnabledColor: AppColors.textfieldColor,
                  style: TextStyle(
                    color: AppColors.textfieldColor,
                    fontSize: 14,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  items: issueList.map((String issue) {
                    return DropdownMenuItem<String>(
                      value: issue,
                      child: Text(issue,
                          style: TextStyle(
                            color: AppColors.blueShade,
                            fontFamily: AppFonts.opensansRegular,
                          )),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedIssue = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'select_issue_type'.tr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontFamily: AppFonts.opensansRegular,
                ),
                decoration: InputDecoration(
                  hintText: 'select_issue_type'.tr,
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: AppColors.textfieldColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: AppColors.textfieldColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  // Handle submit
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A4EF3), Color(0xFF9C3FE4)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'submit'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
