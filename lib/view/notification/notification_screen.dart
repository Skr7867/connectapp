import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/response/status.dart';
import '../../models/Notification/notification_module.dart';
import '../../view_models/controller/notification/notification_controller.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.find<NotificationController>();
  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'all'.obs;
  final FocusNode _searchFocusNode = FocusNode();

  List<Notifications> _filterNotifications(List<Notifications>? notifications) {
    if (notifications == null) return [];
    final filtered = notifications.where((n) {
      if (selectedFilter.value == 'unread' && n.isRead == true) return false;
      if (searchController.text.isEmpty) return true;
      return (n.title
                  ?.toLowerCase()
                  .contains(searchController.text.toLowerCase()) ??
              false) ||
          (n.message
                  ?.toLowerCase()
                  .contains(searchController.text.toLowerCase()) ??
              false);
    }).toList();
    return filtered;
  }

  List<Notifications> _getAllNotifications(List<Notifications>? notifications) {
    return _filterNotifications(notifications);
  }

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidht = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'notification'.tr,
        actions: [
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                  if (controller.unreadCount.value > 0)
                    Positioned(
                      right: 10,
                      top: 8,
                      child: Container(
                        height: 18,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${controller.unreadCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 7,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshNotifications,
        child: Obx(() {
          return controller.rxRequestStatus.value == Status.LOADING
              ? const Center(child: CircularProgressIndicator())
              : controller.rxRequestStatus.value == Status.ERROR
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.error.value,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.refreshNotifications,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: ListView(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.textfieldColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: AppColors.textColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    focusNode: _searchFocusNode,
                                    decoration: InputDecoration(
                                      hintText: 'search_here'.tr,
                                      hintStyle: const TextStyle(
                                        color: AppColors.textColor,
                                        fontFamily: AppFonts.opensansRegular,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: AppFonts.opensansRegular,
                                    ),
                                    onChanged: (value) {
                                      selectedFilter.refresh();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          //  Filter Tabs
                          Obx(() {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: AppColors.textfieldColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: screenWidht * 0.03),
                                  _buildTab(
                                    label: 'all_12'.tr,
                                    isSelected: selectedFilter.value == 'all',
                                    onTap: () => selectedFilter.value = 'all',
                                  ),
                                  Spacer(),
                                  _buildTab(
                                    label: 'unread'.tr,
                                    isSelected:
                                        selectedFilter.value == 'unread',
                                    onTap: () =>
                                        selectedFilter.value = 'unread',
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 5),

                          Divider(),

                          // Notifications with Divider
                          Obx(() {
                            final notifications = _getAllNotifications(
                                controller.notifications.value.notifications);

                            if (notifications.isEmpty) {
                              return Center(
                                child: Text(
                                  "No Notifications Found",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontSize: 14,
                                      fontFamily: AppFonts.helveticaBold),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: notifications.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: AppColors.greyColor.withOpacity(0.4),
                              ),
                              itemBuilder: (context, index) {
                                return NotificationTile(notifications[index]);
                              },
                            );
                          }),
                        ],
                      ),
                    );
        }),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Notifications data;

  const NotificationTile(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        leading: data.type == 'group'
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group, color: AppColors.whiteColor),
              )
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.purple,
                  size: 30,
                ),
              ),
        title: Text(
          data.title ?? 'No Title',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        subtitle: Text(
          data.message ?? 'No Message',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        trailing: Text(
          _formatTime(data.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        onTap: () async {
          // Mark as read if unread
          if (!(data.isRead ?? true) && data.sId != null) {
            await controller.markNotificationRead(data.sId!);
            controller.notifications.refresh();
          }
          final type = data.type?.toLowerCase() ?? '';
          final title = (data.title ?? '').toLowerCase();
          final message = (data.message ?? '').toLowerCase();

          if (type == 'xp') {
            Get.toNamed(RouteName.streakExploreScreen);
          } else if (type == 'social') {
            if (title.contains('follower') ||
                message.contains('started following')) {
              final userId = data.fromUserId;

              // Validate userId before navigation
              if (userId != null && userId.isNotEmpty && userId != 'null') {
                Get.toNamed(RouteName.clipProfieScreen, arguments: userId);
              } else {
                Get.snackbar(
                  'Info',
                  'Old Comment is Depricated',
                  backgroundColor: AppColors.blueColor,
                  colorText: AppColors.whiteColor,
                );
              }
            } else if (title.contains('comment') ||
                message.contains('commented')) {
              // Comment Notification
              final clipId = data.clipId;

              if (clipId != null) {
                Get.toNamed(RouteName.clipPlayScreen, arguments: clipId);
              } else {
                Get.snackbar('Info', 'Clip details not available',
                    backgroundColor: Colors.orange);
                Get.toNamed(RouteName.reelsPage);
              }
            } else if (title.contains('mention') ||
                message.contains('mentioned')) {
              final clipId = data.clipId;
              //  Mention Notification
              Get.toNamed(RouteName.clipPlayScreen, arguments: clipId);
            } else if (title.contains('clip uploaded')) {
              final clipId = data.clipId;
              //  Clip Uploaded Notification
              Get.toNamed(RouteName.clipPlayScreen, arguments: clipId);
            } else {
              Get.toNamed(
                RouteName.clipProfieScreen,
              );
            }
          } else if (type == 'avatar') {
            Get.toNamed(RouteName.usersAvatarScreen);
          } else if (type == 'level_up') {
            Get.toNamed(RouteName.profileScreen);
          } else if (type == 'creator_request_approved') {
            Get.toNamed(RouteName.profileScreen);
          } else if (type == 'level_up') {
            Get.toNamed(RouteName.profileScreen);
          } else {
            //  Default fallback
            Get.snackbar(
              'Info',
              'Old Comment is Depricated',
              backgroundColor: AppColors.blueColor,
              colorText: AppColors.whiteColor,
            );
          }
        });
  }
}

String _formatTime(String? createdAt) {
  if (createdAt == null) return '';
  final dateTime = DateTime.parse(createdAt).toLocal();
  final formatter = DateFormat('MMM d, h:mm a');
  return formatter.format(dateTime);
}

Widget _buildTab({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      height: 30,
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.only(left: 60, top: 8, right: 60),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
            fontFamily: AppFonts.opensansRegular),
      ),
    ),
  );
}
