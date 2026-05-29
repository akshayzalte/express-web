import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/doctor_controller.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';

class NewOrderForm extends StatelessWidget {
  const NewOrderForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Prescription',
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
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: [
              // Patient Details Card
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: controller.patientNameController,
                      labelText: 'Patient Full Name',
                      hintText: 'Jane Doe',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v!.isEmpty ? 'Enter patient name' : null,
                    ),
                    const SizedBox(height: 16),
                    // Due Date Picker
                    Text(
                      'Required By Date',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: controller.selectedDueDate.value,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              controller.selectedDueDate.value = picked;
                            }
                          },
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                            customBgColor: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: isDark ? Colors.white54 : Colors.black45,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      controller.selectedDueDate.value.toString().split(' ')[0],
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.edit_calendar_outlined,
                                  color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Tooth Selector Card
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tooth Selection',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to select teeth for restoration.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Upper Arch
                    Text(
                      'Upper Arch',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(16, (index) {
                          final toothNum = index + 1;
                          return _toothBox(toothNum, controller);
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: isDark ? Colors.white12 : Colors.black12),
                    const SizedBox(height: 8),

                    // Lower Arch
                    Text(
                      'Lower Arch',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(16, (index) {
                          final toothNum = 32 - index;
                          return _toothBox(toothNum, controller);
                        }),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Product specifications
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product & Specifications',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Category Selector
                    Text(
                      'Product Category',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => GlassContainer(
                          padding: EdgeInsets.zero,
                          customBgColor: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.4),
                          child: DropdownButtonFormField<String>(
                            value: controller.selectedProduct.value.isEmpty ? null : controller.selectedProduct.value,
                            items: db.products.where((p) => !p.isSupply).map((p) {
                              return DropdownMenuItem<String>(
                                value: p.name,
                                child: Text(p.name),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) controller.selectedProduct.value = v;
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                            dropdownColor: isDark ? const Color(0xFF0F1E31) : Colors.white,
                          ),
                        )),
                    const SizedBox(height: 16),

                    GlassInput(
                      controller: controller.shadeController,
                      labelText: 'Shade Selection',
                      hintText: 'A2 (e.g. A2, B1, C3)',
                      prefixIcon: Icons.palette_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Toggles Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Column(
                        children: [
                          Obx(() => SwitchListTile.adaptive(
                                title: const Text('Return for Coping Try-in'),
                                subtitle: const Text('Check coping adaptation prior to porcelain build'),
                                value: controller.returnForCoping.value,
                                activeColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                                onChanged: (v) => controller.returnForCoping.value = v,
                              )),
                          const Divider(height: 1),
                          Obx(() => SwitchListTile.adaptive(
                                title: const Text('Return for Bisque Bake'),
                                subtitle: const Text('Try-in at bisque stage prior to final glaze'),
                                value: controller.returnForBisque.value,
                                activeColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                                onChanged: (v) => controller.returnForBisque.value = v,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Upload scan/photos + Notes
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachments & Notes',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    
                    // Image Upload Button
                    Text(
                      'Upload Photos / Scans',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      final hasPhoto = controller.selectedPhotoPath.value.isNotEmpty;
                      return GestureDetector(
                        onTap: controller.pickPhoto,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white30 : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                hasPhoto ? Icons.check_circle_outline_rounded : Icons.cloud_upload_outlined,
                                size: 36,
                                color: hasPhoto 
                                    ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hasPhoto ? 'Photo Attached (Tap to change)' : 'Select Photo / Dental Scan',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasPhoto 
                                    ? controller.selectedPhotoPath.value.split('/').last 
                                    : 'Supports STL, JPG, PNG (Max 50MB)',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              if (hasPhoto && !controller.selectedPhotoPath.value.startsWith('http')) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(controller.selectedPhotoPath.value),
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    GlassInput(
                      controller: controller.notesController,
                      labelText: 'Clinical Notes / Instructions',
                      hintText: 'Add any specific instructions for the lab technician...',
                      maxLines: 4,
                      prefixIcon: Icons.note_alt_outlined,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Finalize Card
              GlassContainer(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Branch',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Obx(() => GlassContainer(
                                    padding: EdgeInsets.zero,
                                    customBgColor: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.4),
                                    child: DropdownButtonFormField<String>(
                                      value: controller.selectedBranch.value.isEmpty ? null : controller.selectedBranch.value,
                                      items: db.branches.map((b) {
                                        return DropdownMenuItem<String>(
                                          value: b.name,
                                          child: Text(b.name),
                                        );
                                      }).toList(),
                                      onChanged: (v) {
                                        if (v != null) controller.selectedBranch.value = v;
                                      },
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      dropdownColor: isDark ? const Color(0xFF0F1E31) : Colors.white,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assign Technician (Optional)',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Obx(() {
                                final techs = db.users.where((u) => u.role == 'technician').toList();
                                return GlassContainer(
                                  padding: EdgeInsets.zero,
                                  customBgColor: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.4),
                                  child: DropdownButtonFormField<String>(
                                    value: controller.selectedTechnicianId.value,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: 'auto',
                                        child: Text('Auto-Assign (Admin Choice)'),
                                      ),
                                      ...techs.map((t) {
                                        return DropdownMenuItem<String>(
                                          value: t.id,
                                          child: Text(t.name),
                                        );
                                      }),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) controller.selectedTechnicianId.value = v;
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    dropdownColor: isDark ? const Color(0xFF0F1E31) : Colors.white,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Obx(() => CheckboxListTile(
                          title: const Text('Call me regarding this case'),
                          value: controller.callMe.value,
                          activeColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                          onChanged: (v) => controller.callMe.value = v ?? false,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        )),
                    const SizedBox(height: 16),
                    
                    Obx(() => controller.isSubmitting.value
                        ? const Center(child: CircularProgressIndicator())
                        : GlassButton(
                            label: 'Submit Order',
                            icon: Icons.send_rounded,
                            onPressed: controller.submitOrder,
                          )),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toothBox(int number, DoctorController controller) {
    return Obx(() {
      final isSelected = controller.selectedTeeth.contains(number);
      final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

      return GestureDetector(
        onTap: () => controller.toggleTooth(number),
        child: Container(
          width: 38,
          height: 48,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
                : Colors.white.withOpacity(isDark ? 0.08 : 0.4),
            border: Border.all(
              color: isSelected
                  ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
                  : Colors.white.withOpacity(0.25),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }
}
