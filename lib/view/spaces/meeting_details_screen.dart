import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/CREATORPANEL/FetchCreatorSpace/fetch_creator_space_model.dart';
import '../../res/assets/image_assets.dart';
import '../../res/color/app_colors.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/CREATORPANEL/FetchCreatorSpace/fetch_creator_space_controller.dart';

class MeetingDetailsScreen extends StatelessWidget {
  const MeetingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final FetchCreatorSpaceController controller =
        Get.put(FetchCreatorSpaceController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Spaces',
        automaticallyImplyLeading: true,
        centerTitle: false,
        actions: [
          Padding(
            padding: ResponsivePadding.customPadding(context, right: 5),
            child: Row(
              children: [
                RoundButton(
                  height: 40,
                  width: 130,
                  buttonColor: AppColors.blueColor,
                  title: 'Create Space',
                  onPress: () {
                    Get.toNamed(RouteName.createSpaceScreen);
                  },
                ),
              ],
            ),
          )
        ],
      ),
      body: Container(
        height: screenHeight,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.courseButtonColor,
                  strokeWidth: 3,
                ),
              );
            }
            if (controller.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.error.value,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    RoundButton(
                      width: screenWidth * 0.6,
                      buttonColor: AppColors.courseButtonColor,
                      title: 'Retry',
                      onPress: controller.fetchSpaces,
                    ),
                  ],
                ),
              );
            }
            if (controller.spacesData.value == null ||
                controller.spacesData.value!.spaces == null ||
                controller.spacesData.value!.spaces!.isEmpty) {
              return Center(
                child: Text(
                  'No spaces found.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: controller.spacesData.value!.spaces!.length,
              itemBuilder: (context, index) {
                final Spaces space =
                    controller.spacesData.value!.spaces![index];
                final tags = space.tags ?? [];
                final displayedTags = tags.take(5).toList();
                final remainingTagsCount =
                    tags.length > 2 ? tags.length - 5 : 0;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.greyColor.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.tealAccent,
                              radius: 30,
                              backgroundImage:
                                  space.creator?.avatar?.imageUrl != null &&
                                          space.creator!.avatar!.imageUrl!
                                              .isNotEmpty
                                      ? NetworkImage(
                                          space.creator!.avatar!.imageUrl!)
                                      : AssetImage(ImageAssets.profileIcon)
                                          as ImageProvider,
                              onBackgroundImageError:
                                  (exception, stackTrace) {},
                              child: space.creator?.avatar?.imageUrl == null ||
                                      space.creator!.avatar!.imageUrl!.isEmpty
                                  ? Image.asset(
                                      ImageAssets.profileIcon,
                                      height: 18,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  space.creator!.fullName ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.opensansRegular,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                                Text(
                                  'Host',
                                  style: TextStyle(
                                      fontFamily: AppFonts.opensansRegular,
                                      color: AppColors.greyColor),
                                ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: AppColors.redColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                space.status.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.opensansRegular,
                                    color: AppColors.whiteColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          space.title ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          space.description ?? 'No Description',
                          style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              color: AppColors.textColor),
                        ),
                        SizedBox(height: 20),
                        if (displayedTags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ...displayedTags.map((tag) => _Tag(tag)),
                              if (remainingTagsCount > 0)
                                _Tag("+$remainingTagsCount more"),
                            ],
                          ),
                        Divider(
                          color: AppColors.greyColor.withOpacity(0.3),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 17,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            SizedBox(width: 5),
                            Text(
                              space.startTime != null
                                  ? DateFormat('MMM dd, yyyy, hh:mm a')
                                      .format(DateTime.parse(space.startTime!))
                                  : 'N/A',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                            SizedBox(width: screenWidth * 0.23),
                            Icon(
                              size: 17,
                              Icons.people_alt_outlined,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${space.totalJoined?.toString() ?? '0'} Joined',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: RoundButton(
                            height: 40,
                            width: double.infinity,
                            buttonColor: AppColors.blueColor,
                            title: 'View Details',
                            onPress: () {
                              Get.toNamed(
                                RouteName.creatorMettingsDetailsScreen,
                                arguments: {'space': space},
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.blue.shade700,
          fontFamily: AppFonts.opensansRegular,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
