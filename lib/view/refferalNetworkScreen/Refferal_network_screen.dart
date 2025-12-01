import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/response/status.dart';
import '../../res/assets/image_assets.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/profile/user_profile_controller.dart';
import '../../view_models/controller/refferalnetwork/refferal_network_controller.dart';
import '../../models/ReffrealNetworkModel/refferals_network_model.dart';

class ReferralNetworkScreen extends StatelessWidget {
  final RefferalNetworkController controller =
      Get.put(RefferalNetworkController());

  ReferralNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;
    // Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Obx(() {
        if (controller.rxRequestStatus.value == Status.LOADING) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.rxRequestStatus.value == Status.ERROR) {
          return Center(
            child: Text(controller.error.value,
                style: const TextStyle(color: Colors.white)),
          );
        }

        final List<ReferralNode> rootNodes =
            controller.userNetwork.value.hierarchy;

        return InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(200),
          maxScale: 2.5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Root "You"
                _youNode(context),
                // const SizedBox(height: 12),
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: AppColors.exploreGradient,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: (rootNodes.length * 95).toDouble(),
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: AppColors.exploreGradient,
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: 12),
                // Children of "You"
                if (rootNodes.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: rootNodes
                        .map(
                          (n) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _buildPerson(n),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _youNode(context) {
    final userData = Get.put(UserProfileController());
    return Column(
      children: [
        Obx(() {
          switch (userData.rxRequestStatus.value) {
            case Status.LOADING:
              return Image.asset(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                ImageAssets.profileIcon,
                fit: BoxFit.cover,
                width: 25,
                height: 25,
              );
            case Status.ERROR:
              return CircleAvatar(
                radius: 25,
                child: IconButton(
                  onPressed: () {
                    Get.toNamed(RouteName.profileScreen);
                  },
                  icon: Image.asset(ImageAssets.profileIcon),
                ),
              );
            case Status.COMPLETED:
              final imageUrl = userData.userList.value.avatar?.imageUrl;
              return IconButton(
                onPressed: () {
                  Get.toNamed(RouteName.profileScreen);
                },
                icon: imageUrl?.isNotEmpty == true
                    ? Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.buttonColor, width: 4),
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      )
                    : Image.asset(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        ImageAssets.profileIcon,
                        fit: BoxFit.cover,
                        width: 25,
                        height: 25,
                      ),
              );
          }
        }),
        Container(
          height: 30,
          width: 60,
          decoration: BoxDecoration(
            gradient: AppColors.exploreGradient,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              'You',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: AppFonts.opensansRegular,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPerson(ReferralNode node) {
    final String title =
        node.fullName ?? node.username ?? node.email ?? 'Unknown';
    final String subtitle =
        node.username ?? node.username ?? node.email ?? 'Unknown';

    return Column(
      children: [
        // connector up
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.exploreGradient,
          ),
        ),
        _avatarWithName(title, node.avatar?.imageUrl, subtitle),
        if (node.downline.isNotEmpty) ...[
          // horizontal connectors row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container(width: 2, height: 20, color: Colors.blue),
              const SizedBox(width: 4),
              // Container(
              //     width: 60.0 * node.downline.length,
              //     height: 2,
              //     color: Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: node.downline
                .map((child) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildPerson(child),
                    ))
                .toList(),
          ),
        ],

        // if (node.downline.isNotEmpty) ...[
        //   Container(
        //     width: (node.downline.length * 80).toDouble(),
        //     height: 3,
        //     decoration: BoxDecoration(
        //       gradient: AppColors.exploreGradient,
        //     ),
        //   ),
        //   Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: node.downline
        //         .map((child) => Padding(
        //               padding: const EdgeInsets.symmetric(horizontal: 12),
        //               child: _buildPerson(child),
        //             ))
        //         .toList(),
        //   ),
        // ],
      ],
    );
  }

  Widget _avatarWithName(String title, String? imageUrl, String subtitle) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal,
          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
              ? NetworkImage(imageUrl)
              : null,
          child: (imageUrl == null || imageUrl.isEmpty)
              ? Text(
                  _initials(title),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: AppFonts.opensansRegular),
                )
              : null,
        ),
        const SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            gradient: AppColors.exploreGradient,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: AppFonts.opensansRegular),
              ),
              Text(
                '@$subtitle',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: AppFonts.opensansRegular),
              ),
            ],
          ),
        )
      ],
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts[0].isNotEmpty ? parts[0][0] : '') +
        (parts[1].isNotEmpty ? parts[1][0] : '').toUpperCase();
  }
}
