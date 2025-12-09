import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/view_models/controller/useravatar/user_avatar_controller.dart';
import '../../models/UserAvatar/user_avatar_model.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';

class UserAvatarScreen extends StatefulWidget {
  const UserAvatarScreen({super.key});

  @override
  State<UserAvatarScreen> createState() => _UserAvatarScreenState();
}

class _UserAvatarScreenState extends State<UserAvatarScreen>
    with TickerProviderStateMixin {
  final UserAvatarController userAvatarController =
      Get.put(UserAvatarController());
  final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();

  late AnimationController _headerAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'My Avatars',
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          Obx(() {
            final totalAvatars = userAvatarController.purchasedAvatars.length;
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.collections,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalAvatars',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.buttonColor,
        onRefresh: () async {
          final user = await userPreferences.getUser();
          final token = user?.token;
          if (token != null) {
            await userAvatarController.fetchUserAvatars(isRefresh: true);
          } else {
            _showErrorSnackbar('Please log in to refresh avatars.');
          }
        },
        child: Obx(() {
          if (userAvatarController.isLoading.value &&
              userAvatarController.purchasedAvatars.isEmpty) {
            return _buildLoadingState();
          }

          if (userAvatarController.errorMessage.value.isNotEmpty &&
              userAvatarController.purchasedAvatars.isEmpty) {
            return _buildErrorState();
          }

          if (userAvatarController.purchasedAvatars.isEmpty) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Current Avatar Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerAnimation,
                  child: _buildCurrentAvatarHeader(),
                ),
              ),

              // Collection Info
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerAnimation,
                  child: _buildCollectionInfo(),
                ),
              ),

              // Avatar Grid
              SliverPadding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(orientation, isTablet),
                    crossAxisSpacing: isTablet ? 20 : 12,
                    mainAxisSpacing: isTablet ? 20 : 12,
                    childAspectRatio: isTablet ? 0.5 : 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final avatar =
                          userAvatarController.purchasedAvatars[index];
                      return _buildAvatarCard(avatar, index);
                    },
                    childCount: userAvatarController.purchasedAvatars.length,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  int _getCrossAxisCount(Orientation orientation, bool isTablet) {
    if (isTablet) {
      return orientation == Orientation.portrait ? 3 : 5;
    }
    return orientation == Orientation.portrait ? 2 : 3;
  }

  Widget _buildCurrentAvatarHeader() {
    return Obx(() {
      final currentAvatar = userAvatarController.currentAvatar.value;
      if (currentAvatar == null) return const SizedBox.shrink();

      // Find the matching purchased avatar to get coins
      final purchasedAvatar = userAvatarController.purchasedAvatars.firstWhere(
        (avatar) => avatar.sId == currentAvatar.sId,
        orElse: () => PurchasedAvatars(
          sId: currentAvatar.sId,
          name: currentAvatar.name,
          imageUrl: currentAvatar.imageUrl,
          coins: 0, // Default value
        ),
      );

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade400,
              Colors.teal.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Current Avatar Image with Pulse Animation
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: currentAvatar.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: currentAvatar.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            ImageAssets.javaIcon,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          ImageAssets.javaIcon,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentAvatar.name ?? 'Current Avatar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${purchasedAvatar.coins ?? 0} Coins Value', // Use coins from purchasedAvatar
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCollectionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 39, 9, 233).withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.collections_bookmark,
              color: AppColors.buttonColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Collection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap any avatar to make it active',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(dynamic avatar, int index) {
    final isCurrentAvatar =
        userAvatarController.currentAvatar.value?.sId == avatar.sId;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: userAvatarController.isUpdating.value
            ? null
            : () async {
                if (!isCurrentAvatar) {
                  await userAvatarController.updateCurrentAvatar(avatar.sId!);
                  _showSuccessSnackbar('Avatar updated successfully!');
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: isCurrentAvatar
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade400.withOpacity(0.2),
                      Colors.teal.shade400.withOpacity(0.2),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrentAvatar
                  ? Colors.green.shade400
                  : AppColors.greyColor.withOpacity(0.3),
              width: isCurrentAvatar ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isCurrentAvatar
                    ? Colors.green.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isCurrentAvatar ? 20 : 15,
                offset: const Offset(0, 5),
                spreadRadius: isCurrentAvatar ? 2 : -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: userAvatarController.isUpdating.value
                    ? null
                    : () async {
                        if (!isCurrentAvatar) {
                          await userAvatarController
                              .updateCurrentAvatar(avatar.sId!);
                          _showSuccessSnackbar('Avatar updated successfully!');
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar Image
                      _buildAvatarImage(avatar, isCurrentAvatar),

                      const SizedBox(height: 12),

                      // Avatar Name
                      Text(
                        avatar.name ?? 'Unknown',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: isCurrentAvatar
                              ? LinearGradient(
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.teal.shade400,
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.purple.shade400,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isCurrentAvatar
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCurrentAvatar
                                  ? Icons.check_circle
                                  : Icons.touch_app,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isCurrentAvatar ? 'Active' : 'Tap to Use',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Coins Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${avatar.coins ?? 0}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(dynamic avatar, bool isCurrentAvatar) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (isCurrentAvatar)
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.green.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),

        // Avatar container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCurrentAvatar
                  ? [
                      Colors.green.withOpacity(0.3),
                      Colors.teal.withOpacity(0.3),
                    ]
                  : [
                      AppColors.buttonColor.withOpacity(0.3),
                      Colors.purple.withOpacity(0.3),
                    ],
            ),
            border: Border.all(
              color: isCurrentAvatar ? Colors.green : AppColors.buttonColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: isCurrentAvatar
                    ? Colors.green.withOpacity(0.4)
                    : AppColors.buttonColor.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: avatar.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatar.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.buttonColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      ImageAssets.javaIcon,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    ImageAssets.javaIcon,
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        // Active indicator
        if (isCurrentAvatar)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.buttonColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppColors.buttonColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Your Avatars...',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your collection',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              userAvatarController.errorMessage.value,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontFamily: AppFonts.opensansRegular,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final user = await userPreferences.getUser();
                final token = user?.token;
                if (token != null) {
                  await userAvatarController.fetchUserAvatars(isRefresh: true);
                } else {
                  _showErrorSnackbar('Please log in to retry.');
                }
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.opensansRegular,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.buttonColor.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.face_retouching_natural,
                color: AppColors.buttonColor,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Avatars Yet',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t purchased any avatars yet.\nVisit the Avatar Collection to get started!',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontFamily: AppFonts.opensansRegular,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.shopping_bag, color: Colors.white),
              label: const Text(
                'Browse Avatars',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.opensansRegular,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
