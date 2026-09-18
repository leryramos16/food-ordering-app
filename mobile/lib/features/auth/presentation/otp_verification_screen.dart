import 'dart:async';

import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import 'auth_layout.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.authController,
    required this.phone,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final AuthController authController;
  final String phone;

  // Kept so "Resend code" can re-submit the same registration form without
  // the user having to type everything again.
  final String name;
  final String email;
  final String password;
  final String role;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _resendCooldown = Duration(seconds: 60);

  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendCooldown.inSeconds;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _secondsLeft = _resendCooldown.inSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) => AuthLayout(
        title: 'Verify your phone',
        subtitle: 'Enter the 6-digit code we texted to ${widget.phone}.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  labelText: 'Verification code',
                  counterText: '',
                ),
                validator: (value) => value == null || value.trim().length != 6
                    ? 'Enter the 6-digit code.'
                    : null,
              ),
              if (widget.authController.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.authController.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: widget.authController.isSubmitting ? null : _verify,
                child: widget.authController.isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify and continue'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    _secondsLeft > 0 || widget.authController.isSubmitting
                    ? null
                    : _resend,
                child: Text(
                  _secondsLeft > 0
                      ? 'Resend code in ${_secondsLeft}s'
                      : 'Resend code',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authController.verifyRegistrationOtp(
      widget.phone,
      _code.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _resend() async {
    final success = await widget.authController.requestRegistrationOtp(
      widget.name,
      widget.email,
      widget.phone,
      widget.password,
      widget.role,
    );

    if (success) {
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('A new code was sent.')));
      }
    }
  }
}
