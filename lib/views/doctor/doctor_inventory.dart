import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';

class DoctorInventory extends StatefulWidget {
  const DoctorInventory({super.key});

  @override
  State<DoctorInventory> createState() => _DoctorInventoryState();
}

class _DoctorInventoryState extends State<DoctorInventory> {
  final db = Get.find<DatabaseService>();
  final searchQuery = ''.obs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lab Catalog & Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
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
        child: Column(
          children: [
            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 16,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              searchQuery.value = '';
                            },
                          )
                        : const SizedBox.shrink()),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
            
            // Products List
            Expanded(
              child: Obx(() {
                final query = searchQuery.value.toLowerCase().trim();
                final prodList = db.products.where((p) {
                  return p.isSupply && (p.name.toLowerCase().contains(query) ||
                      p.description.toLowerCase().contains(query));
                }).toList();

                if (prodList.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                              Icons.layers_outlined,
                              color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prod.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prod.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
