import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:flutter/material.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/CREATORPANEL/DeleteMeetins/delete_meetings_controller.dart';
import '../../view_models/CREATORPANEL/EndMeetings/end_meetings_controller.dart';
import '../../view_models/CREATORPANEL/StartMeeting/start_meetings_controller.dart';
import '../../view_models/controller/themeController/theme_controller.dart';

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

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    if (space == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                "No Space Found",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
            // Enhanced Header Section
            _buildEnhancedHeader(context, space, size, isTablet),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Host & Creator Card
                    _buildHostCreatorCard(context, space, isTablet),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Description Section
                    _buildDescriptionSection(context, space, isTablet),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Space Stats Cards
                    _buildSpaceStatsCards(context, space, isTablet),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Tags Section
                    _buildTagsSection(context, space, isTablet),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Members Section
                    _buildMembersSection(context, space, isTablet),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Action Buttons
                    _buildActionButtons(
                      context,
                      space,
                      startController,
                      endMeetingsController,
                      deleteMeetingsController,
                      size,
                      isTablet,
                    ),

                    SizedBox(height: isTablet ? 32 : 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Header with gradient and better layout
  Widget _buildEnhancedHeader(
    BuildContext context,
    dynamic space,
    Size size,
    bool isTablet,
  ) {
    Color statusColor = _getStatusColor(space.status);
    IconData statusIcon = _getStatusIcon(space.status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge and Time Row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        space.startTime != null
                            ? DateFormat('MMM dd, yyyy, hh:mm a').format(
                                DateTime.parse(space.startTime!).toLocal(),
                              )
                            : 'N/A',
                        style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 13,
                            color: AppColors.blackColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        space.status.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: AppFonts.opensansRegular,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 20 : 16),

            // Title
            Text(
              space.title ?? 'No Title',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            SizedBox(height: isTablet ? 20 : 16),

            // Start Meeting Button
            _buildStartMeetingButton(context, space, size, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildStartMeetingButton(
    BuildContext context,
    dynamic space,
    Size size,
    bool isTablet,
  ) {
    final isDisabled = (space.status == 'Ended' || space.status == 'Scheduled');
    final buttonWidth = isTablet ? size.width * 0.35 : size.width * 0.6;

    return SizedBox(
      width: buttonWidth,
      height: isTablet ? 54 : 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDisabled ? Colors.grey.shade400 : AppColors.blueColor,
          foregroundColor: Colors.white,
          elevation: isDisabled ? 0 : 2,
          shadowColor: AppColors.blueColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        onPressed: isDisabled
            ? null
            : () async {
                final url = space.dailyRoomUrl;
                if (url == null || url.isEmpty) {
                  Get.snackbar('Info', 'No room URL found.');
                  return;
                }

                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  Get.snackbar('Info', 'Could not launch URL.');
                }
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDisabled ? Icons.block : Icons.videocam,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Start Meeting',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Host Creator Card
  Widget _buildHostCreatorCard(
      BuildContext context, dynamic space, bool isTablet) {
    final themeController = Get.find<ThemeController>();
    final bool isDark = themeController.isDarkMode.value;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.blackColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin,
                size: isTablet ? 20 : 18,
                color: AppColors.blueColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Host & Creator',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: AppFonts.opensansRegular,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isTablet ? 32 : 28,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: (space.creator?.avatar?.imageUrl != null &&
                          space.creator!.avatar!.imageUrl!.isNotEmpty)
                      ? NetworkImage(space.creator!.avatar!.imageUrl!)
                      : null,
                  child: (space.creator?.avatar?.imageUrl == null ||
                          space.creator!.avatar!.imageUrl!.isEmpty)
                      ? Text(
                          space.creator?.fullName != null &&
                                  space.creator!.fullName!.isNotEmpty
                              ? space.creator!.fullName![0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blueColor,
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      space.creator.fullName ?? 'User',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${space.creator.username ?? 'username'}',
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Description Section
  Widget _buildDescriptionSection(
      BuildContext context, dynamic space, bool isTablet) {
    final themeController = Get.find<ThemeController>();
    final bool isDark = themeController.isDarkMode.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: isTablet ? 20 : 18,
              color: AppColors.blueColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Description',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.blackColor : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            space.description ?? 'No description available',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.8),
              fontFamily: AppFonts.opensansRegular,
              fontSize: isTablet ? 16 : 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  // Space Stats Cards
  Widget _buildSpaceStatsCards(
      BuildContext context, dynamic space, bool isTablet) {
    // final themeController = Get.find<ThemeController>();
    // final bool isDark = themeController.isDarkMode.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: isTablet ? 20 : 18,
              color: AppColors.blueColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Space Information',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isTablet || constraints.maxWidth > 500) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.fingerprint,
                      'Space ID',
                      space.sId ?? 'N/A',
                      isTablet,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.people,
                      'Participants',
                      (space.totalJoined ?? 0).toString(),
                      isTablet,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildStatCard(
                    context,
                    Icons.fingerprint,
                    'Space ID',
                    space.sId ?? 'N/A',
                    isTablet,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    Icons.people,
                    'Participants',
                    (space.totalJoined ?? 0).toString(),
                    isTablet,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isTablet,
  ) {
    final themeController = Get.find<ThemeController>();
    final bool isDark = themeController.isDarkMode.value;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     Colors.blue.shade50,
        //     Colors.white,
        //   ],
        // ),

        color: isDark ? AppColors.blackColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: isTablet ? 20 : 18,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Tags Section
  Widget _buildTagsSection(BuildContext context, dynamic space, bool isTablet) {
    if (space.tags == null || space.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.label_outline,
              size: isTablet ? 20 : 18,
              color: AppColors.blueColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 12 : 8,
          children: space.tags
              .map<Widget>((tag) => _buildTag(tag, isTablet))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String label, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 10 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontFamily: AppFonts.opensansRegular,
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Members Section
  Widget _buildMembersSection(
      BuildContext context, dynamic space, bool isTablet) {
    if (space.members == null || space.members.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.group,
              size: isTablet ? 20 : 18,
              color: AppColors.blueColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Members',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${space.members.length}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontFamily: AppFonts.opensansRegular,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        SizedBox(
          height: isTablet ? 140 : 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: space.members.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: isTablet ? 20 : 16),
            itemBuilder: (context, index) {
              final member = space.members[index];
              return _buildMemberCard(context, member, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, dynamic member, bool isTablet) {
    return Container(
      width: isTablet ? 120 : 100,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueColor.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: isTablet ? 28 : 24,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: (member?.avatar?.imageUrl != null &&
                      member.avatar!.imageUrl!.isNotEmpty)
                  ? NetworkImage(member.avatar!.imageUrl!)
                  : null,
              child: (member?.avatar?.imageUrl == null ||
                      member.avatar!.imageUrl!.isEmpty)
                  ? Text(
                      member?.fullName != null && member.fullName!.isNotEmpty
                          ? member.fullName![0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            member?.fullName ?? 'No Name',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: AppFonts.opensansRegular,
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '@${member?.username ?? 'user'}',
            style: TextStyle(
              color: AppColors.blueColor,
              fontFamily: AppFonts.opensansRegular,
              fontSize: isTablet ? 11 : 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action Buttons Section
  Widget _buildActionButtons(
    BuildContext context,
    dynamic space,
    StartMeetingsController startController,
    EndMeetingsController endMeetingsController,
    DeleteMeetingsController deleteMeetingsController,
    Size size,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings,
              size: isTablet ? 20 : 18,
              color: AppColors.blueColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Meeting Controls',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isTablet || constraints.maxWidth > 500) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStartEndButton(
                      context,
                      space,
                      startController,
                      endMeetingsController,
                      isTablet,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildDeleteButton(
                    context,
                    space,
                    deleteMeetingsController,
                    isTablet,
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStartEndButton(
                    context,
                    space,
                    startController,
                    endMeetingsController,
                    isTablet,
                  ),
                  const SizedBox(height: 12),
                  _buildDeleteButton(
                    context,
                    space,
                    deleteMeetingsController,
                    isTablet,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStartEndButton(
    BuildContext context,
    dynamic space,
    StartMeetingsController startController,
    EndMeetingsController endMeetingsController,
    bool isTablet,
  ) {
    return Obx(
      () => SizedBox(
        height: isTablet ? 54 : 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: space.status == 'Ended'
                ? Colors.grey.shade400
                : space.status == 'Live'
                    ? Colors.orange.shade600
                    : AppColors.blueColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppColors.blueColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          onPressed: startController.isLoading.value || space.status == 'Ended'
              ? null
              : space.status == 'Live'
                  ? () {
                      _showEndMeetingDialog(
                        context,
                        space,
                        endMeetingsController,
                      );
                    }
                  : () {
                      startController.startMeeting(space.sId!);
                    },
          child: startController.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      space.status == 'Ended'
                          ? Icons.check_circle
                          : space.status == 'Live'
                              ? Icons.stop_circle
                              : Icons.play_circle,
                      size: isTablet ? 22 : 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      space.status == 'Ended'
                          ? 'Ended'
                          : space.status == 'Live'
                              ? 'End Meeting'
                              : 'Start',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    dynamic space,
    DeleteMeetingsController deleteMeetingsController,
    bool isTablet,
  ) {
    return Obx(
      () => SizedBox(
        height: isTablet ? 54 : 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.redColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppColors.redColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: deleteMeetingsController.isDeleting.value
              ? null
              : () async {
                  if (space.sId == null) {
                    Get.snackbar('Error', 'Space ID is missing.');
                    return;
                  }
                  _showDeleteConfirmationDialog(
                    context,
                    space,
                    deleteMeetingsController,
                  );
                },
          child: deleteMeetingsController.isDeleting.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_forever,
                      size: isTablet ? 22 : 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete Meeting',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Helper Functions
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Live':
        return Colors.red;
      case 'Scheduled':
        return Colors.blue;
      case 'Ended':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Live':
        return Icons.circle;
      case 'Scheduled':
        return Icons.schedule;
      case 'Ended':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  void _showEndMeetingDialog(
    BuildContext context,
    dynamic space,
    EndMeetingsController endMeetingsController,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'End Meeting',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end this meeting? All participants will be disconnected.',
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            color:
                Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              endMeetingsController.endMeeting(space.sId!);
            },
            child: Text(
              'End Meeting',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    dynamic space,
    DeleteMeetingsController deleteMeetingsController,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.delete_forever,
              color: AppColors.redColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Meeting',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete this meeting? This action cannot be undone.',
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            color:
                Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              deleteMeetingsController.deleteSpace(space.sId!);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
