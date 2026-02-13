import 'package:flutter/material.dart';

class ImportBackupPage extends StatelessWidget {
  const ImportBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Import Backup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Select a backup file to restore",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Choose Backup File"),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
