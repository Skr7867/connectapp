import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../res/fonts/app_fonts.dart';

class StreakExploreScreen extends StatelessWidget {
  const StreakExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Get.put(UserProfileController());
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    final dayMapping = {
      'Sun': 'Sunday',
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Streak Dashboard',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Enhanced Streak Card
              Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepOrange.withOpacity(0.1),
                          Colors.orange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.deepOrange.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          children: [
                            // Streak Header
                            _buildStreakHeader(
                                context, userData, screenWidth, screenHeight),

                            SizedBox(height: screenHeight * 0.03),

                            // Days of Week
                            _buildDaysOfWeek(context, userData, dayMapping,
                                screenWidth, screenHeight, orientation),

                            SizedBox(height: screenHeight * 0.025),

                            // Decorative Divider
                            Container(
                              height: 1,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.deepOrange.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.025),

                            // XP Display
                            _buildXPDisplay(context, userData, screenWidth),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Badges Section Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrange.withOpacity(0.2),
                            Colors.orange.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        PhosphorIconsFill.medal,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recently Earned Badges',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: AppFonts.opensansRegular,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Badges List
              _buildBadgesList(context, userData, screenWidth, screenHeight),

              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakHeader(BuildContext context,
      UserProfileController userData, double screenWidth, double screenHeight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Transform.rotate(
                      angle: value * 0.5,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsFill.fire,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Current Streak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.opensansRegular,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Obx(() {
            final user = userData.userList.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.maxStreak ?? 0}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                    height: 1,
                  ),
                ),
                Text(
                  'Days',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek(
      BuildContext context,
      UserProfileController userData,
      Map<String, String> dayMapping,
      double screenWidth,
      double screenHeight,
      Orientation orientation) {
    return SizedBox(
      height: orientation == Orientation.portrait
          ? screenHeight * 0.12
          : screenHeight * 0.22,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, int index) {
          final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          final fullDayName = dayMapping[days[index]] ?? '';

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Obx(() {
              final user = userData.userList.value;
              final activeDays = user.activeDaysInWeek ?? [];
              final isActive = activeDays.contains(fullDayName);

              return Container(
                width: screenWidth * 0.125,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        color: isActive
                            ? Colors.deepOrange
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        fontFamily: AppFonts.opensansRegular,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isActive
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.deepOrange,
                                  Colors.orange.shade600,
                                ],
                              )
                            : null,
                        color: isActive ? null : Colors.grey.withOpacity(0.2),
                        border: Border.all(
                          color: isActive
                              ? Colors.deepOrange.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.deepOrange.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          PhosphorIconsFill.fire,
                          color: isActive
                              ? Colors.white
                              : Colors.grey.withOpacity(0.4),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildXPDisplay(BuildContext context, UserProfileController userData,
      double screenWidth) {
    return Obx(() {
      final user = userData.userList.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.teal.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsFill.lightning,
                color: Colors.green.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Total XP',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.teal.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${user.xp} XP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBadgesList(BuildContext context, UserProfileController userData,
      double screenWidth, double screenHeight) {
    return Obx(() {
      final badges = userData.userList.value.badges ?? [];

      if (badges.isEmpty) {
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenHeight * 0.05),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.1),
                  Colors.grey.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIconsFill.medal,
                  size: 64,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  "No badges earned yet",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.6),
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Keep going to earn your first badge!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.4),
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepOrange.withOpacity(0.05),
                    Colors.orange.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.deepOrange.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange.withOpacity(0.3),
                        Colors.orange.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        badge.iconUrl != null && badge.iconUrl!.isNotEmpty
                            ? NetworkImage(badge.iconUrl!)
                            : const AssetImage(ImageAssets.defaultProfileImg)
                                as ImageProvider,
                  ),
                ),
                title: Text(
                  badge.name ?? "Unnamed Badge",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: AppFonts.opensansRegular,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: -0.3,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    badge.description ?? "",
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange.withOpacity(0.2),
                        Colors.orange.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsFill.checkCircle,
                    color: Colors.deepOrange,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
