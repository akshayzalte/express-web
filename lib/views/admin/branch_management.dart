import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/admin_controller.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';

class BranchManagement extends StatelessWidget {
  const BranchManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lab Branches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () => _showBranchDialog(context),
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
          final branchList = db.branches.toList();

          if (branchList.isEmpty) {
            return Center(
              child: Text(
                'No branches configured.',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: branchList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final branch = branchList[index];
              return GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          branch.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => controller.deleteBranch(branch.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      branch.address,
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    
                    // Maps display card representation
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.black26,
                        child: Stack(
                          children: [
                            Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAaIwW5CHBTV2RSpm8A1_XXM3pnrpardPEDSv1KvYfkwPLTI5oFC6vME5MYanKCnWv1Z6gU-YkqjWKBRLDosjUCZk6Tna1rKxN8pPMt5G1mgtSrs8mbuxUrI6vl8P6mdanJUIsDeZie1KiNWsQpw7OQO8_MajCTBaxfGeZxoOSyh46yEWHy7rbIQoMZftAgzFdqhjiJSAYD6a7kfm1XaaUGbgBvdVfe0NdpThVkiMsJ5SgYopM1B75BH5Pi928Ite6YpJexEGyPsLPv',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'GPS: ${branch.latitude.toStringAsFixed(4)}, ${branch.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const Center(
                              child: Icon(Icons.pin_drop, color: Colors.redAccent, size: 30),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
            },
          );
        }),
      ),
    );
  }

  void _showBranchDialog(BuildContext context) {
    final controller = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    controller.clearBranchInputs();

    // Default mock coordinates
    controller.branchLatController.text = '40.7306';
    controller.branchLngController.text = '-73.9352';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Lab Branch',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              GlassInput(
                controller: controller.branchNameController,
                labelText: 'Branch Name',
                hintText: 'e.g. Uptown Lab Branch',
              ),
              const SizedBox(height: 12),
              GlassInput(
                controller: controller.branchAddressController,
                labelText: 'Branch Address',
                hintText: '450 Precision Way...',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassInput(
                      controller: controller.branchLatController,
                      labelText: 'Latitude',
                      hintText: '40.7306',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassInput(
                      controller: controller.branchLngController,
                      labelText: 'Longitude',
                      hintText: '-73.9352',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: controller.addBranch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
