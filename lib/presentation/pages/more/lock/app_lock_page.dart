import 'package:flutter/material.dart';

import 'package:phr/data/services/settings_service.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  String? savedPin;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController oldPinCtrl = TextEditingController();
  final TextEditingController newPinCtrl = TextEditingController();
  final TextEditingController confirmPinCtrl = TextEditingController();

  bool loading = true;

  bool showSet = false;

  bool showChange = false;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    savedPin = await SettingsService.get("app_lock_pin");

    setState(() => loading = false);
  }

  Future<void> _setPin() async {
    if (nameCtrl.text.isEmpty || dobCtrl.text.isEmpty) {
      _msg("Name & DOB required");
      return;
    }

    if (newPinCtrl.text.length < 4 || newPinCtrl.text != confirmPinCtrl.text) {
      _msg("Invalid PIN");
      return;
    }

    await SettingsService.save("app_lock_pin", newPinCtrl.text);

    await SettingsService.save("app_lock_name", nameCtrl.text.trim());
    await SettingsService.save("app_lock_dob", dobCtrl.text.trim());

    _msg("App lock enabled", success: true);

    Navigator.pop(context, true);
  }

  Future<void> _changePin() async {
    if (oldPinCtrl.text != savedPin) {
      _msg("Old PIN incorrect");
      return;
    }

    if (newPinCtrl.text.length < 4 || newPinCtrl.text != confirmPinCtrl.text) {
      _msg("Invalid PIN");
      return;
    }

    await SettingsService.save("app_lock_pin", newPinCtrl.text);

    _msg("PIN updated", success: true);

    Navigator.pop(context, true);
  }

  Future<void> _remove() async {
    await SettingsService.save("app_lock_pin", "");
    await SettingsService.save("app_lock_name", "");
    await SettingsService.save("app_lock_dob", "");

    _msg("App lock removed", success: true);

    Navigator.pop(context, true);
  }

  void _msg(String t, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {bool num = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,

        keyboardType: num ? TextInputType.number : TextInputType.text,

        obscureText: num,

        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasPin = savedPin != null && savedPin!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("App Lock")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!hasPin) ...[
            ElevatedButton(
              onPressed: () => setState(() => showSet = !showSet),
              child: const Text("Set App Lock"),
            ),

            if (showSet) ...[
              const SizedBox(height: 20),
              _field("Full Name", nameCtrl),
              _field("Date of Birth (yyyy-mm-dd)", dobCtrl),
              _field("New PIN", newPinCtrl, num: true),
              _field("Confirm PIN", confirmPinCtrl, num: true),
              ElevatedButton(onPressed: _setPin, child: const Text("Save")),
            ],
          ],

          if (hasPin) ...[
            ElevatedButton(
              onPressed: () => setState(() => showChange = !showChange),
              child: const Text("Change PIN"),
            ),

            if (showChange) ...[
              const SizedBox(height: 20),
              _field("Old PIN", oldPinCtrl, num: true),
              _field("New PIN", newPinCtrl, num: true),
              _field("Confirm PIN", confirmPinCtrl, num: true),
              ElevatedButton(
                onPressed: _changePin,
                child: const Text("Update"),
              ),
            ],

            TextButton(
              onPressed: _remove,
              child: const Text(
                "Remove App Lock",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
