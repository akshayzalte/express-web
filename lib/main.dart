import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/fcm_service.dart';
import 'services/connectivity_service.dart';
import 'views/doctor/doctor_under_review_view.dart';
import 'views/doctor/doctor_inventory.dart';
import 'views/login_view.dart';
import 'views/doctor/doctor_dashboard.dart';
import 'views/doctor/new_order_form.dart';
import 'views/doctor/order_tracker.dart';
import 'views/doctor/doctor_bills.dart';
import 'views/doctor/doctor_profile.dart';
import 'views/doctor/doctor_notifications.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/admin/admin_orders_list.dart';
import 'views/admin/admin_order_detail.dart';
import 'views/admin/product_management.dart';
import 'views/admin/branch_management.dart';
import 'views/admin/technician_management.dart';
import 'views/admin/doctor_management.dart';
import 'views/technician/technician_dashboard.dart';

import 'views/technician/technician_order_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Core Services
  final dbService = Get.put(DatabaseService(), permanent: true);
  final authService = Get.put(AuthService(), permanent: true);
  final fcmService = Get.put(FCMService(), permanent: true);
  final connectivityService = Get.put(ConnectivityService(), permanent: true);

  // Initialize push notification listeners
  await fcmService.initFirebase();

  runApp(const CloudDentalExpressApp());
}

class CloudDentalExpressApp extends StatelessWidget {
  const CloudDentalExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cloud Dental Express',
      theme: GlacierTheme.lightTheme,
      darkTheme: GlacierTheme.darkTheme,
      themeMode: ThemeMode.system, // respects system theme
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final connectivity = Get.find<ConnectivityService>();
        return Stack(
          children: [
            if (child != null) child,
            Obx(() {
              if (!connectivity.isConnected.value) {
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Offline Mode • No Internet Connection',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: connectivity.checkConnection,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/dashboard', page: () => const DashboardRouter()),
        
        // Doctor Pages
        GetPage(name: '/doctor-dashboard', page: () => const DoctorDashboard()),
        GetPage(name: '/new-order', page: () => const NewOrderForm()),
        GetPage(name: '/order-tracker', page: () => const OrderTracker()),
        GetPage(name: '/bills', page: () => const DoctorBills()),
        GetPage(name: '/profile', page: () => const DoctorProfile()),
        GetPage(name: '/notifications', page: () => const DoctorNotifications()),
        GetPage(name: '/inventory', page: () => const DoctorInventory()),

        // Admin Pages
        GetPage(name: '/admin-dashboard', page: () => const AdminDashboard()),
        GetPage(name: '/admin-orders', page: () => const AdminOrdersList()),
        GetPage(name: '/admin-order-detail', page: () => const AdminOrderDetail()),
        GetPage(name: '/products-mgmt', page: () => const ProductManagement()),
        GetPage(name: '/branches-mgmt', page: () => const BranchManagement()),
        GetPage(name: '/technicians-mgmt', page: () => const TechnicianManagement()),
        GetPage(name: '/doctors-mgmt', page: () => const DoctorManagement()),


        // Technician Pages
        GetPage(name: '/technician-dashboard', page: () => const TechnicianDashboard()),
        GetPage(name: '/technician-order-detail', page: () => const TechnicianOrderDetail()),
      ],
    );
  }
}

// Router class to dynamically render the corresponding dashboard based on the logged in user's role
class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.currentUser.value;
    if (user == null) {
      return const LoginView();
    }

    switch (user.role.toLowerCase()) {
      case 'doctor':
        if (!user.isApproved) {
          return const DoctorUnderReviewView();
        }
        return const DoctorDashboard();
      case 'admin':
        return const AdminDashboard();
      case 'technician':
        return const TechnicianDashboard();
      default:
        return Scaffold(
          body: Center(
            child: Text(
              'Invalid role configuration: ${user.role}',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
        );
    }
  }
}

