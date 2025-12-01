import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/response/status.dart';
import '../../view_models/controller/searchUser/search_user_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunityMembersWidget extends StatefulWidget {
  final Function(User) onUserSelected;
  final VoidCallback? onClose;

  const CommunityMembersWidget({
    super.key,
    required this.onUserSelected,
    this.onClose,
  });

  @override
  State<CommunityMembersWidget> createState() => _CommunityMembersWidgetState();
}

class _CommunityMembersWidgetState extends State<CommunityMembersWidget> {
  @override
  Widget build(BuildContext context) {
    Get.put(SearchUsersController());
    final TextEditingController searchController = TextEditingController();

    return Obx(() {
      final controller = Get.find<SearchUsersController>();
      final bool hasSearched = searchController.text.isNotEmpty;
      final status = controller.rxRequestStatus.value;
      final errorMsg = controller.error.value;
      final isSearchLoading = controller.isLoading.value;

      if (errorMsg.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading data: $errorMsg')),
          );
          controller.error.value = '';
        });
      }

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Community Members',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontFamily: AppFonts.helveticaMedium),
                  ),
                  Spacer(),
                  if (widget.onClose != null)
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                ],
              ),
            ),
            // Search field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      cursorHeight: 20,
                      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'search user by name, username or email..',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: AppColors.greyColor,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                      onChanged: controller.searchUsers,
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: !hasSearched
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 48,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Search to connect with users',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.helveticaMedium),
                          ),
                        ],
                      ),
                    )
                  : isSearchLoading || status == Status.LOADING
                      ? Center(child: CircularProgressIndicator())
                      : status == Status.ERROR
                          ? Center(
                              child: Text('Error occurred while searching'))
                          : controller.users.isEmpty
                              ? Center(child: Text('No users found'))
                              : ListView.builder(
                                  itemCount: controller.users.length,
                                  itemBuilder: (context, index) {
                                    final modelUser = controller.users[index];
                                    final user =
                                        User.fromJson(modelUser.toJson());
                                    return InkWell(
                                      onTap: () =>
                                          _showUserDetails(context, user),
                                      child: UserCard(user: user),
                                    );
                                  },
                                ),
            ),
          ],
        ),
      );
    });
  }

  void _showUserDetails(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.greyColor),
            ),
            padding: EdgeInsets.all(24.0),
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar and name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (user.avatarUrl != null)
                          CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(user.avatarUrl!),
                            radius: 30,
                          )
                        else
                          CircleAvatar(
                            radius: 40,
                            child: Icon(Icons.person, size: 40),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              '${user.level}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontFamily: AppFonts.helveticaMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.isPremium)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber[400],
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: user.subscriptionFeatures
                                                ?.premiumIconUrl !=
                                            null
                                        ? Image.network(
                                            user.subscriptionFeatures!
                                                .premiumIconUrl!,
                                            width: 10,
                                            height: 10,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(Icons.star,
                                                        size: 20,
                                                        color: Colors.white),
                                          )
                                        : Icon(Icons.star,
                                            size: 20, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: user.isPremium
                                  ? Colors.amber[700]
                                  : Colors.grey[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '@${user.username}',
                              style: TextStyle(
                                color:
                                    user.isPremium ? Colors.red : Colors.white,
                                fontFamily: AppFonts.opensansRegular,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (user.isPremium)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.amber[200]!),
                                ),
                                child: Text(
                                  'Premium Member',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber[800],
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.opensansRegular),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Stats row
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.greyColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('${user.level} Level'),
                      _buildStatItem('${user.xp} XP'),
                      _buildStatItem('${user.coins} Coins'),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Achievements section (only shown in dialog)
                if (user.badges.isNotEmpty) ...[
                  Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: user.badges
                        .map((badge) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 10),
                                  SizedBox(width: 8),
                                  Text(badge.name),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 24),
                ],
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Connection request sent to ${user.fullName}')),
                          );
                        },
                        child: Text(
                          'Connect Request',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 12,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onUserSelected(user);
                        },
                        child: Text(
                          'Send Message',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.opensansRegular,
        fontSize: 16,
        color: Colors.amber[800],
      ),
    );
  }
}

// Keep your existing User, Badge, and UserCard classes as they are
class User {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String? avatarUrl;
  final int coins;
  final int xp;
  final int level;
  final List<Badge> badges;
  final Subscription? subscription;
  final SubscriptionFeatures? subscriptionFeatures;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.coins,
    required this.xp,
    required this.level,
    required this.badges,
    this.subscription,
    this.subscriptionFeatures,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Parsing user: ${json['fullName']}'); // Debug
    print('Subscription data: ${json['subscription']}'); // Debug
    print('Premium icon: ${json['subscriptionFeatures']?['premiumIconUrl']}');
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      username: json['username'] ?? '',
      email: json['email'],
      avatarUrl: json['avatar']?['imageUrl'],
      coins: json['wallet']['coins'],
      xp: json['xp'],
      level: json['level'],
      badges: (json['badges'] as List?)
              ?.map((badge) => Badge.fromJson(badge))
              .toList() ??
          [],
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
      subscriptionFeatures: json['subscriptionFeatures'] != null
          ? SubscriptionFeatures.fromJson(json['subscriptionFeatures'])
          : null,
    );
  }

  bool get isPremium {
    final isPremium = subscription?.status == 'Active';
    print('$fullName premium status: $isPremium'); // Debug
    return isPremium;
  }
}

class Subscription {
  final String? planId;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  Subscription({
    this.planId,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      planId: json['planId'],
      status: json['status'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class SubscriptionFeatures {
  final String? premiumIconUrl;

  SubscriptionFeatures({
    this.premiumIconUrl,
  });

  factory SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeatures(
      premiumIconUrl: json['premiumIconUrl'],
    );
  }
}

class Badge {
  final String id;
  final String name;

  Badge({required this.id, required this.name});

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyColor),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with level badge
            Stack(
              children: [
                if (user.avatarUrl != null)
                  CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(user.avatarUrl!),
                    radius: 30,
                  )
                else
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '${user.level}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      if (user.isPremium)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber[400],
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: user.subscriptionFeatures?.premiumIconUrl !=
                                    null
                                ? Image.network(
                                    user.subscriptionFeatures!.premiumIconUrl!,
                                    width: 16,
                                    height: 16,
                                  )
                                : Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: user.isPremium ? Colors.amber[700] : null,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: user.isPremium
                            ? Colors.red
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatItem('${user.coins} coins', context),
                      SizedBox(width: 16),
                      _buildStatItem('${user.xp} XP', context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String text, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.greyColor)),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.opensansRegular,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
