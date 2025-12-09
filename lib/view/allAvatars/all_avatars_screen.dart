import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/view_models/controller/allAvatars/all_avatar_controller.dart';
import 'package:connectapp/view_models/controller/allAvatars/purchase_avatar_controller.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';
import 'package:connectapp/view_models/controller/useravatar/user_avatar_controller.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';

class AllAvatarsScreen extends StatefulWidget {
  const AllAvatarsScreen({super.key});

  @override
  State<AllAvatarsScreen> createState() => _AllAvatarsScreenState();
}

class _AllAvatarsScreenState extends State<AllAvatarsScreen>
    with TickerProviderStateMixin {
  final AllAvatarController controller = Get.put(AllAvatarController());
  final PurchaseAvatarController purchaseController =
      Get.put(PurchaseAvatarController());
  final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
  final ScrollController _scrollController = ScrollController();
  final userCoins = Get.find<UserProfileController>();

  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  String? token;
  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await userPreferences.getUser();
      setState(() {
        token = user?.token;
      });
      if (token != null) {
        controller.fetchAvatars(token!, isRefresh: false);
        Get.find<UserAvatarController>().fetchUserAvatars(isRefresh: false);
        _headerAnimationController.forward();
      } else {
        _showErrorSnackbar('Please log in to view avatars.');
      }
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!controller.isLoading.value &&
          controller.hasMore.value &&
          token != null) {
        controller.fetchAvatars(token!);
      }
    }
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

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    Get.delete<AllAvatarController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Avatar Collection',
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          // User coins display
          Obx(() {
            final coins = userCoins.userList.value.wallet?.coins ?? 0;
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$coins',
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
          if (token != null) {
            await controller.fetchAvatars(token!, isRefresh: true);
            await Get.find<UserAvatarController>()
                .fetchUserAvatars(isRefresh: true);
          } else {
            _showErrorSnackbar('Please log in to refresh avatars.');
          }
        },
        child: Obx(() {
          if (controller.isLoading.value && controller.avatars.isEmpty) {
            return _buildLoadingState();
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.avatars.isEmpty) {
            return _buildErrorState();
          }

          final activeAvatars = controller.avatars
              .where((avatar) => avatar.isActive == true)
              .toList();

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Animated Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerAnimation,
                  child: _buildHeader(activeAvatars.length),
                ),
              ),

              // Grid of Avatars
              SliverPadding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(orientation, isTablet),
                    crossAxisSpacing: isTablet ? 20 : 12,
                    mainAxisSpacing: isTablet ? 20 : 12,
                    childAspectRatio: isTablet ? 0.45 : 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= activeAvatars.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: AppColors.buttonColor,
                            ),
                          ),
                        );
                      }

                      final avatar = activeAvatars[index];
                      return _buildAvatarCard(avatar, index);
                    },
                    childCount: activeAvatars.length +
                        (controller.hasMore.value ? 1 : 0),
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

  Widget _buildHeader(int totalAvatars) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.buttonColor.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.buttonColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.face_retouching_natural,
                  color: AppColors.buttonColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Avatars',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalAvatars premium avatars available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: AppFonts.opensansRegular,
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

  Widget _buildAvatarCard(dynamic avatar, int index) {
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.greyColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showAvatarDetails(avatar),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar Image with Badge
                    _buildAvatarImage(avatar),

                    const SizedBox(height: 10),

                    // Avatar Name
                    Text(
                      avatar.name ?? 'Unknown',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Premium Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.orange.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            avatar.isActive == true ? 'Premium' : 'Basic',
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

                    const SizedBox(height: 12),

                    // Purchase Button
                    _buildPurchaseButton(avatar),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(dynamic avatar) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.buttonColor.withOpacity(0.3),
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
              colors: [
                AppColors.buttonColor.withOpacity(0.3),
                Colors.purple.withOpacity(0.3),
              ],
            ),
            border: Border.all(
              color: AppColors.buttonColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor.withOpacity(0.4),
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

        // Coin badge
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade600, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  '${avatar.coins ?? 0}',
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
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(dynamic avatar) {
    return Obx(() {
      final isPurchasing =
          purchaseController.isAvatarPurchasing(avatar.sId.toString());
      final isPurchased = Get.find<UserAvatarController>()
          .isAvatarPurchased(avatar.sId.toString());
      final requiredCoins = avatar.coins ?? 0;
      final userCurrentCoins = userCoins.userList.value.wallet?.coins ?? 0;
      final canAfford = userCurrentCoins >= requiredCoins;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPurchased
                ? [Colors.grey.shade600, Colors.grey.shade700]
                : canAfford
                    ? [Colors.purple.shade600, Colors.purple.shade800]
                    : [Colors.red.shade400, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isPurchased
                  ? Colors.grey.withOpacity(0.3)
                  : canAfford
                      ? Colors.purple.withOpacity(0.4)
                      : Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isPurchasing || isPurchased || !canAfford
                ? null
                : () {
                    purchaseController.purchaseAvatar(
                      avatar.sId.toString(),
                      requiredCoins,
                      token,
                      isPurchased: isPurchased,
                    );
                  },
            child: Container(
              alignment: Alignment.center,
              child: isPurchasing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPurchased
                              ? Icons.check_circle
                              : canAfford
                                  ? Icons.shopping_bag
                                  : Icons.lock,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPurchased
                              ? 'Owned'
                              : requiredCoins == 0
                                  ? 'Free'
                                  : canAfford
                                      ? 'Buy for $requiredCoins'
                                      : 'Need $requiredCoins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
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
            'Loading Avatars...',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your avatars',
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
              controller.errorMessage.value,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontFamily: AppFonts.opensansRegular,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (token != null) {
                  controller.fetchAvatars(token!, isRefresh: true);
                  Get.find<UserAvatarController>()
                      .fetchUserAvatars(isRefresh: true);
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

  void _showAvatarDetails(dynamic avatar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            _buildAvatarImage(avatar),
            const SizedBox(height: 20),
            Text(
              avatar.name ?? 'Unknown Avatar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.buttonColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Type',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        avatar.isActive == true ? 'Premium' : 'Basic',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      Text(
                        'Price',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
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
                              fontSize: 16,
                              fontFamily: AppFonts.opensansRegular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _buildPurchaseButton(avatar),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
