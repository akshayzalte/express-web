import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';

class OrderTracker extends StatelessWidget {
  const OrderTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel order = Get.arguments as OrderModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      {'title': 'Pending', 'desc': 'Prescription submitted to lab queue.'},
      {'title': 'Lab Received', 'desc': 'Dental lab checked in scan impressions.'},
      {'title': 'In Progress', 'desc': 'Technician is active modeling & casting.'},
      {'title': 'Quality Check', 'desc': 'Checking crown margins under microscope.'},
      {'title': 'Delivered', 'desc': 'Case shipped to clinic with generated invoice.'},
    ];

    int activeIndex = 0;
    final statusStr = order.status.toLowerCase().replaceAll(' ', '');
    if (statusStr == 'pending') activeIndex = 0;
    if (statusStr == 'labreceived') activeIndex = 1;
    if (statusStr == 'inprogress') activeIndex = 2;
    if (statusStr == 'qualitycheck' || statusStr == 'qc') activeIndex = 3;
    if (statusStr == 'delivered') activeIndex = 4;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Case ${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: isDark
                ? [const Color(0xFF0F2B48), const Color(0xFF0A1628)]
                : [const Color(0xFFDCE6F1), const Color(0xFFEAF0F6)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Order details summary card
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.patientName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _detailRow(context, 'Product:', order.product),
                  _detailRow(context, 'Tooth Number:', '#${order.toothNumbers.join(",")}'),
                  _detailRow(context, 'Shade Spec:', order.shade),
                  _detailRow(context, 'Branch Lab:', order.branch),
                  _detailRow(context, 'Due Date:', order.dueDate.toString().split(' ')[0]),
                  if (order.technicianName != null) ...[
                    _detailRow(context, 'Assigned Tech:', order.technicianName!),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),

            // Tracker Stepper Header
            Text(
              'Restoration Progress Steps',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 12),

            // Stepper Box
            GlassContainer(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isCompleted = index < activeIndex;
                  final isCurrent = index == activeIndex;
                  
                  Color dotColor = Colors.grey;
                  if (isCompleted) {
                    dotColor = isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary;
                  } else if (isCurrent) {
                    dotColor = isDark ? GlacierColors.darkAccent : const Color(0xFF4FC3F7);
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line & circle graphics
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isCurrent ? dotColor : Colors.transparent,
                              border: Border.all(
                                color: dotColor,
                                width: isCurrent ? 5.0 : 2.0,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (index < steps.length - 1)
                            Container(
                              width: 2,
                              height: 50,
                              color: index < activeIndex
                                  ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Step text
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isCurrent
                                      ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
                                      : (isCompleted ? null : Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step['desc']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCurrent
                                      ? null
                                      : (isCompleted ? Colors.grey : Colors.grey.withOpacity(0.7)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),

            // Lab Technical Notes
            if (order.labNotes != null) ...[
              Text(
                'Lab Notes from Technician',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.labNotes!,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
