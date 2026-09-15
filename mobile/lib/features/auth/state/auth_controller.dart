import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../domain/app_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._service);

  final AuthService _service;
  AppUser? user;
  bool isCheckingSession = true;
  bool isSubmitting = false;
  String? errorMessage;

  bool get isAuthenticated => user != null;

  Future<void> restoreSession() async {
    user = await _service.restoreSession();
    isCheckingSession = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) {
    return _run(() => _service.login(email: email, password: password));
  }

  Future<bool> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) {
    return _run(
      () => _service.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      ),
    );
  }

  Future<void> logout() async {
    isSubmitting = true;
    notifyListeners();
    await _service.logout();
    user = null;
    isSubmitting = false;
    notifyListeners();
  }

  Future<bool> _run(Future<AppUser> Function() action) async {
    errorMessage = null;
    isSubmitting = true;
    notifyListeners();

    try {
      user = await action();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
