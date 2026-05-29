import 'package:get/get.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/branch.dart';
import '../models/bill.dart';
import '../models/notification.dart';

// Stub Realm configuration to bypass complex local Android NDK compilation
// for Realm C++ binaries. To enable online MongoDB Sync, restore the package:realm imports.
class RealmAppStub {
  RealmAppStub(dynamic config);
}
class RealmStub {
  RealmStub(dynamic config);
}
class AppConfigurationStub {
  AppConfigurationStub(String appId);
}

class DatabaseService extends GetxService {
  // Realm App Services Client
  late final RealmAppStub? _realmApp;
  final RealmStub? _realm = null;
  
  final isMongoConnected = false.obs;

  // Reactive data streams for local/synced storage
  final users = <UserModel>[].obs;
  final products = <ProductModel>[].obs;
  final orders = <OrderModel>[].obs;
  final branches = <BranchModel>[].obs;
  final bills = <BillModel>[].obs;
  final notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      // Setup Realm App Services Client if possible
      // Using placeholder App ID from design specifications
      const appServicesId = 'cloud-dental-express-xxxxx';
      
      if (!appServicesId.contains('xxxxx')) {
        _realmApp = RealmAppStub(AppConfigurationStub(appServicesId));
        // Realm configuration would be opened here for online sync
        isMongoConnected.value = true;
      } else {
        _realmApp = null;
        isMongoConnected.value = false;
      }
    } catch (e) {
      isMongoConnected.value = false;
      _realmApp = null;
    }
    
    // Always seed local data so the application is fully hydrated and interactive
    _seedLocalData();
  }

  void _seedLocalData() {
    // Seed Users
    users.addAll([
      UserModel(
        id: 'doc_1',
        email: 'doctor@dental.com',
        name: 'Dr. Jane Smith',
        role: 'doctor',
        clinicName: 'Smith Family Dentistry',
        address: '123 Medical Plaza, New York, NY 10001',
        latitude: 40.7128,
        longitude: -74.0060,
        profilePhotoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDsC2snuohD00_UQjeY7KFzHRrADDJp0WCkT5mFDUqZcG9e1-ifwvl1ufdOMrd0gqDAHQ-1e8rLeBq9kOx8_8zbgsYkCa-zDmrziQLYKP-t4YgAptCwU1k8mFsHHFV8B0vNur7VI8L8v7L8ykpa6so-A59n6oLAhYUMh5TJCBjwbk1qONi1dxx8yLpl3cCJbrUYTKXdT7Z5UgWkWE8g6ka-a2aBFRMHduIomjBPWQInnyK4TVGKTIFYow-w-baUnM1b3NFaw1w9zF5m',
      ),
      UserModel(
        id: 'admin_1',
        email: 'admin@dental.com',
        name: 'Admin Chief',
        role: 'admin',
      ),
      UserModel(
        id: 'tech_1',
        email: 'alex@dental.com',
        name: 'Alex Rivers',
        role: 'technician',
        profilePhotoUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=200&auto=format&fit=crop',
      ),
      UserModel(
        id: 'tech_2',
        email: 'sarah@dental.com',
        name: 'Sarah Jenkins',
        role: 'technician',
        profilePhotoUrl: 'https://images.unsplash.com/photo-1594824813573-246434de83fb?q=80&w=200&auto=format&fit=crop',
      ),
      UserModel(
        id: 'tech_3',
        email: 'marcus@dental.com',
        name: 'Marcus Chen',
        role: 'technician',
        profilePhotoUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=200&auto=format&fit=crop',
      ),
    ]);

    // Seed Products
    products.addAll([
      // Lab restorations (Crowns, etc.)
      ProductModel(id: 'prod_1', name: 'Zirconia Crown', description: 'High translucency, multi-layered zirconia restoration.', price: 150.00, isSupply: false),
      ProductModel(id: 'prod_2', name: 'E.Max Crown', description: 'Lithium disilicate glass-ceramic for premium aesthetics.', price: 180.00, isSupply: false),
      ProductModel(id: 'prod_3', name: 'PFM Crown', description: 'Porcelain fused to cobalt-chromium metal alloy framework.', price: 120.00, isSupply: false),
      ProductModel(id: 'prod_4', name: 'Implant Abutment', description: 'Custom titanium abutment with high precision fitting.', price: 250.00, isSupply: false),

      // Clinic supplies (Inventory items)
      ProductModel(id: 'sup_1', name: 'Nitrile Examination Gloves', description: 'Premium powder-free, medical-grade nitrile gloves (Box of 100).', price: 0.0, isSupply: true),
      ProductModel(id: 'sup_2', name: 'Digital Sensor Sleeves', description: 'Disposable protective barrier sleeves for intraoral digital X-ray sensors.', price: 0.0, isSupply: true),
      ProductModel(id: 'sup_3', name: 'Dental Cotton Rolls', description: 'Highly absorbent, medical-grade cotton rolls for moisture control.', price: 0.0, isSupply: true),
      ProductModel(id: 'sup_4', name: 'Saliva Ejector Tips', description: 'Flexible disposable saliva ejectors with non-removable comfort tips.', price: 0.0, isSupply: true),
      ProductModel(id: 'sup_5', name: 'Micro Applicator Brushes', description: 'Non-linting microbrush applicators for bonding agents and etchants.', price: 0.0, isSupply: true),
    ]);

    // Seed Branches
    branches.addAll([
      BranchModel(id: 'branch_1', name: 'Main Laboratory', address: '450 Precision Way, Suite A, New York, NY 10018', latitude: 40.7528, longitude: -73.9890),
      BranchModel(id: 'branch_2', name: 'Downtown Express Branch', address: '88 Fulton St, Brooklyn, NY 11201', latitude: 40.6931, longitude: -73.9855),
    ]);

    // Seed Orders
    final now = DateTime.now();
    orders.addAll([
      OrderModel(
        id: 'ORD-9821',
        patientName: 'Doe, John',
        toothNumbers: [14, 15],
        product: 'Zirconia Crown',
        shade: 'A2',
        coping: true,
        bakeToggle: false,
        photoUrl: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?q=80&w=300&auto=format&fit=crop',
        branch: 'Main Laboratory',
        callMeToggle: true,
        notes: 'Please maintain subtle anatomy. Margin is subgingival.',
        status: 'In Progress',
        technicianId: 'tech_1',
        technicianName: 'Alex Rivers',
        doctorId: 'doc_1',
        doctorName: 'Dr. Jane Smith',
        dateCreated: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 4)),
        labNotes: 'Model cast completed. Starting crown scan.',
      ),
      OrderModel(
        id: 'ORD-9822',
        patientName: 'Smith, Jane',
        toothNumbers: [8],
        product: 'E.Max Crown',
        shade: 'B1',
        coping: false,
        bakeToggle: true,
        photoUrl: null,
        branch: 'Downtown Express Branch',
        callMeToggle: false,
        notes: 'Incisal translucency is critical here.',
        status: 'Pending',
        doctorId: 'doc_1',
        doctorName: 'Dr. Jane Smith',
        dateCreated: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 6)),
      ),
      OrderModel(
        id: 'ORD-9823',
        patientName: 'Johnson, Robert',
        toothNumbers: [30],
        product: 'PFM Crown',
        shade: 'A3',
        coping: false,
        bakeToggle: false,
        photoUrl: null,
        branch: 'Main Laboratory',
        callMeToggle: false,
        notes: 'Standard occlusion.',
        status: 'Delivered',
        technicianId: 'tech_2',
        technicianName: 'Sarah Jenkins',
        doctorId: 'doc_1',
        doctorName: 'Dr. Jane Smith',
        dateCreated: now.subtract(const Duration(days: 8)),
        dueDate: now.subtract(const Duration(days: 1)),
        labNotes: 'Coping bake fit checked and final porcelain fired. Delivered to clinic.',
      ),
      OrderModel(
        id: 'ORD-9824',
        patientName: 'Davis, Emily',
        toothNumbers: [19],
        product: 'Implant Abutment',
        shade: 'A1',
        coping: true,
        bakeToggle: true,
        photoUrl: null,
        branch: 'Main Laboratory',
        callMeToggle: true,
        notes: 'Check connection clearance carefully.',
        status: 'Quality Check',
        technicianId: 'tech_3',
        technicianName: 'Marcus Chen',
        doctorId: 'doc_1',
        doctorName: 'Dr. Jane Smith',
        dateCreated: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 2)),
        labNotes: 'Finished custom milling. Currently checking margin precision under stereomicroscope.',
      ),
    ]);

    // Seed Bills
    bills.addAll([
      BillModel(
        id: 'INV-4001',
        orderId: 'ORD-9823',
        patientName: 'Johnson, Robert',
        productName: 'PFM Crown',
        price: 120.00,
        dateCreated: now.subtract(const Duration(days: 1)),
        isPaid: true,
      ),
      BillModel(
        id: 'INV-4002',
        orderId: 'ORD-9821',
        patientName: 'Doe, John',
        productName: 'Zirconia Crown',
        price: 300.00, // 2 crowns
        dateCreated: now.subtract(const Duration(days: 3)),
        isPaid: false,
      ),
    ]);

    // Seed Notifications
    notifications.addAll([
      NotificationModel(
        id: 'not_1',
        userId: 'doc_1',
        title: 'Case Status Update',
        message: 'Order ORD-9823 for Robert Johnson has been delivered.',
        dateCreated: now.subtract(const Duration(hours: 4)),
        isRead: false,
      ),
      NotificationModel(
        id: 'not_2',
        userId: 'doc_1',
        title: 'Case Quality Checked',
        message: 'Order ORD-9824 for Emily Davis has entered Quality Check.',
        dateCreated: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: 'not_3',
        userId: 'tech_1',
        title: 'New Case Assigned',
        message: 'You have been assigned Case ORD-9821 for John Doe.',
        dateCreated: now.subtract(const Duration(days: 3)),
        isRead: false,
      ),
    ]);
  }

  // CRUD for Products
  void saveProduct(ProductModel product) {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      products[index] = product;
    } else {
      products.add(product);
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
  }

  // CRUD for Branches
  void saveBranch(BranchModel branch) {
    final index = branches.indexWhere((b) => b.id == branch.id);
    if (index >= 0) {
      branches[index] = branch;
    } else {
      branches.add(branch);
    }
  }

  void deleteBranch(String id) {
    branches.removeWhere((b) => b.id == id);
  }

  // CRUD for Orders
  void saveOrder(OrderModel order) {
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      orders[index] = order;
    } else {
      orders.insert(0, order);
    }
  }

  // Bills Management
  void saveBill(BillModel bill) {
    final index = bills.indexWhere((b) => b.id == bill.id);
    if (index >= 0) {
      bills[index] = bill;
    } else {
      bills.insert(0, bill);
    }
  }

  // Notifications Management
  void addNotification(String userId, String title, String message) {
    notifications.insert(
      0,
      NotificationModel(
        id: 'not_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        message: message,
        dateCreated: DateTime.now(),
        isRead: false,
      ),
    );
  }

  void markNotificationRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
  }
}
