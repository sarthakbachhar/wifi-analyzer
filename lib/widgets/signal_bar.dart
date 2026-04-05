import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SignalBar extends StatelessWidget {
  final int rssi;
  final double barWidth;
  final double maxHeight;
  final int bars;

  const SignalBar({
    super.key,
    required this.rssi,
    this.barWidth = 4,
    this.maxHeight = 18,
    this.bars = 4,
  });

  int get _filledBars {
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    if (rssi >= -80) return 1;
    return 0;
  }

  Color get _color {
    if (rssi >= -60) return AppColors.secure;
    if (rssi >= -70) return AppColors.medium;
    return AppColors.high;
  }

  @override
  Widget build(BuildContext context) {
    final filled = _filledBars;
    final color = _color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(bars, (i) {
        final isFilled = i < filled;
        final height = maxHeight * ((i + 1) / bars);
        return Container(
          width: barWidth,
          height: height,
          margin: EdgeInsets.only(left: i == 0 ? 0 : 2),
          decoration: BoxDecoration(
            color: isFilled ? color : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
