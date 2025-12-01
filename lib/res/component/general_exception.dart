import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../color/app_colors.dart';

class GeneralException extends StatefulWidget {
  final VoidCallback onpress;
  const GeneralException({super.key, required this.onpress});

  @override
  State<GeneralException> createState() => _GeneralExceptionState();
}

class _GeneralExceptionState extends State<GeneralException> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.03,
          ),
          Icon(
            Icons.cloud_off,
            color: AppColors.blackColor,
            size: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(child: Text('general_exception'.tr)),
          ),
          SizedBox(
            height: screenHeight * 0.03,
          ),
          InkWell(
            onTap: widget.onpress,
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Retry',
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
