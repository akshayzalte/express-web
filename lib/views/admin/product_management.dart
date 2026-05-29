import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/admin_controller.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';
import '../../models/product.dart';

class ProductManagement extends StatelessWidget {
  const ProductManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Catalog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context, null),
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
          final prodList = db.products.toList();

          if (prodList.isEmpty) {
            return Center(
              child: Text(
                'No products in catalog.',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: prodList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final prod = prodList[index];
              return GlassContainer(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.layers,
                        color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                prod.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: prod.isSupply
                                      ? Colors.orange.withOpacity(0.15)
                                      : Colors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: prod.isSupply
                                        ? Colors.orange.withOpacity(0.3)
                                        : Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  prod.isSupply ? 'Supply' : 'Crown/Lab',
                                  style: TextStyle(
                                    color: prod.isSupply
                                        ? (isDark ? Colors.orange[300] : Colors.orange[800])
                                        : (isDark ? Colors.blue[300] : Colors.blue[800]),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prod.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                      onPressed: () => _showProductDialog(context, prod),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () => controller.deleteProduct(prod.id),
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

  void _showProductDialog(BuildContext context, ProductModel? product) {
    final controller = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (product != null) {
      controller.productNameController.text = product.name;
      controller.productDescController.text = product.description;
      controller.isProductSupply.value = product.isSupply;
    } else {
      controller.clearProductInputs();
    }

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
                product != null ? 'Edit Product Item' : 'Add New Product',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              GlassInput(
                controller: controller.productNameController,
                labelText: 'Product Name',
                hintText: 'e.g. Zirconia Crown',
              ),
              const SizedBox(height: 12),
              GlassInput(
                controller: controller.productDescController,
                labelText: 'Description',
                hintText: 'Translucent restoration...',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Obx(() => SwitchListTile.adaptive(
                    title: const Text('Clinic Supply / Consumable'),
                    subtitle: const Text('Available in Doctor Inventory (e.g. gloves, sleeves)'),
                    value: controller.isProductSupply.value,
                    activeColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                    onChanged: (val) => controller.isProductSupply.value = val,
                    contentPadding: EdgeInsets.zero,
                  )),
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
                    onPressed: () {
                      if (product != null) {
                        controller.editProduct(product);
                      } else {
                        controller.addProduct();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(product != null ? 'Update' : 'Add'),
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
