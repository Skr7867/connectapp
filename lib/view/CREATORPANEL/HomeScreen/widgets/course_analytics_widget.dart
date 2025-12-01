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
    final List<Color> rodColors = [
      Colors.cyan,
      Colors.deepOrange,
      Colors.orange,
      Colors.teal,
      Colors.green,
      Colors.pink,
      Colors.indigo,
      Colors.redAccent,
    ];

    return Obx(() {
      switch (c.rxRequestStatus.value) {
        case Status.LOADING:
          return const Center(child: CircularProgressIndicator());
        case Status.ERROR:
          return Center(child: Text(c.error.value));
        case Status.COMPLETED:
          final data = c.creatorList.value.stats?.graphData ?? [];

          if (data.isEmpty) {
            return Center(
              child: Text(
                'No course enrollment data Found',
                style: TextStyle(
                    color: AppColors.blueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 16.0), // Add right padding
            child: _Bar(bodyData: data, rodColors: rodColors),
          );
      }
    });
  }
}

class _Bar extends StatelessWidget {
  final List<GraphData> bodyData;
  final List<Color> rodColors;

  const _Bar({required this.bodyData, required this.rodColors});

  @override
  Widget build(BuildContext context) {
    final maxVal = bodyData.fold<int>(
      0,
      (prev, e) => max(prev, e.enrolledUsers ?? 0),
    );

    final maxY = maxVal == 0 ? 1.0 : (maxVal * 1.2).ceilToDouble();

    return AspectRatio(
      aspectRatio: 2.0, // Increased to allow more horizontal space
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = bodyData[groupIndex];
                return BarTooltipItem(
                  '${item.courseTitle ?? '-'}\nEnrolled: ${rod.toY.toInt()}',
                  TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= bodyData.length) {
                    return const SizedBox.shrink();
                  }
                  final title = bodyData[index].courseTitle ?? '-';
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Transform.rotate(
                      angle: -15 * 3.1415927 / 180,
                      child: Text(
                        _shorten(title, 12),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            fontSize: 10,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY > 5 ? maxY / 5 : 1,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    space: 24,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(bodyData.length, (i) {
            final enrolled = (bodyData[i].enrolledUsers ?? 0).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: enrolled,
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                  color: rodColors[i % rodColors.length],
                ),
              ],
            );
          }),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }
}

String _shorten(String s, int maxLen) =>
    s.length <= maxLen ? s : '${s.substring(0, maxLen - 1)}…';
