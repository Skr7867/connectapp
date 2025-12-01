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
          return const Center(child: CircularProgressIndicator());
        case Status.ERROR:
          return Center(child: Text(c.error.value));
        case Status.COMPLETED:
          final data = c.creatorList.value.stats?.ratingsPerCourse ?? [];

          if (data.isEmpty) {
            return Center(
              child: Text(
                textAlign: TextAlign.center,
                'No Course Ratings For this Creator.',
                style: TextStyle(
                    color: AppColors.blueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular),
              ),
            );
          }

          return RatingsPieChart(ratings: data);
      }
    });
  }
}

class RatingsPieChart extends StatelessWidget {
  final List<RatingsPerCourse> ratings;

  const RatingsPieChart({required this.ratings, super.key});

  @override
  Widget build(BuildContext context) {
    ratings.fold<double>(
      0.0,
      (sum, item) => sum + (item.averageRating ?? 0),
    );

    final colorList = [
      Colors.cyan,
      Colors.deepOrange,
      Colors.orange,
      Colors.teal,
      Colors.green,
      Colors.pink,
      Colors.indigo,
      Colors.redAccent,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    sections: List.generate(ratings.length, (i) {
                      final item = ratings[i];
                      return PieChartSectionData(
                        color: colorList[i % colorList.length],
                        value: item.averageRating ?? 0,
                        title:
                            '${(item.averageRating ?? 0).toStringAsFixed(1)}/5.0',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(ratings.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorList[i % colorList.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              ratings[i].courseTitle ?? 'Unnamed',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 10,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
