// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:connectapp/res/component/round_button.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view/userSelfProfile/widgets/user_profile_container_widget.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/response/status.dart';
import '../../res/assets/image_assets.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/CREATORPANEL/CreatorController/creator_controller.dart';
import '../../view_models/CREATORPANEL/CreatorController/switch_creator_controller.dart';
import 'widgets/archive_clips_widgets.dart';
import 'widgets/my_clips_widgets.dart';
import 'widgets/repost_clips_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // *******************************************User profile container*******************************************************//
                  UserProfileContainerWidget(),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorColor: Theme.of(context).textTheme.bodyLarge?.color,
                  labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                  labelPadding: ResponsivePadding.symmetricPadding(context,
                      horizontal: 4),
                  tabs: [
                    Tab(
                      icon: Icon(PhosphorIconsRegular.user),
                      text: 'about'.tr,
                    ),
                    Tab(
                        icon: Icon(PhosphorIconsRegular.videoCamera),
                        text: 'Clips'),
                    Tab(
                        icon: Icon(PhosphorIconsRegular.archive),
                        text: 'Archive'),
                    Tab(
                        icon: Icon(PhosphorIconsRegular.repeat),
                        text: 'Reposts'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // About Tab
            _buildAboutTab(),
            // MyClips
            buildStatsTab(context),
            // Archive Tabs Tab
            archiveClipsTab(context),
            // Reposts Clips
            repostClipsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    final userData = Get.put(UserProfileController());
    double screenHeight = MediaQuery.of(context).size.height;

    // Orientation orientation = MediaQuery.of(context).orientation;

    return SingleChildScrollView(
      child: Padding(
        padding: ResponsivePadding.symmetricPadding(context,
            horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              // margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  // gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.greyColor.withOpacity(0.4))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "bio".tr,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: AppFonts.helveticaBold),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    switch (userData.rxRequestStatus.value) {
                      case Status.LOADING:
                        return const Text(
                          "Loading...",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor,
                          ),
                        );
                      case Status.ERROR:
                        return Text(
                          "bio_desc".tr,
                        );
                      case Status.COMPLETED:
                        final bio = userData.userList.value.bio;
                        return Text(
                          (bio == null || bio.isEmpty) ? "bio_desc".tr : bio,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        );
                    }
                  }),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "email".tr,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      Obx(() {
                        switch (userData.rxRequestStatus.value) {
                          case Status.LOADING:
                            return const Text(
                              "Loading...",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFonts.opensansRegular,
                                fontWeight: FontWeight.bold,
                                color: AppColors.whiteColor,
                              ),
                            );
                          case Status.ERROR:
                            return const Text("Null");

                          case Status.COMPLETED:
                            final email = userData.userList.value.email;
                            String shortenedEmail;

                            if (email!.contains('@')) {
                              final parts = email.split('@');
                              final username = parts[0];
                              final domain = parts[1];
                              final shortUsername = username.length > 5
                                  ? '${username.substring(0, 5)}...'
                                  : username;
                              shortenedEmail = '$shortUsername@$domain';
                            } else {
                              shortenedEmail = email.length > 20
                                  ? '${email.substring(0, 17)}...'
                                  : email;
                            }

                            return Text(
                              shortenedEmail,
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            );
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("member_since".tr,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular,
                          )),
                      Obx(() {
                        String formattedDate = 'N/A';
                        try {
                          if (userData.userList.value.createdAt!.isNotEmpty) {
                            final dateTime = DateTime.parse(
                                userData.userList.value.createdAt!);
                            formattedDate =
                                DateFormat('dd-MM-yyyy').format(dateTime);
                          }
                        } catch (e) {
                          log('Error parsing date: $e');
                        }
                        switch (userData.rxRequestStatus.value) {
                          case Status.LOADING:
                            return const Text(
                              "Loading...",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFonts.opensansRegular,
                                fontWeight: FontWeight.bold,
                                color: AppColors.whiteColor,
                              ),
                            );
                          case Status.ERROR:
                            return const Text("Null");
                          case Status.COMPLETED:
                            return Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            );
                        }
                      }),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Obx(() {
              final creatorController = Get.find<CreatorController>();
              final switchController = Get.find<CreatorModeController>();

              if (userData.userList.value.isAlreadyCreator == true) {
                // SHOW THE SWITCH
                return Container(
                  padding: ResponsivePadding.symmetricPadding(context,
                      horizontal: 1),
                  // margin: const EdgeInsets.only(right: 15, bottom: 8),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.greyColor.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      'Creator Mode',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.helveticaBold,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    subtitle: Text(
                      'Switch Mode',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: AppColors.greenColor),
                    ),
                    trailing: Stack(
                      alignment: Alignment.center,
                      children: [
                        Switch(
                          value: switchController.isCreatorMode.value,
                          onChanged: switchController.isLoading.value
                              ? null
                              : (_) {
                                  switchController.toggleCreatorMode();
                                },
                        ),
                        if (switchController.isLoading.value)
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.whiteColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                // SHOW BECOME CREATOR BUTTON
                if (creatorController.isRequestSubmitted.value == true) {
                  return Container(
                    padding: ResponsivePadding.symmetricPadding(context,
                        horizontal: 4),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.greyColor.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      title: Text(
                        'Your Request send sucessfully',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.helveticaBold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        "Wait for Admin approval",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: AppFonts.opensansRegular,
                            color: AppColors.greyColor),
                      ),
                      trailing: RoundButton(
                        height: 35,
                        fontSize: 12,
                        width: 100,
                        buttonColor: AppColors.blackColor,
                        title: 'Submitted',
                        onPress: () {},
                      ),
                    ),
                  );
                } else {
                  return Container(
                    padding: ResponsivePadding.symmetricPadding(context,
                        horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.greyColor.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      title: Text(
                        'Become Creator',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.helveticaBold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: const Text(
                        "You'll be creator after your\nRequest is approved",
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: RoundButton(
                        height: 35,
                        fontSize: 12,
                        width: 100,
                        buttonColor: AppColors.blackColor,
                        title: 'Send Request',
                        onPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final TextEditingController reasonController =
                                  TextEditingController();

                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  "Why do you want to become a creator?*",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.opensansRegular,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                                content: TextField(
                                  cursorHeight: 25,
                                  cursorColor: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  controller: reasonController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Tell us why you want to become a creator...",
                                    hintStyle: TextStyle(
                                      fontFamily: AppFonts.opensansRegular,
                                      fontSize: 16,
                                      color: AppColors.greyColor,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontFamily: AppFonts.opensansRegular,
                                        fontSize: 16,
                                        color: AppColors.redColor,
                                      ),
                                    ),
                                  ),
                                  Obx(() => ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.blackColor,
                                        ),
                                        onPressed: creatorController
                                                .isLoading.value
                                            ? null
                                            : () {
                                                creatorController.becomeCreator(
                                                  reason: reasonController.text,
                                                );
                                              },
                                        child: creatorController.isLoading.value
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text(
                                                "Submit",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      )),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
              }
            }),
            SizedBox(height: screenHeight * 0.02),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.greyColor.withOpacity(0.4))),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6A11CB),
                        Color(0xFF2575FC),
                        Color(0xFF00C6FF),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: AppColors.whiteColor,
                  ),
                ),
                title: Text(
                  'Premium Member',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.helveticaBold,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                subtitle: Text(
                  'Active Subscription',
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: AppColors.greyColor,
                  ),
                ),
                trailing: Obx(() {
                  switch (userData.rxRequestStatus.value) {
                    case Status.LOADING:
                      return Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: AppFonts.opensansRegular,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      );
                    case Status.ERROR:
                      return const Text("Null");
                    case Status.COMPLETED:
                      return (userData.userList.value.subscription?.status ==
                              "Active")
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.greenColor,
                            )
                          : Icon(
                              Icons.close_rounded,
                              color: AppColors.redColor,
                            );
                  }
                }),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                SizedBox(width: 10),
                Text(
                  'Social Links',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.helveticaBold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Obx(() {
              final socialLinks = userData.userList.value.socialLinks;

              // Extract links safely
              final twitter = socialLinks?.twitter ?? "";
              final instagram = socialLinks?.instagram ?? "";
              final linkedin = socialLinks?.linkedin ?? "";
              final website = socialLinks?.website ?? "";

              // Build only if available
              List<Widget> links = [];
              if (instagram.isNotEmpty) {
                links.add(_buildSocialLink(
                    ImageAssets.instagram, "Instagram", instagram, context));
                links.add(Divider(color: AppColors.greyColor.withOpacity(0.4)));
              }
              if (twitter.isNotEmpty) {
                links.add(_buildSocialLink(
                    ImageAssets.twitterIcon, "X", twitter, context));
                links.add(Divider(color: AppColors.greyColor.withOpacity(0.4)));
              }
              if (linkedin.isNotEmpty) {
                links.add(_buildSocialLink(
                    ImageAssets.linkedin, "LinkedIn", linkedin, context));
                links.add(Divider(color: AppColors.greyColor.withOpacity(0.4)));
              }
              if (website.isNotEmpty) {
                links.add(_buildSocialLink(
                    ImageAssets.website, "Website", website, context));
              }

              // If no links at all
              if (links.isEmpty) {
                links.add(
                  Text(
                    "No social links available",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                        fontFamily: AppFonts.opensansRegular),
                  ),
                );
              }

              return _buildCard(
                child: Column(children: links),
              );
            }),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                SizedBox(width: 10),
                Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.helveticaBold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.greyColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(
                    Icons.flash_on,
                    "Total XP",
                    Obx(() {
                      switch (userData.rxRequestStatus.value) {
                        case Status.LOADING:
                          return SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: AppColors.blackColor,
                            ),
                          );
                        case Status.ERROR:
                          return const Text("No XP");
                        case Status.COMPLETED:
                          return Text(
                            userData.userList.value.xp.toString(),
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: AppFonts.opensansRegular,
                                color: AppColors.greyColor),
                          );
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: AppColors.greyColor.withOpacity(0.4)),
                  _buildStatRow(
                    Icons.adjust,
                    "Level",
                    Obx(() {
                      switch (userData.rxRequestStatus.value) {
                        case Status.LOADING:
                          return SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          );
                        case Status.ERROR:
                          return const Text("No Level");
                        case Status.COMPLETED:
                          return Text(
                            userData.userList.value.level.toString(),
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: AppFonts.opensansRegular,
                                color: AppColors.greyColor),
                          );
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: AppColors.greyColor.withOpacity(0.4)),
                  _buildStatRow(
                    Icons.monetization_on,
                    "Coins",
                    Obx(() {
                      switch (userData.rxRequestStatus.value) {
                        case Status.LOADING:
                          return SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: AppColors.greyColor,
                            ),
                          );
                        case Status.ERROR:
                          return const Text("No Coins");
                        case Status.COMPLETED:
                          return Text(
                            userData.userList.value.wallet!.coins.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: AppFonts.opensansRegular,
                              color: AppColors.greyColor,
                            ),
                          );
                      }
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.helveticaBold,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        valueWidget, // <-- Here we show widget instead of String
      ],
    );
  }

  static Widget _buildSocialLink(
      String imagePath, String label, String link, context) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.blackColor,
            ),
            child: Image.asset(
              imagePath,
              width: 22,
              height: 22,
              color: AppColors.whiteColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                const SizedBox(height: 2),
                Text(link,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

Widget _buildCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
