import 'dart:developer';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:flutter/material.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../res/color/app_colors.dart';
import '../../utils/utils.dart';
import '../../view_models/controller/allspaces/join_space_controller.dart';

class JoinMeetingScreen extends StatelessWidget {
  const JoinMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final space = arguments['space'];
    final JoinSpaceController joinController = Get.put(JoinSpaceController());
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
        title: 'Space',
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
                    color: Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            ? DateFormat('dd/MM/yyyy h:mm a').format(
                                DateTime.parse(space.startTime).toLocal())
                            : 'N/A',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.7),
                          fontFamily: AppFonts.opensansRegular,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 8),
                      Obx(() => SizedBox(
                            width: screenWidth * 0.25,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              onPressed: joinController.rxRequestStatus.value
                                  ? null
                                  : () async {
                                      final roomUrl = await joinController
                                          .joinSpace(space.sId);
                                      if (roomUrl != null) {
                                        final Uri uri = Uri.parse(roomUrl);
                                        try {
                                          final canLaunch =
                                              await canLaunchUrl(uri);
                                          log("Can launch URL: $canLaunch");
                                          if (canLaunch) {
                                            await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          } else {
                                            Utils.snackBar(
                                              "No app available to open the meeting URL. Please ensure a browser is installed.",
                                              "Info",
                                            );
                                          }
                                        } catch (e, stackTrace) {
                                          log("Launch URL error: $e",
                                              stackTrace: stackTrace);
                                          Utils.snackBar(
                                            "Failed to open the meeting URL: $e",
                                            "Error",
                                          );
                                        }
                                      }
                                    },
                              child: joinController.rxRequestStatus.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Join Now',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: AppFonts.opensansRegular),
                                    ),
                            ),
                          )),
                      const SizedBox(width: 8),
                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () async {
                              String deepLink =
                                  "https://play.google.com/store/apps/details?id=app.connectapp.com&pcampaignid=web_share";
                              await Share.share(
                                'Check out this Space: $deepLink',
                                subject: 'Share Space',
                              );
                            },
                            icon: Icon(Icons.share),
                          ),
                        ),
                      ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Live Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                    // Host & Creator section
                    _buildSectionTitle('Host & Creator', context),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
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
                    Divider(),
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
                    Divider(),

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
                    Divider(),
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
