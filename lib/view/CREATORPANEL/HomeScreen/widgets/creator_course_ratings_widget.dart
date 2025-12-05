import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/response/status.dart';
import '../../../../models/CREATORPANEL/Profile/creators_profile_model.dart';
import '../../../../res/color/app_colors.dart';
import '../../../../view_models/CREATORPANEL/CreatorProfile/creator_profile_controller.dart';

class CreatorCourseRatingsWidget extends StatelessWidget {
  CreatorCourseRatingsWidget({super.key});

  final CreatorProfileController c = Get.find<CreatorProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (c.rxRequestStatus.value) {
        case Status.LOADING:
          return _buildLoadingState();
        case Status.ERROR:
          return _buildErrorState(c.error.value);
        case Status.COMPLETED:
          final data = c.creatorList.value.stats?.ratingsPerCourse ?? [];

          if (data.isEmpty) {
            return _buildEmptyState();
          }

          return _buildRatingsContent(data);
      }
    });
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading ratings data...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontFamily: AppFonts.opensansRegular,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.amber.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade100),
      ),
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
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 48,
              color: AppColors.blueColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Course Ratings Yet',
            style: TextStyle(
              color: AppColors.blueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Course ratings will appear here once available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsContent(List<RatingsPerCourse> data) {
    final avgRating = data.fold<double>(
          0.0,
          (sum, item) => sum + (item.averageRating ?? 0),
        ) /
        data.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Ratings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.length} courses',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAverageRatingChip(avgRating),
            ],
          ),
          const SizedBox(height: 24),
          RatingsPieChart(ratings: data),
        ],
      ),
    );
  }

  Widget _buildAverageRatingChip(double avgRating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.yellow.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 6),
          Text(
            avgRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
        ],
      ),
    );
  }
}

class RatingsPieChart extends StatefulWidget {
  final List<RatingsPerCourse> ratings;

  const RatingsPieChart({required this.ratings, super.key});

  @override
  State<RatingsPieChart> createState() => _RatingsPieChartState();
}

class _RatingsPieChartState extends State<RatingsPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  final List<Color> colorList = [
    const Color(0xFF00BCD4),
    const Color(0xFFFF5722),
    const Color(0xFFFF9800),
    const Color(0xFF009688),
    const Color(0xFF4CAF50),
    const Color(0xFFE91E63),
    const Color(0xFF3F51B5),
    const Color(0xFFF44336),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AspectRatio(
          aspectRatio: 1.4,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 1,
                    centerSpaceRadius: 2,
                    sections: List.generate(widget.ratings.length, (i) {
                      final item = widget.ratings[i];
                      final isTouched = i == touchedIndex;
                      final double radius = isTouched ? 95 : 85;
                      final double fontSize = isTouched ? 18 : 14;

                      return PieChartSectionData(
                        color: colorList[i % colorList.length],
                        value: (item.averageRating ?? 0) * _animation.value,
                        title: isTouched
                            ? '${(item.averageRating ?? 0).toStringAsFixed(1)}'
                            : '${(item.averageRating ?? 0).toStringAsFixed(1)}',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: AppFonts.opensansRegular,
                          shadows: [
                            const Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        badgeWidget: isTouched
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.star,
                                  color: colorList[i % colorList.length],
                                  size: 20,
                                ),
                              )
                            : null,
                        badgePositionPercentageOffset: 1.3,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(widget.ratings.length, (i) {
                      final isSelected = i == touchedIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorList[i % colorList.length].withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? colorList[i % colorList.length]
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colorList[i % colorList.length],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorList[i % colorList.length]
                                        .withOpacity(0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ratings[i].courseTitle ?? 'Unnamed',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 8,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontFamily: AppFonts.opensansRegular,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.amber[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(widget.ratings[i].averageRating ?? 0).toStringAsFixed(1)}/5.0',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
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
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
