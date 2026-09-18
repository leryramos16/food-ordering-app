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

  /// Returns true if the code was sent. Doesn't touch [user] — no account
  /// exists until the code is verified.
  Future<bool> requestRegistrationOtp(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async {
    errorMessage = null;
    isSubmitting = true;
    notifyListeners();

    try {
      await _service.requestRegistrationOtp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> verifyRegistrationOtp(String phone, String code) {
    return _run(() => _service.verifyRegistrationOtp(phone: phone, code: code));
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
