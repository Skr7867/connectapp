import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../view_models/controller/pendingFollowRequest/pending_follow_request_controller.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/controller/acceptFollowRequest/accept_follow_request_controller.dart';

class PendingFollowRequestScreen extends StatelessWidget {
  const PendingFollowRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PendingFollowRequestController());
    final followAccept = Get.put(AcceptFollowRequestController());
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pending Requests',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Obx(() {
          switch (controller.rxStatus.value) {
            case Status.LOADING:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading requests...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ],
                ),
              );

            case Status.ERROR:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            controller.fetchPendingFollowRequests(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

            case Status.COMPLETED:
              final requests = controller.requests;

              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.people_outline_rounded,
                            size: 80, color: AppColors.greyColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Pending Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Text(
                          'You\'re all caught up! No follow requests at the moment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchPendingFollowRequests(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${requests.length} ${requests.length == 1 ? 'Request' : 'Requests'}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'People who want to follow you',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // List of Requests
                    SliverPadding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final request = requests[index];
                            final fromUser = request.from;

                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 300 + (index * 50)),
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
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          AppColors.greyColor.withOpacity(0.4)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Avatar with Ring
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).primaryColor,
                                              Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.6),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF1A1A1A)
                                                : Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundColor: isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade200,
                                            backgroundImage: fromUser
                                                        ?.avatar?.imageUrl !=
                                                    null
                                                ? NetworkImage(
                                                    fromUser!.avatar!.imageUrl!)
                                                : null,
                                            child: fromUser?.avatar?.imageUrl ==
                                                    null
                                                ? Icon(
                                                    Icons.person,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                    size: 28,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // User Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fromUser?.fullName ??
                                                  'Unknown User',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '@${fromUser?.username ?? 'unknown'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.white54
                                                    : AppColors.greyColor,
                                                fontFamily:
                                                    AppFonts.opensansRegular,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action Buttons
                                      Obx(() {
                                        final isLoading = followAccept
                                            .processingUserIds
                                            .contains(fromUser?.sId);

                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Accept Button
                                            _ActionButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () async {
                                                      await followAccept
                                                          .respondFollowRequest(
                                                        action: "accept",
                                                        fromUserId:
                                                            fromUser!.sId!,
                                                      );
                                                      // Refresh the list
                                                      controller
                                                          .fetchPendingFollowRequests();
                                                    },
                                              isLoading: isLoading,
                                              icon: Icons.check_rounded,
                                              color: const Color(0xFF10B981),
                                              tooltip: 'Accept',
                                            ),
                                            const SizedBox(width: 8),

                                            // Reject Button
                                            _ActionButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () async {
                                                      await followAccept
                                                          .respondFollowRequest(
                                                        action: "reject",
                                                        fromUserId:
                                                            fromUser!.sId!,
                                                      );
                                                      // Refresh the list
                                                      controller
                                                          .fetchPendingFollowRequests();
                                                    },
                                              isLoading: false,
                                              icon: Icons.close_rounded,
                                              color: const Color(0xFFEF4444),
                                              tooltip: 'Reject',
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: requests.length,
                        ),
                      ),
                    ),

                    // Bottom Spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
              );
          }
        }),
      ),
    );
  }
}

// Custom Action Button Widget
class _ActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final Color color;
  final String tooltip;

  const _ActionButton({
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: widget.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onPressed,
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                      ),
                    )
                  : Icon(
                      widget.icon,
                      color: widget.color,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
