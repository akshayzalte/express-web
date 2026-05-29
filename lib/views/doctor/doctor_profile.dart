import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/doctor_controller.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/tile_map_widget.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final auth = Get.find<AuthService>();
  final docCtrl = Get.find<DoctorController>();

  late TextEditingController nameController;
  late TextEditingController clinicController;
  late TextEditingController addressController;
  late double lat;
  late double lng;
  
  bool isDarkTheme = Get.isDarkMode;

  @override
  void initState() {
    super.initState();
    final user = auth.currentUser.value;
    nameController = TextEditingController(text: user?.name);
    clinicController = TextEditingController(text: user?.clinicName);
    addressController = TextEditingController(text: user?.address);
    lat = user?.latitude ?? 19.0760;
    lng = user?.longitude ?? 72.8777;

    addressController.addListener(() {
      final addr = addressController.text.trim();
      if (addr.isNotEmpty) {
        final coords = _simulateGeocode(addr);
        setState(() {
          lat = coords['lat']!;
          lng = coords['lng']!;
        });
      }
    });
  }

  Map<String, double> _simulateGeocode(String address) {
    final addr = address.toLowerCase().trim();
    if (addr.isEmpty) {
      return {'lat': 19.0760, 'lng': 72.8777};
    }
    
    if (addr.contains(',')) {
      final parts = addr.split(',');
      if (parts.length == 2) {
        final latVal = double.tryParse(parts[0].trim());
        final lngVal = double.tryParse(parts[1].trim());
        if (latVal != null && lngVal != null) {
          return {'lat': latVal, 'lng': lngVal};
        }
      }
    }
    
    if (addr.contains('mumbai') || addr.contains('bandra') || addr.contains('dadar') || addr.contains('andheri') || addr.contains('colaba') || addr.contains('chembur')) {
      double offset = (address.length % 5) * 0.003;
      return {'lat': 19.0760 + offset, 'lng': 72.8777 - offset};
    }
    if (addr.contains('pune') || addr.contains('kothrud') || addr.contains('hinjewadi') || addr.contains('hadapsar') || addr.contains('chinchwad')) {
      double offset = (address.length % 5) * 0.003;
      return {'lat': 18.5204 + offset, 'lng': 73.8567 - offset};
    }
    if (addr.contains('nagpur')) {
      return {'lat': 21.1458, 'lng': 79.0882};
    }
    if (addr.contains('nashik') || addr.contains('nasik')) {
      return {'lat': 19.9975, 'lng': 73.7898};
    }
    if (addr.contains('thane')) {
      return {'lat': 19.2183, 'lng': 72.9781};
    }
    
    final int hash = address.hashCode;
    final double latOffset = (hash % 100) / 2000.0;
    final double lngOffset = ((hash >> 2) % 100) / 2000.0;
    return {'lat': 19.0760 + latOffset, 'lng': 72.8777 + lngOffset};
  }

  @override
  void dispose() {
    nameController.dispose();
    clinicController.dispose();
    addressController.dispose();
    super.dispose();
  }


  void saveProfile() {
    final updatedUser = auth.currentUser.value?.copyWith(
      name: nameController.text,
      clinicName: clinicController.text,
      address: addressController.text,
      latitude: lat,
      longitude: lng,
    );
    if (updatedUser != null) {
      auth.currentUser.value = updatedUser;
      Get.snackbar('Success', 'Profile updated successfully!',
          backgroundColor: const Color(0xFF1D9E75), colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
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
            // Profile Image Header
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final photo = auth.currentUser.value?.profilePhotoUrl;
                    final hasLocalPhoto = docCtrl.selectedPhotoPath.value.isNotEmpty;
                    
                    ImageProvider imgProvider;
                    if (hasLocalPhoto && !docCtrl.selectedPhotoPath.value.startsWith('http')) {
                      imgProvider = FileImage(File(docCtrl.selectedPhotoPath.value));
                    } else if (photo != null) {
                      imgProvider = NetworkImage(photo);
                    } else {
                      imgProvider = const NetworkImage('https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=200&auto=format&fit=crop');
                    }

                    return Hero(
                      tag: 'profile_avatar',
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38, width: 3),
                          image: DecorationImage(
                            image: imgProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        await docCtrl.pickPhoto();
                        if (docCtrl.selectedPhotoPath.value.isNotEmpty) {
                          auth.updateProfilePhoto(docCtrl.selectedPhotoPath.value);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),

            // Profile info inputs card
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinic Details',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  GlassInput(
                    controller: nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  GlassInput(
                    controller: clinicController,
                    labelText: 'Clinic Name',
                    prefixIcon: Icons.business,
                  ),
                  const SizedBox(height: 16),
                  GlassInput(
                    controller: addressController,
                    labelText: 'Clinic Address',
                    prefixIcon: Icons.location_city,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Map Pin Section
                  Text(
                    'Location Coordinates',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 120,
                      color: Colors.black26,
                      child: Stack(
                        children: [
                           TileMapWidget(
                             latitude: lat,
                             longitude: lng,
                             height: 120,
                           ),
                           Positioned.fill(
                             child: InkWell(
                               onTap: () {
                                 setState(() {
                                   lat = lat + 0.001;
                                   lng = lng + 0.001;
                                 });
                                 Get.snackbar('Coordinates Updated', 'Custom location pin adjusted.');
                               },
                              child: Container(
                                color: Colors.black12,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                        ),
                                      ),
                                      const Text(
                                        'Tap to adjust pin location',
                                        style: TextStyle(color: Colors.white70, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),

            // Settings & Preferences Card
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    title: const Text('Dark Mode Theme'),
                    subtitle: const Text('Render app surfaces in midnight blue'),
                    value: isDarkTheme,
                    activeColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                    onChanged: (v) {
                      setState(() {
                        isDarkTheme = v;
                      });
                      Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                    },

                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Save Profile Button
            GlassButton(
              label: 'Save Profile Changes',
              icon: Icons.save_rounded,
              onPressed: saveProfile,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
