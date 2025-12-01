import 'package:connectapp/models/Leaderboard/leaderboard_response_model.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class FullLeaderboardScreen extends StatelessWidget {
  final List<LeaderboardUserModel> leaderboard;

  const FullLeaderboardScreen({
    super.key,
    required this.leaderboard,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    final List<Color> rankColors = [
      Colors.amber, // Rank 1
      Colors.grey, // Rank 2
      Colors.pink, // Rank 3
      Colors.blue, // Rank 4
      Colors.green, // Rank 5
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Full Leaderboard',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: leaderboard.isEmpty
            ? Center(
                child: Text(
                  'No users found',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];
                  final initials = user.fullName
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .map((e) => e[0])
                      .take(2)
                      .join()
                      .toUpperCase();
                  final badge = 'Level ${user.level}';

                  return Column(
                    children: [
                      ListTile(
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.buttonColor,
                              child: user.avatar.imageUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        user.avatar.imageUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Text(
                                          initials.isNotEmpty ? initials : '?',
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontFamily:
                                                AppFonts.opensansRegular,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      initials.isNotEmpty ? initials : '?',
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontFamily: AppFonts.opensansRegular,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: screenHeight * 0.02,
                              right: -1,
                              child: Container(
                                height: screenHeight * 0.04,
                                width: screenWidth * 0.04,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.blackColor, width: 1),
                                  color: rankColors[index % rankColors.length],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${user.rank}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: AppFonts.opensansRegular,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${user.xp} XP',
                          style: TextStyle(
                            fontSize: 14,
                            color: rankColors[index % rankColors.length],
                            fontFamily: AppFonts.opensansRegular,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Container(
                          height: orientation == Orientation.portrait
                              ? screenHeight * 0.03
                              : screenHeight * 0.05,
                          width: orientation == Orientation.portrait
                              ? screenWidth * 0.3
                              : screenWidth * 0.17,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: rankColors[index % rankColors.length]
                                .withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: rankColors[index % rankColors.length],
                                fontFamily: AppFonts.opensansRegular,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index < leaderboard.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            color: Colors.grey.withOpacity(0.3),
                            thickness: 0.7,
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
