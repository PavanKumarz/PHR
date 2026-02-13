import 'package:flutter/material.dart';

import 'package:phr/presentation/pages/home_page.dart';

import 'package:phr/presentation/pages/more/lock/app_lock_verify_page.dart';

import 'package:phr/data/services/app_lock_controller.dart';

import 'package:phr/data/services/settings_service.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _check();
  }

  Future<void> _check() async {
    final pin = await SettingsService.get("app_lock_pin");

    if (pin != null && pin.isNotEmpty && AppLockController.instance.isLocked) {
      final unlocked = await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const AppLockVerifyPage(),
        ),
      );

      if (unlocked == true) {
        AppLockController.instance.unlock();
      }
    }

    setState(() => loading = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const HomePage();
  }
}
