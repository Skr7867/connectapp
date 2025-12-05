import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/response/status.dart';
import '../../../res/color/app_colors.dart';
import '../../../res/custom_widgets/responsive_padding.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../res/routes/routes_name.dart';
import '../../../view_models/CREATORPANEL/DeleteCourse/delete_course_controller.dart';
import '../../../view_models/CREATORPANEL/GetAllCreatorCourses/get_all_creater_courses_controller.dart';
import '../CreatorCourses/dialog_box.dart';

class CourseManagementScreen extends StatelessWidget {
  const CourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final controller = Get.put(GetAllCreatorCoursesController());
    final deleteCourseController = Get.put(DeleteCourseController());

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'Course Management',
        centerTitle: false,
        actions: [
          Padding(
            padding: ResponsivePadding.customPadding(context, right: 5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.cyan.shade500],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed(RouteName.createCourseScreen),
                  borderRadius: BorderRadius.circular(25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_circle_outline,
                            color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Create Course',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        switch (controller.rxRequestStatus.value) {
          case Status.LOADING:
            return _buildLoadingState();
          case Status.ERROR:
            return _buildErrorState(context, controller, screenHeight);
          case Status.COMPLETED:
            if (controller.creatorCourses.isEmpty) {
              return _buildEmptyState(context, screenHeight);
            }
            return _buildCoursesList(
              context,
              controller,
              deleteCourseController,
              screenWidth,
              screenHeight,
            );
        }
      }),
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
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your courses...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    GetAllCreatorCoursesController controller,
    double screenHeight,
  ) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.error.value.isEmpty
                  ? 'Failed to load courses'
                  : controller.error.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.refreshApi(),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(RouteName.createCourseScreen),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Create Course'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double screenHeight) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.cyan.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.school_outlined,
                size: 64,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Courses Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start creating your first course\nand share your knowledge!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                height: 1.5,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(RouteName.createCourseScreen),
              icon: const Icon(Icons.add_circle_outline, size: 22),
              label: const Text('Create Your First Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(
    BuildContext context,
    GetAllCreatorCoursesController controller,
    DeleteCourseController deleteCourseController,
    double screenWidth,
    double screenHeight,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.creatorCourses.length,
      itemBuilder: (context, index) {
        final course = controller.creatorCourses[index];
        return _CourseCard(
          course: course,
          index: index,
          controller: controller,
          deleteCourseController: deleteCourseController,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        );
      },
    );
  }
}

class _CourseCard extends StatefulWidget {
  final dynamic course;
  final int index;
  final GetAllCreatorCoursesController controller;
  final DeleteCourseController deleteCourseController;
  final double screenWidth;
  final double screenHeight;

  const _CourseCard({
    required this.course,
    required this.index,
    required this.controller,
    required this.deleteCourseController,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.course.tags ?? [];
    final displayedTags = tags.take(3).toList();
    final remainingTagsCount = tags.length > 3 ? tags.length - 3 : 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Image Header
              Stack(
                children: [
                  _buildThumbnail(),
                  _buildGradientOverlay(),
                  _buildTopActions(context),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 2),
                    _buildDescription(),
                    const SizedBox(height: 12),
                    _buildTags(displayedTags, remainingTagsCount),
                    const SizedBox(height: 16),
                    _buildStats(),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      height: 200,
      width: double.infinity,
      child: widget.course.thumbnail != null
          ? Image.network(
              widget.course.thumbnail!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported,
                    size: 64, color: Colors.grey[400]),
              ),
            )
          : Container(
              color: Colors.grey[200],
              child: Icon(Icons.school, size: 64, color: Colors.grey[400]),
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      left: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  DateFormat('d MMM yyyy').format(
                    DateTime.parse(widget.course.createdAt.toString()),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              ],
            ),
          ),
          _buildPopupMenu(context),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        color: Theme.of(context).scaffoldBackgroundColor,
        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (BuildContext context) => [
          _buildPopupMenuItem(Icons.edit_outlined, 'Edit', 'edit', false),
          _buildPopupMenuItem(Icons.delete_outline, 'Delete', 'delete', true),
          _buildPopupMenuItem(
              Icons.people_alt_outlined, 'Create Group', 'createGroup', false),
          // _buildPopupMenuItem(Icons.share, 'Share', 'share', false),
          _buildPopupMenuItem(
              Icons.add_box_outlined, 'Add Section', 'addsection', false),
        ],
        onSelected: (value) => _handleMenuAction(context, value),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    IconData icon,
    String text,
    String value,
    bool isDanger,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDanger ? AppColors.redColor : Colors.grey[700],
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDanger ? AppColors.redColor : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) async {
    switch (value) {
      case 'edit':
        final result = await Get.toNamed(
          RouteName.editCourseScreen,
          arguments: widget.controller.creatorCourses[widget.index],
        );
        if (result == true) widget.controller.refreshApi();
        break;
      case 'addsection':
        Get.toNamed(
          RouteName.createCourseSectionScreen,
          arguments: {'courseId': widget.course.sId},
        );
        break;
      case 'delete':
        if (widget.course.sId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course ID is missing.')),
          );
          break;
        }
        widget.deleteCourseController.isDeleting.value = true;
        await widget.deleteCourseController.deleteCourse(widget.course.sId!);
        widget.deleteCourseController.isDeleting.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
        break;
      case 'createGroup':
        showCreateGroupDialog(context, widget.course.sId ?? '');
        break;
      case 'share':
        Utils.toastMessageCenter('Share feature coming soon!');
        break;
    }
  }

  Widget _buildTitle() {
    return Text(
      widget.course.title ?? 'No Title',
      style: TextStyle(
          fontSize: 18,
          fontFamily: AppFonts.opensansRegular,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.course.description ?? 'No Description',
      style: TextStyle(
        fontFamily: AppFonts.opensansRegular,
        color: Colors.grey[600],
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(List displayedTags, int remainingTagsCount) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayedTags.map((tag) => _Tag(tag)),
        if (remainingTagsCount > 0) _Tag("+$remainingTagsCount", isExtra: true),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildStatItem(Icons.workspace_premium, 'Perfect Quiz',
                  widget.course.xpPerPerfectQuiz, Colors.blue)),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
              child: _buildStatItem(Icons.play_circle_outline, 'XP Start',
                  widget.course.xpOnStart, Colors.green)),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
              child: _buildStatItem(Icons.check_circle_outline, 'Completion',
                  widget.course.xpOnCompletion, Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String label, dynamic value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontFamily: AppFonts.opensansRegular,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? '0',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(ImageAssets.coins, height: 20),
              const SizedBox(width: 6),
              Text(
                widget.course.coins?.toString() ?? '0',
                style: const TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool isExtra;

  const _Tag(this.label, {this.isExtra = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isExtra
            ? LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500])
            : LinearGradient(
                colors: [Colors.blue.shade600, Colors.cyan.shade500]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isExtra ? Colors.grey : Colors.blue).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontFamily: AppFonts.opensansRegular,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
