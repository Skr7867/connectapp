import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../res/custom_widgets/custome_appbar.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/popularCourses/popular_courses_controller.dart';
import 'widgets/pagination_point_widget.dart';

class PopularCoursesScreen extends StatelessWidget {
  const PopularCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PopularCoursesController());
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidht = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Popular Courses',
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.popularCourses.isEmpty) {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ));
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return Column(
          children: [
            const SizedBox(height: 16),

            // Courses Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: screenHeight * 0.0008,
                  ),
                  itemCount: controller.popularCourses.length,
                  itemBuilder: (context, index) {
                    final popularCourses = controller.popularCourses[index];
                    return InkWell(
                      onTap: () {
                        Get.toNamed(RouteName.viewDetailsOfCourses,
                            arguments: popularCourses.courseId);
                      },
                      child: CourseCard(
                        coins: popularCourses.coins ?? 0,
                        thumbnail: popularCourses.thumbnail ?? "",
                        title: popularCourses.title ?? "",
                        description: popularCourses.description ?? "",
                        rating: popularCourses.ratings?.avgRating?.toString() ??
                            "0",
                        enrolledCount: popularCourses.enrolledCount ?? 0,
                        isFree: popularCourses.coins == 0,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Pagination controls
            Padding(
              padding: const EdgeInsets.only(bottom: 45),
              child: PaginationWidget(controller: controller),
            ),
          ],
        );
      }),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final String description;
  final String rating;
  final int enrolledCount;
  final bool isFree;
  final int coins;

  const CourseCard({
    super.key,
    required this.thumbnail,
    required this.coins,
    required this.title,
    required this.description,
    required this.rating,
    required this.enrolledCount,
    required this.isFree,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Free Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  thumbnail,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                      ),
                      child: Image.asset(
                        'assets/images/java.png',
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                      ),
                      child: Image.asset(
                        'assets/images/java.png',
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              if (isFree)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D9A3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Free',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Footer with Rating and Students
                  Row(
                    children: [
                      // Rating
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      // Students
                      const Icon(
                        Icons.people,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        enrolledCount.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$coins',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      SizedBox(width: 3),
                      Image.asset(
                        ImageAssets.coins,
                        height: 20,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
