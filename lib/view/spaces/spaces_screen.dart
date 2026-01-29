import 'dart:developer';
import 'package:connectapp/data/response/status.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/allspaces/get_all_spaces_controller.dart';
import 'package:connectapp/view_models/controller/allspaces/enroll_in_space_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../res/color/app_colors.dart';

class SpacesScreen extends StatefulWidget {
  const SpacesScreen({super.key});

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  String selectedTab = "Upcoming";

  @override
  Widget build(BuildContext context) {
    Get.put(AllSpacesController());
    Get.put(EnrollSpaceController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          selectedTab,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: AppFonts.opensansRegular,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.textfieldColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabItem("Live Now", selectedTab == "Live Now"),
                const SizedBox(width: 5),
                _tabItem("Upcoming", selectedTab == "Upcoming"),
                const SizedBox(width: 5),
                _tabItem("Recorded", selectedTab == "Recorded"),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Space by title, description...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // Content
            Expanded(child: _getTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String label, bool isSelected, {int badgeCount = 0}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label == "Live Now")
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (label == "Upcoming")
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (label == "Recorded")
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey.shade600,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).scaffoldBackgroundColor,
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 19,
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getTabContent() {
    final spacesController = Get.find<AllSpacesController>();
    String statusFilter;
    switch (selectedTab) {
      case "Live Now":
        statusFilter = "live";
        break;
      case "Recorded":
        statusFilter = "recorded";
        break;
      case "Upcoming":
      default:
        statusFilter = "scheduled";
        break;
    }

    return Obx(() {
      if (spacesController.rxRequestStatus.value == Status.LOADING) {
        return const Center(child: CircularProgressIndicator());
      } else if (spacesController.rxRequestStatus.value == Status.ERROR) {
        return Center(
          child: Text(
            spacesController.error.value,
            style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular),
          ),
        );
      }

      final filteredSpaces = spacesController.spaces
          .where((space) =>
              space.status?.toLowerCase() == statusFilter.toLowerCase())
          .toList();

      if (filteredSpaces.isEmpty) {
        return Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              "No $selectedTab spaces found",
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: AppFonts.opensansRegular),
            ),
            Text(
              textAlign: TextAlign.center,
              "Check back later for $selectedTab spaces",
              style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textColor,
                  fontFamily: AppFonts.opensansRegular),
            ),
          ],
        ));
      }

      return RefreshIndicator(
        onRefresh: spacesController.refreshSpaces,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredSpaces.length,
          itemBuilder: (context, index) {
            return _buildSessionCard(filteredSpaces[index]);
          },
        ),
      );
    });
  }

  Widget _buildSessionCard(space) {
    final enrollController = Get.find<EnrollSpaceController>();

    // Initialize enrollment with space.sId
    if (space.sId != null) {
      enrollController.initializeEnrollment(space.sId!, space.members ?? []);
    }

    String formattedStartTime = "N/A";
    if (space.startTime != null) {
      try {
        final utcDate = DateTime.parse(space.startTime!).toUtc();
        final istDate = utcDate.add(const Duration(hours: 5, minutes: 30));
        formattedStartTime = DateFormat('MMM d, yyyy h:mm a').format(istDate);
      } catch (e) {
        log("Error parsing startTime: $e");
      }
    }

    final tags = space.tags ?? [];
    final displayedTags = tags.take(2).toList();
    final remainingTagsCount = tags.length > 2 ? tags.length - 2 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).scaffoldBackgroundColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Host info row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: space.creator?.avatar?.imageUrl != null &&
                          space.creator!.avatar!.imageUrl!.isNotEmpty
                      ? NetworkImage(space.creator!.avatar!.imageUrl!)
                      : AssetImage(ImageAssets.profileIcon) as ImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: space.creator?.avatar?.imageUrl == null ||
                          space.creator!.avatar!.imageUrl!.isEmpty
                      ? Image.asset(
                          ImageAssets.profileIcon,
                          height: 18,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      space.creator?.fullName ?? "Host",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Host",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${space.totalJoined ?? 0} joined",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title and description
            Text(
              space.title ?? "Connect app",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              space.description ?? "Connect app meeting",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            if (displayedTags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...displayedTags.map((tag) => _Tag(tag)),
                  if (remainingTagsCount > 0) _Tag("+$remainingTagsCount more"),
                ],
              ),
            const SizedBox(height: 16),

            // Date and time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedStartTime,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 12,
                  ),
                ),
                // const Spacer(),
                // Icon(
                //   Icons.schedule,
                //   size: 14,
                //   color: Theme.of(context).textTheme.bodyLarge?.color,
                // ),
                // const SizedBox(width: 4),
                // Text(
                //   '60',
                //   style: TextStyle(
                //     color: Theme.of(context).textTheme.bodyLarge?.color,
                //     fontFamily: AppFonts.opensansRegular,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Obx(() {
                final buttonText = enrollController.getButtonText(
                  space.sId ?? "",
                  space.status ?? "",
                );
                final isLoading = enrollController.rxRequestStatus[space.sId] ==
                    Status.LOADING;

                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : buttonText == "Enroll"
                          ? () =>
                              enrollController.enrollInSpace(space.sId ?? "")
                          : buttonText == "View Details"
                              ? () {
                                  final spaceId = space.sId;
                                  if (spaceId == null || spaceId.isEmpty) {
                                    Get.snackbar(
                                      "Error",
                                      "Space ID is missing.",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                  log("Navigating to JoinMeetingScreen with spaceId: $spaceId");
                                  Get.toNamed(
                                    RouteName.joinMeeting,
                                    arguments: {'space': space},
                                  );
                                }
                              : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textfieldColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          buttonText.isEmpty ? "Enrolled Already" : buttonText,
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontFamily: AppFonts.opensansRegular,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                );
              }),
            ),
          ],
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
