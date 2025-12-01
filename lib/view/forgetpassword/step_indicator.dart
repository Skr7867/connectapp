import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // which step is active (1,2,3)

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= currentStep;

        return Row(
          children: [
            // Circle
            CircleAvatar(
              radius: 16,
              backgroundColor: isActive ? Colors.black : Colors.white,
              child: Text(
                "$stepNumber",
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Connector line (except last step)
            if (index != 2)
              Container(
                width: 30,
                height: 2,
                color: stepNumber < currentStep ? Colors.black : Colors.grey,
              ),
          ],
        );
      }),
    );
  }
}
