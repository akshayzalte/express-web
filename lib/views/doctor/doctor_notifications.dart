import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';

class DoctorNotifications extends StatelessWidget {
  const DoctorNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              for (var n in db.notifications) {
                db.markNotificationRead(n.id);
              }
              Get.snackbar('Notifications', 'All messages marked as read.');
            },
            child: Text(
              'Mark all read',
              style: TextStyle(
                color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        child: Obx(() {
          final notifyList = db.notifications.toList();

          if (notifyList.isEmpty) {
            return Center(
              child: Text(
                'No new notifications.',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: notifyList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = notifyList[index];
              return GestureDetector(
                onTap: () => db.markNotificationRead(n.id),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16.0),
                  customBgColor: n.isRead
                      ? null
                      : (isDark 
                          ? Colors.white.withOpacity(0.08) 
                          : Colors.white.withOpacity(0.85)),
                  customBorderColor: n.isRead
                      ? null
                      : (isDark ? GlacierColors.darkPrimary.withOpacity(0.3) : GlacierColors.lightPrimary.withOpacity(0.3)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unread indicator dot
                      if (!n.isRead) ...[
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 10),
                          decoration: BoxDecoration(
                            color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(width: 18),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: TextStyle(
                                fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.message,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n.dateCreated.toString().substring(11, 16),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
            },
          );
        }),
      ),
    );
  }
}
