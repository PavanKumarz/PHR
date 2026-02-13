import 'package:flutter/widgets.dart';

import 'package:phr/data/services/settings_service.dart';

class AppLockController with WidgetsBindingObserver {
  static final AppLockController instance = AppLockController._();

  AppLockController._();

  bool _isLocked = false;

  bool get isLocked => _isLocked;
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> lockIfEnabled() async {
    final pin = await SettingsService.get("app_lock_pin");
    _isLocked = pin != null && pin.isNotEmpty;
  }

  void unlock() {
    _isLocked = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      lockIfEnabled();
    }
  }
}
