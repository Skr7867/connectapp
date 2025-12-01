import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view_models/controller/popularCourses/popular_courses_controller.dart';

class PaginationWidget extends StatelessWidget {
  final PopularCoursesController controller;

  const PaginationWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidht = MediaQuery.of(context).size.width;
    return Obx(() {
      int currentPage = controller.currentPage.value;
      int totalPages = controller.totalPages.value;

      // calculate visible pages
      List<int> visiblePages = [];
      if (totalPages <= 3) {
        visiblePages = List.generate(totalPages, (i) => i + 1);
      } else {
        if (currentPage <= 2) {
          visiblePages = [1, 2, 3];
        } else if (currentPage >= totalPages - 1) {
          visiblePages = [totalPages - 2, totalPages - 1, totalPages];
        } else {
          visiblePages = [currentPage - 1, currentPage, currentPage + 1];
        }
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prev Button

          TextButton(
            onPressed: currentPage > 1
                ? () => controller.fetchPopularCourses(currentPage - 1)
                : null,
            child: Text(
              "Prev",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),

          SizedBox(width: screenWidht * 0.01),

          if (currentPage > 2 && totalPages > 3) ...[
            const Text("..."),
            const SizedBox(width: 5),
          ],

          Wrap(
            spacing: 0.1,
            children: visiblePages.map((page) {
              bool isActive = page == currentPage;
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      isActive ? Colors.grey.shade400 : Colors.transparent,
                  minimumSize: const Size(30, 30),
                  shape: const CircleBorder(),
                  side: BorderSide(
                    color: isActive ? Colors.black : Colors.blue,
                  ),
                ),
                onPressed: () => controller.fetchPopularCourses(page),
                child: Text(
                  page.toString(),
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.blue,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),

          if (currentPage < totalPages - 1 && totalPages > 3) ...[
            SizedBox(width: screenWidht * 0.02),
            const Text("..."),
          ],

          SizedBox(width: screenWidht * 0.02),

          // Next Button

          TextButton(
            onPressed: currentPage < totalPages
                ? () => controller.fetchPopularCourses(currentPage + 1)
                : null,
            child: Text(
              "Next",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      );
    });
  }
}
