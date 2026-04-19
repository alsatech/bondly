import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? AppColors.primary
                  : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
