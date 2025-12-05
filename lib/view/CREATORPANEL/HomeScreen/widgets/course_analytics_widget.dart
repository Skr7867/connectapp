import 'dart:math';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/response/status.dart';
import '../../../../models/CREATORPANEL/Profile/creators_profile_model.dart';
import '../../../../view_models/CREATORPANEL/CreatorProfile/creator_profile_controller.dart';

class CreatorEnrolmentsBarChart extends StatelessWidget {
  CreatorEnrolmentsBarChart({super.key});

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
          final data = c.creatorList.value.stats?.graphData ?? [];

          if (data.isEmpty) {
            return _buildEmptyState();
          }

          return _buildChartContent(data);
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
              'Loading enrollment data...',
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
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
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
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.school_outlined,
              size: 48,
              color: AppColors.blueColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Enrollment Data Found',
            style: TextStyle(
              color: AppColors.blueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Course enrollment statistics will appear here',
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

  Widget _buildChartContent(List<GraphData> data) {
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
                    colors: [Colors.cyan.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
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
                      'Course Enrollments',
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
              _buildStatsChip(data),
            ],
          ),
          const SizedBox(height: 24),
          _Bar(bodyData: data),
        ],
      ),
    );
  }

  Widget _buildStatsChip(List<GraphData> data) {
    final total =
        data.fold<int>(0, (sum, item) => sum + (item.enrolledUsers ?? 0));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.teal.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Text(
            '$total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              fontFamily: AppFonts.opensansRegular,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatefulWidget {
  final List<GraphData> bodyData;

  const _Bar({required this.bodyData});

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Color> rodColors = [
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
      duration: const Duration(milliseconds: 1200),
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
    final maxVal = widget.bodyData.fold<int>(
      0,
      (prev, e) => max(prev, e.enrolledUsers ?? 0),
    );

    final maxY = maxVal == 0 ? 1.0 : (maxVal * 1.2).ceilToDouble();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AspectRatio(
          aspectRatio: 2.2,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.grey[900]?.withOpacity(0.9),
                  tooltipRoundedRadius: 12,
                  tooltipPadding: const EdgeInsets.all(12),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = widget.bodyData[groupIndex];
                    return BarTooltipItem(
                      '${item.courseTitle ?? '-'}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toInt()} enrolled',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= widget.bodyData.length) {
                        return const SizedBox.shrink();
                      }
                      final title = widget.bodyData[index].courseTitle ?? '-';
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Transform.rotate(
                          angle: -20 * 3.1415927 / 180,
                          child: Text(
                            _shorten(title, 15),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: maxY > 5 ? maxY / 5 : 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  left: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              barGroups: List.generate(widget.bodyData.length, (i) {
                final enrolled =
                    (widget.bodyData[i].enrolledUsers ?? 0).toDouble();
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: enrolled * _animation.value,
                      width: 28,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          rodColors[i % rodColors.length],
                          rodColors[i % rodColors.length].withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                );
              }),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 5 ? maxY / 5 : 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[200],
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

String _shorten(String s, int maxLen) =>
    s.length <= maxLen ? s : '${s.substring(0, maxLen - 1)}…';
