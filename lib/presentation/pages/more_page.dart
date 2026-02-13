import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phr/presentation/pages/more/cardPages/bp_tracking_page.dart';
import 'package:phr/presentation/pages/more/emergency_contacts_page.dart';
import 'package:phr/presentation/pages/more/emergency_info_page.dart';
import 'package:phr/presentation/pages/more/export_backup_page.dart';
import 'package:phr/presentation/pages/more/import_backup_page.dart';
import 'package:phr/presentation/pages/more/lock/app_lock_page.dart';
import 'package:phr/presentation/pages/more/cardPages/medical_cards_page.dart';
import 'package:phr/presentation/pages/more/personal_info_page.dart';
import 'package:phr/presentation/pages/more/storage_usage_page.dart';
import 'package:phr/presentation/pages/more/cardPages/sugar_tracking_page.dart';
import 'package:phr/presentation/pages/more/cardPages/weight_tracking_page.dart';

import 'package:phr/data/services/data_wipe_service.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("More"),
        centerTitle: true,
        elevation: 1.5,
      ),

      body: ListView(
        children: [
          _sectionTitle("Profile"),
          _tile(
            icon: Icons.person,
            title: "Personal Information",
            subtitle: "Age, gender, blood group, etc.",
            onTap: () => _open(context, const PersonalInfoPage()),
          ),

          _sectionTitle("Emergency"),
          _tile(
            icon: Icons.emergency,
            title: "Emergency Info",
            subtitle: "Contacts & critical health info",
            onTap: () => _open(context, const EmergencyInfoPage()),
          ),
          _tile(
            icon: Icons.contact_phone,
            title: "Emergency Contacts",
            subtitle: "Add people to reach in emergencies",
            onTap: () => _open(context, const EmergencyContactsPage()),
          ),

          _sectionTitle("Security"),
          _tile(
            icon: Icons.lock,
            title: "App Lock (PIN)",
            subtitle: "Set, change or remove app PIN",
            onTap: () => _open(context, const AppLockPage()),
          ),

          _sectionTitle("Data & Backup"),
          _tile(
            icon: Icons.backup,
            title: "Export Backup",
            subtitle: "Backup all data offline",
            onTap: () => _open(context, const ExportBackupPage()),
          ),
          _tile(
            icon: Icons.restore,
            title: "Import Backup",
            subtitle: "Restore from backup file",
            onTap: () => _open(context, const ImportBackupPage()),
          ),
          _tile(
            icon: Icons.storage,
            title: "Storage Usage",
            subtitle: "Database, files, audio usage",
            onTap: () => _open(context, const StorageUsagePage()),
          ),

          _sectionTitle("Health Settings"),
          _tile(
            icon: Icons.monitor_heart,
            title: "Blood Pressure Tracking",
            subtitle: "Enable/disable BP logs",
            onTap: () => _open(context, const BPTrackingPage()),
          ),
          _tile(
            icon: Icons.bloodtype,
            title: "Blood Sugar Tracking",
            subtitle: "Enable/disable Sugar logs",
            onTap: () => _open(context, const SugarTrackingPage()),
          ),
          _tile(
            icon: Icons.fitness_center,
            title: "Weight Tracking",
            subtitle: "Enable/disable weight logs",
            onTap: () => _open(context, const WeightTrackingPage()),
          ),
          _tile(
            icon: Icons.medical_information,
            title: "Medical Cards",
            subtitle: "e-Card, Insurance, reports",
            onTap: () => _open(context, const MedicalcardsPage()),
          ),

          _sectionTitle("Danger Zone"),
          _dangerTile(
            icon: Icons.delete_forever,
            title: "Delete All Data",
            subtitle: "Erase everything (cannot be undone)",
            onTap: () => _confirmDeleteAll(context),
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Future<void> _confirmDeleteAll(BuildContext context) async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("⚠️ Delete All Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "This will permanently delete ALL your data.\n\n"
                "Notes, medical cards, health records, settings.\n\n"
                "This action CANNOT be undone.",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Type DELETE to confirm",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
              onPressed: () {
                if (controller.text.trim() == "DELETE") {
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteAllData(context);
    }
  }

  static Future<void> _deleteAllData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await DataWipeService.wipeEverything();

    Navigator.of(context).pop();

    await Future.delayed(const Duration(milliseconds: 300));

    SystemNavigator.pop();
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  static Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
      ),
    );
  }

  static Widget _dangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.red[100],
          child: Icon(icon, color: Colors.red[700]),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      ),
    );
  }
}
