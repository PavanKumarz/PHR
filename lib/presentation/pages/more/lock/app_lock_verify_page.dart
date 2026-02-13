import 'package:flutter/material.dart';
import 'package:phr/data/services/settings_service.dart';

class AppLockVerifyPage extends StatefulWidget {
  const AppLockVerifyPage({super.key});

  @override
  State<AppLockVerifyPage> createState() => _AppLockVerifyPageState();
}

class _AppLockVerifyPageState extends State<AppLockVerifyPage> {
  final pinCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  String? pin, name, dob;
  bool loading = true;
  bool forgot = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    pin = await SettingsService.get("app_lock_pin");
    name = await SettingsService.get("app_lock_name");
    dob = await SettingsService.get("app_lock_dob");
    setState(() => loading = false);
  }

  void _verifyPin() {
    if (pinCtrl.text == pin) {
      Navigator.pop(context, true);
    } else {
      _msg("Incorrect PIN");
    }
  }

  Future<void> _recover() async {
    if (nameCtrl.text == name && dobCtrl.text == dob) {
      await SettingsService.save("app_lock_pin", "");
      Navigator.pop(context, true);
    } else {
      _msg("Details do not match");
    }
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: forgot ? _forgotUI() : _pinUI(),
        ),
      ),
    );
  }

  Widget _pinUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock, size: 60),
        const SizedBox(height: 20),
        TextField(
          controller: pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter PIN"),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _verifyPin, child: const Text("Unlock")),
        TextButton(
          onPressed: () => setState(() => forgot = true),
          child: const Text("Forgot PIN?"),
        ),
      ],
    );
  }

  Widget _forgotUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Verify Identity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: "Full Name"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: dobCtrl,
          decoration: const InputDecoration(
            labelText: "Date of Birth (yyyy-mm-dd)",
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _recover, child: const Text("Verify")),
        TextButton(
          onPressed: () => setState(() => forgot = false),
          child: const Text("Back to PIN"),
        ),
      ],
    );
  }
}
