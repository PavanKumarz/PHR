import 'package:flutter/material.dart';
import 'package:phr/data/services/settings_service.dart';

class EmergencyInfoPage extends StatefulWidget {
  const EmergencyInfoPage({super.key});

  @override
  State<EmergencyInfoPage> createState() => _EmergencyInfoPageState();
}

class _EmergencyInfoPageState extends State<EmergencyInfoPage> {
  final TextEditingController conditions = TextEditingController();
  final TextEditingController allergies = TextEditingController();
  final TextEditingController medications = TextEditingController();
  final TextEditingController doctor = TextEditingController();
  final TextEditingController notes = TextEditingController();

  bool loading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    conditions.text = await SettingsService.get("emg_conditions") ?? "";
    allergies.text = await SettingsService.get("emg_allergies") ?? "";
    medications.text = await SettingsService.get("emg_medications") ?? "";
    doctor.text = await SettingsService.get("emg_doctor") ?? "";
    notes.text = await SettingsService.get("emg_notes") ?? "";

    setState(() => loading = false);
  }

  Future<void> saveData() async {
    await SettingsService.save("emg_conditions", conditions.text);
    await SettingsService.save("emg_allergies", allergies.text);
    await SettingsService.save("emg_medications", medications.text);
    await SettingsService.save("emg_doctor", doctor.text);
    await SettingsService.save("emg_notes", notes.text);

    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
            ),
          ),
        ),
        title: const Text("Emergency Information"),
        centerTitle: true,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [_infoCard()],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Critical Medical Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          isEditing
              ? _editField(
                  "Medical Conditions",
                  conditions,
                  Icons.medical_information,
                  lines: 3,
                )
              : _viewField(
                  "Medical Conditions",
                  conditions.text,
                  Icons.medical_information,
                ),

          isEditing
              ? _editField("Allergies", allergies, Icons.warning, lines: 3)
              : _viewField("Allergies", allergies.text, Icons.warning),

          isEditing
              ? _editField(
                  "Medications",
                  medications,
                  Icons.medication,
                  lines: 3,
                )
              : _viewField("Medications", medications.text, Icons.medication),

          isEditing
              ? _editField("Doctor / Hospital", doctor, Icons.local_hospital)
              : _viewField(
                  "Doctor / Hospital",
                  doctor.text,
                  Icons.local_hospital,
                ),

          isEditing
              ? _editField("Additional Notes", notes, Icons.note, lines: 3)
              : _viewField("Additional Notes", notes.text, Icons.note),

          const SizedBox(height: 24),

          if (isEditing)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Save", style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _viewField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          alignLabelWithHint: true,
          filled: true,
          fillColor: const Color(0xFFF2F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
