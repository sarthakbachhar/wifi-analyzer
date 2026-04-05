import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../theme/app_theme.dart';

class SecurityBadge extends StatelessWidget {
  final SecurityType type;
  final bool small;

  const SecurityBadge({super.key, required this.type, this.small = false});

  Color get _color {
    switch (type) {
      case SecurityType.open:
        return AppColors.critical;
      case SecurityType.wep:
        return AppColors.critical;
      case SecurityType.wpa:
        return AppColors.high;
      case SecurityType.wpa2:
        return AppColors.medium;
      case SecurityType.wpa2wpa3:
        return AppColors.low;
      case SecurityType.wpa3:
        return AppColors.secure;
      case SecurityType.unknown:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = small ? 9.0 : 10.0;
    final hPad = small ? 6.0 : 8.0;
    final vPad = small ? 2.0 : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: _color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class RiskLevelBadge extends StatelessWidget {
  final RiskLevel level;
  final bool small;

  const RiskLevelBadge({super.key, required this.level, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = riskLevelColor(level);
    final fontSize = small ? 9.0 : 10.0;
    final hPad = small ? 6.0 : 8.0;
    final vPad = small ? 2.0 : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        level.shortLabel,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class SeverityIcon extends StatelessWidget {
  final Severity severity;
  final double size;

  const SeverityIcon({super.key, required this.severity, this.size = 18});

  IconData get _icon {
    switch (severity) {
      case Severity.info:
        return Icons.info_outline_rounded;
      case Severity.low:
        return Icons.check_circle_outline_rounded;
      case Severity.medium:
        return Icons.warning_amber_rounded;
      case Severity.high:
        return Icons.error_outline_rounded;
      case Severity.critical:
        return Icons.dangerous_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(_icon, color: severityColor(severity), size: size);
  }
}
