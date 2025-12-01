import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/CREATORPANEL/DeleteMeetins/delete_meetings_controller.dart';
import '../../view_models/CREATORPANEL/EndMeetings/end_meetings_controller.dart';
import '../../view_models/CREATORPANEL/StartMeeting/start_meetings_controller.dart';

class CreatorMeetingDetailsScreen extends StatelessWidget {
  const CreatorMeetingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final space = arguments['space'];
    final StartMeetingsController startController =
        Get.put(StartMeetingsController());
    final EndMeetingsController endMeetingsController =
        Get.put(EndMeetingsController());
    final DeleteMeetingsController deleteMeetingsController =
        Get.put(DeleteMeetingsController());
    double screenWidth = MediaQuery.of(context).size.width;

    if (space == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No Live Space Found",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Space Details',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Header with date, title, and actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Host & Creator',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.opensansRegular,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      SizedBox(width: screenWidth * 0.27),
                      RoundButton(
                          height: 25,
                          width: 70,
                          buttonColor: AppColors.redColor,
                          title: space.status.toString(),
                          onPress: () {}),
                      IconButton(
                          onPressed: () {
                            Utils.toastMessageCenter(
                                'It will Work after app push on playstore');
                          },
                          icon: Icon(
                            Icons.share,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ))
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        space.startTime != null
                            ? DateFormat('MMM dd, yyyy, hh:mm a')
                                .format(DateTime.parse(space.startTime!))
                            : 'N/A',
                        style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 13,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.title ?? 'No Title',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (space.status == 'Ended' ||
                                  space.status == 'Scheduled')
                              ? Colors.grey
                              : AppColors.blueColor,
                          minimumSize: Size(screenWidth * 0.2, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: (space.status == 'Ended' ||
                                space.status == 'Scheduled')
                            ? null
                            : () async {
                                final url = space.dailyRoomUrl;
                                if (url == null || url.isEmpty) {
                                  Get.snackbar('Error', 'No room URL found.');
                                  return;
                                }

                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  Get.snackbar(
                                      'Error', 'Could not launch URL.');
                                }
                              },
                        child: Text(
                          'Start Meeting',
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.greyColor.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: (space.creator?.avatar?.imageUrl !=
                                        null &&
                                    space.creator!.avatar!.imageUrl!.isNotEmpty)
                                ? NetworkImage(space.creator!.avatar!.imageUrl!)
                                : null,
                            child: (space.creator?.avatar?.imageUrl == null ||
                                    space.creator!.avatar!.imageUrl!.isEmpty)
                                ? Text(
                                    space.creator?.fullName != null &&
                                            space.creator!.fullName!.isNotEmpty
                                        ? space.creator!.fullName![0]
                                            .toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                space.creator.fullName ?? 'No Name',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                space.creator.username ??
                                    'No UserName Available',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.6),
                                  fontFamily: AppFonts.opensansRegular,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: AppColors.greyColor.withOpacity(0.4)),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Description', context),
                    const SizedBox(height: 8),
                    Text(
                      space.description ?? 'No description Available',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.7),
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Space Information section
                    _buildSectionTitle('Space Information', context),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          'Space Id : ',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.7),
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          space.sId ?? 'Id Not Available',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: AppColors.greyColor.withOpacity(0.4)),

                    // Participants and Duration section
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                  'Participates Joined', context),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (space.totalJoined ?? 0).toString(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontFamily: AppFonts.opensansRegular,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tags section
                    _buildSectionTitle('Tags', context),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...space.tags.map((tag) => _buildTag(tag)).toList(),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Divider(color: AppColors.greyColor.withOpacity(0.4)),
                    const SizedBox(height: 10),
                    // Members section
                    _buildSectionTitle('Members', context),
                    Center(
                      child: Image.asset(
                        ImageAssets.signinImg,
                        height: 70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: space.members.length,
                          itemBuilder: (context, int index) {
                            return Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade300,
                                        backgroundImage:
                                            (space.creator?.avatar?.imageUrl !=
                                                        null &&
                                                    space.creator!.avatar!
                                                        .imageUrl!.isNotEmpty)
                                                ? NetworkImage(space
                                                    .creator!.avatar!.imageUrl!)
                                                : null,
                                        child: (space.creator?.avatar
                                                        ?.imageUrl ==
                                                    null ||
                                                space.creator!.avatar!.imageUrl!
                                                    .isEmpty)
                                            ? Text(
                                                space.creator?.fullName !=
                                                            null &&
                                                        space.creator!.fullName!
                                                            .isNotEmpty
                                                    ? space
                                                        .creator!.fullName![0]
                                                        .toUpperCase()
                                                    : "?",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      space.creator.fullName ?? 'No Name',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontFamily: AppFonts.opensansRegular,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      space.creator.username ??
                                          'No UserName Available',
                                      style: TextStyle(
                                        color: AppColors.greenColor,
                                        fontFamily: AppFonts.opensansRegular,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                    ),
                    Row(
                      children: [
                        Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: space.status == 'Ended'
                                  ? Colors.grey
                                  : AppColors.blueColor,
                              minimumSize: Size(screenWidth * 0.35, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: startController.isLoading.value ||
                                    space.status == 'Ended'
                                ? null
                                : space.status == 'Live'
                                    ? () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor:
                                                AppColors.blackColor,
                                            title: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                  color: AppColors.whiteColor),
                                            ),
                                            content: Text(
                                              'Are you sure you want to end the meeting?',
                                              style: TextStyle(
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                  color: AppColors.whiteColor),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      fontFamily: AppFonts
                                                          .opensansRegular,
                                                      color:
                                                          AppColors.whiteColor),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                  endMeetingsController
                                                      .endMeeting(space.sId!);
                                                },
                                                child: Text(
                                                  'End',
                                                  style: TextStyle(
                                                      fontFamily: AppFonts
                                                          .opensansRegular,
                                                      color:
                                                          AppColors.whiteColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    : () {
                                        startController
                                            .startMeeting(space.sId!);
                                      },
                            child: startController.isLoading.value
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    space.status == 'Ended'
                                        ? 'Ended'
                                        : space.status == 'Live'
                                            ? 'End meeting'
                                            : 'Start',
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 16,
                                      fontFamily: AppFonts.opensansRegular,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: AppColors.redColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: IconButton(
                              icon: deleteMeetingsController.isDeleting.value
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: AppColors.redColor,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Delete Meetings',
                                      style: TextStyle(
                                          fontFamily: AppFonts.opensansRegular,
                                          fontWeight: FontWeight.bold),
                                    ),
                              onPressed: deleteMeetingsController
                                      .isDeleting.value
                                  ? null
                                  : () async {
                                      if (space.sId == null) {
                                        Get.snackbar(
                                            'Error', 'Space ID is missing.');
                                        return;
                                      }
                                      await deleteMeetingsController
                                          .deleteSpace(space.sId!);
                                    },
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontFamily: AppFonts.opensansRegular,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontFamily: AppFonts.opensansRegular,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
