import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../models/patient.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';

class DoctorPatients extends StatefulWidget {
  const DoctorPatients({super.key});

  @override
  State<DoctorPatients> createState() => _DoctorPatientsState();
}

class _DoctorPatientsState extends State<DoctorPatients> {
  final db = Get.find<DatabaseService>();
  final auth = Get.find<AuthService>();
  
  final searchQuery = ''.obs;
  final TextEditingController _searchController = TextEditingController();

  // Add Patient Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _bpController = TextEditingController();
  final _ailmentController = TextEditingController();
  final _clinicalHistoryController = TextEditingController();
  
  final _selectedGender = 'Male'.obs;
  final _hasAilment = false.obs;
  final selectedDob = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _bpController.dispose();
    _ailmentController.dispose();
    _clinicalHistoryController.dispose();
    super.dispose();
  }

  void _clearAddPatientForm() {
    _nameController.clear();
    _dobController.clear();
    _ageController.clear();
    _bpController.clear();
    _ailmentController.clear();
    _clinicalHistoryController.clear();
    _selectedGender.value = 'Male';
    _hasAilment.value = false;
    selectedDob.value = '';
  }

  void _showAddPatientDialog(BuildContext context) {
    _clearAddPatientForm();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F1E31) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add New Patient',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: 400,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassInput(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'John Smith',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v!.isEmpty ? 'Enter patient name' : null,
                    ),
                    const SizedBox(height: 12),
                    Obx(() => GlassInput(
                      controller: _dobController,
                      labelText: 'Date of Birth (DOB)',
                      hintText: 'Select Date of Birth...',
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: isDark
                                    ? const ColorScheme.dark(
                                        primary: Color(0xFF00ADB5),
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF0F1E31),
                                        onSurface: Colors.white70,
                                      )
                                    : const ColorScheme.light(
                                        primary: Color(0xFF007A87),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black87,
                                      ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          // Standard DD-MM-YYYY format
                          String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year.toString().padLeft(4, '0')}";
                          _dobController.text = formattedDate;
                          selectedDob.value = formattedDate;
                          
                          // Calculate age automatically
                          int age = DateTime.now().year - pickedDate.year;
                          if (DateTime.now().month < pickedDate.month ||
                              (DateTime.now().month == pickedDate.month && DateTime.now().day < pickedDate.day)) {
                            age--;
                          }
                          _ageController.text = age.toString();
                        }
                      },
                      suffixIcon: selectedDob.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _dobController.clear();
                                _ageController.clear();
                                selectedDob.value = '';
                              },
                            )
                          : Icon(
                              Icons.arrow_drop_down_rounded,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                      validator: (v) => v!.isEmpty ? 'Select Date of Birth' : null,
                    )),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GlassInput(
                            controller: _ageController,
                            labelText: 'Age',
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.cake_outlined,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter age';
                              if (int.tryParse(v) == null) return 'Invalid age';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0, bottom: 6.0),
                                child: Text(
                                  'Gender',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedGender.value,
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF0F1E31) : Colors.white,
                                        items: ['Male', 'Female', 'Other'].map((g) {
                                          return DropdownMenuItem<String>(
                                            value: g,
                                            child: Text(g),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) _selectedGender.value = val;
                                        },
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GlassInput(
                      controller: _bpController,
                      labelText: 'Blood Pressure',
                      hintText: '120/80 mmHg',
                      prefixIcon: Icons.favorite_border_rounded,
                      validator: (v) => v!.isEmpty ? 'Enter blood pressure' : null,
                    ),
                    const SizedBox(height: 12),
                    Obx(() => CheckboxListTile(
                          title: const Text('Any Medical History / Chronic Illness?'),
                          value: _hasAilment.value,
                          activeColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                          onChanged: (v) => _hasAilment.value = v ?? false,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        )),
                    Obx(() => _hasAilment.value
                        ? GlassInput(
                            controller: _ailmentController,
                            labelText: 'Medical History Details',
                            hintText: 'e.g., Diabetes, Hypertension, Asthma, Penicillin Allergy',
                            prefixIcon: Icons.healing_outlined,
                            maxLines: 2,
                            validator: (v) => (_hasAilment.value && (v == null || v.isEmpty))
                                ? 'Specify medical history details'
                                : null,
                          )
                        : const SizedBox.shrink()),
                    const SizedBox(height: 12),
                    GlassInput(
                      controller: _clinicalHistoryController,
                      labelText: 'Clinical History (Past Dental Treatments)',
                      hintText: 'e.g., Root Canal on 14, Extraction on 36, Crown on 46',
                      prefixIcon: Icons.history_rounded,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            GlassButton(
              label: 'Save',
              icon: Icons.check,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newPatient = PatientModel(
                    id: 'pat_${DateTime.now().millisecondsSinceEpoch}',
                    name: _nameController.text.trim(),
                    age: int.parse(_ageController.text.trim()),
                    gender: _selectedGender.value,
                    bloodPressure: _bpController.text.trim(),
                    hasAilment: _hasAilment.value,
                    ailmentDetails: _hasAilment.value ? _ailmentController.text.trim() : 'None',
                    doctorId: auth.currentUser.value?.id ?? 'doc_1',
                    dob: _dobController.text.trim(),
                    clinicalHistory: _clinicalHistoryController.text.trim(),
                  );
                  db.savePatient(newPatient);
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'Success',
                    '${newPatient.name} added to patients database.',
                    backgroundColor: const Color(0xFF1D9E75),
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patients Directory',
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
                    hintText: 'Search patients by name or condition...',
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
            
            // Patients List
            Expanded(
              child: Obx(() {
                final query = searchQuery.value.toLowerCase().trim();
                final patientsList = db.patients.where((p) {
                  return p.doctorId == (auth.currentUser.value?.id ?? 'doc_1') && 
                      (p.name.toLowerCase().contains(query) ||
                      p.ailmentDetails.toLowerCase().contains(query));
                }).toList();

                if (patientsList.isEmpty) {
                  return Center(
                    child: Text(
                      'No patients found.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  itemCount: patientsList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final patient = patientsList[index];
                    final hasHistory = patient.hasAilment;
                    
                    return GlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                patient.gender.toLowerCase() == 'male' 
                                    ? Icons.face_rounded 
                                    : (patient.gender.toLowerCase() == 'female' ? Icons.face_3_rounded : Icons.person),
                                color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        patient.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${patient.age}y / ${patient.gender[0]}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.favorite_border_rounded, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'BP: ${patient.bloodPressure}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white60 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Medical History Tags
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (hasHistory) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.warning_amber_rounded, size: 10, color: Colors.redAccent),
                                              const SizedBox(width: 4),
                                              Text(
                                                patient.ailmentDetails,
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle_outline, size: 10, color: Colors.green),
                                              SizedBox(width: 4),
                                              Text(
                                                'No health alerts',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (patient.clinicalHistory != null &&
                                          patient.clinicalHistory!.isNotEmpty &&
                                          patient.clinicalHistory != 'None') ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00ADB5).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFF00ADB5).withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.history_rounded, size: 10, color: Color(0xFF00ADB5)),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Clin. History: ${patient.clinicalHistory}',
                                                style: const TextStyle(
                                                  color: Color(0xFF00ADB5),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientDialog(context),
        backgroundColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
