import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A hairline step tracker for the intake wizard — communicates
/// progress through a real sequence (this content genuinely is one),
/// unlike a decorative numbered-marker row.
class StepTracker extends StatelessWidget {
  final List<String> labels;
  final int currentIndex;

  const StepTracker(
      {super.key, required this.labels, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftDone = (i - 1) ~/ 2 < currentIndex;
          return Expanded(
            child: Container(
              height: 1.4,
              color: leftDone ? AppColors.ink : AppColors.hairline,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex < currentIndex;
        final isCurrent = stepIndex == currentIndex;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone || isCurrent ? AppColors.ink : Colors.transparent,
                border: Border.all(
                  color: isDone || isCurrent ? AppColors.ink : AppColors.hairline,
                  width: 1.4,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${stepIndex + 1}',
                      style: AppType.data(
                        size: 12,
                        weight: FontWeight.w600,
                        color: isCurrent ? Colors.white : AppColors.textMuted,
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              labels[stepIndex],
              style: AppType.body(
                size: 11,
                weight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? AppColors.ink : AppColors.textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }
}
