import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/custome_textfield.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../view_models/CREATORPANEL/CreateSpace/meetings_controller.dart';

class NewMeetingScreen extends StatelessWidget {
  const NewMeetingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final NewMeetingController controller = Get.put(NewMeetingController());
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'New Meeting',
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.04),
                          Text(
                            'Title',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                          CustomTextField(
                            textColor:
                                Theme.of(context).textTheme.bodyLarge?.color,
                            hintTextColor: AppColors.greyColor,
                            hintText: 'Enter Space Title',
                            controller: controller.topicController,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                          CustomTextField(
                            height: 100,
                            textColor:
                                Theme.of(context).textTheme.bodyLarge?.color,
                            hintTextColor: AppColors.greyColor,
                            hintText: 'Enter Space Description',
                            controller: controller.descriptionController,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tags',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                          CustomTextField(
                            textColor:
                                Theme.of(context).textTheme.bodyLarge?.color,
                            hintTextColor: AppColors.greyColor,
                            hintText: "Tags (comma-separated)",
                            controller: controller.tagsController,
                          ),
                          const SizedBox(height: 20),
                          Obx(() => _buildDateTile(
                                "Date",
                                controller.selectedDate.value != null
                                    ? DateFormat.yMMMd()
                                        .format(controller.selectedDate.value!)
                                    : null,
                                () => controller.pickDate(context),
                                context,
                              )),
                          Obx(() => _buildDateTile(
                                "From",
                                controller.fromTime.value?.format(context),
                                () => controller.pickTime(context, true),
                                context,
                              )),
                          Obx(() => _buildDateTile(
                                "To",
                                controller.toTime.value?.format(context),
                                () => controller.pickTime(context, false),
                                context,
                              )),
                          // Divider(color: AppColors.greyColor.withOpacity(0.4)),
                          // Text(
                          //   "Meeting option",
                          //   style: TextStyle(
                          //     color:
                          //         Theme.of(context).textTheme.bodyLarge?.color,
                          //     fontSize: 16,
                          //     fontFamily: AppFonts.opensansRegular,
                          //   ),
                          // ),
                          // Obx(() => _buildSwitch(
                          //       "Enable waiting room",
                          //       controller.enableWaitingRoom.value,
                          //       (val) =>
                          //           controller.enableWaitingRoom.value = val,
                          //       context,
                          //     )),
                          // Obx(() => _buildSwitch(
                          //       "Automatically record meeting",
                          //       controller.autoRecord.value,
                          //       (val) => controller.autoRecord.value = val,
                          //       context,
                          //     )),
                          const Spacer(),
                          Center(
                            child: Obx(() => controller.isLoading.value
                                ? CircularProgressIndicator(
                                    color: AppColors.courseButtonColor,
                                  )
                                : RoundButton(
                                    width: screenWidth * 0.85,
                                    buttonColor: AppColors.blueColor,
                                    title: 'Schedule meeting',
                                    onPress: () => controller.scheduleMeeting(),
                                  )),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile(
      String label, String? value, VoidCallback onTap, BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontFamily: AppFonts.opensansRegular,
        ),
      ),
      trailing: Text(
        value ?? "➔",
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontFamily: AppFonts.opensansRegular,
        ),
      ),
      onTap: onTap,
    );
  }

  // Widget _buildSwitch(String label, bool value, Function(bool) onChanged,
  //     BuildContext context) {
  //   return SwitchListTile(
  //     contentPadding: EdgeInsets.zero,
  //     title: Text(
  //       label,
  //       style: TextStyle(
  //         color: Theme.of(context).textTheme.bodyLarge?.color,
  //         fontFamily: AppFonts.opensansRegular,
  //       ),
  //     ),
  //     value: value,
  //     onChanged: onChanged,
  //   );
  // }
}
