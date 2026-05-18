import 'package:flutter/material.dart';

class MapSelectionStepMeter extends StatelessWidget {
  const MapSelectionStepMeter({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index < currentStep;
        final current = index == currentStep && currentStep < labels.length;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active || current
                    ? const Color(0xFFEEF2FF)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active || current
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    active
                        ? Icons.check_circle_rounded
                        : current
                            ? Icons.adjust_rounded
                            : Icons.circle_outlined,
                    size: 18,
                    color: active || current
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: active || current
                          ? const Color(0xFF4338CA)
                          : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
