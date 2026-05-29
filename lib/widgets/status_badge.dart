import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'glass_container.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase().replaceAll(' ', '')) {
      case 'pending':
        bgColor = GlacierColors.badgePendingBg;
        textColor = GlacierColors.badgePendingText;
        break;
      case 'inprogress':
      case 'labreceived':
        bgColor = GlacierColors.badgeInProgressBg;
        textColor = GlacierColors.badgeInProgressText;
        break;
      case 'qualitycheck':
      case 'qc':
        bgColor = GlacierColors.badgeQualityCheckBg;
        textColor = GlacierColors.badgeQualityCheckText;
        break;
      case 'delivered':
        bgColor = GlacierColors.badgeDeliveredBg;
        textColor = GlacierColors.badgeDeliveredText;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
    }

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      borderRadius: 99.0, // pill shape
      customBgColor: bgColor,
      customBorderColor: textColor.withOpacity(0.2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
