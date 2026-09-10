// User profile screen

//----------------------------------------------------------------------
//Import required packages
//------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/auth_error_messages.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.onVerificationComplete,
    required this.onBackToLogin,
  });

  // Fields to be used for email verification
  final String email;
  final VoidCallback onVerificationComplete;
  final VoidCallback onBackToLogin;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  //-------------------------------------------------------------------
  // Method to verify the email OTP
  //-------------------------------------------------------------------
  Future<void> _verifyEmail() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showMessage('Please enter the verification code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        email: widget.email,
        token: otp,
      );
      widget.onVerificationComplete();
    } on AuthException catch (e) {
      _showMessage(getAuthErrorMessage(e));
    } catch (e) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //-------------------------------------------------------------------
  // Method to resend the verification code
  //-------------------------------------------------------------------
  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      _showMessage('Verification code resent');
    } on AuthException catch (e) {
      _showMessage(getAuthErrorMessage(e));
    } catch (e) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  //------------------------------------------
  // User feedback method
  //------------------------------------------
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
        leading: IconButton(
          onPressed: _isLoading ? null : widget.onBackToLogin,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 72,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Check your email",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    "We sent a verification code to:",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: 'Verification code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  FilledButton(
                    onPressed: _isLoading ? null : _verifyEmail,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Verify email'),
                  ),
                  const SizedBox(height: 16.0),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _resendCode,
                    child: _isResending
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Resend verification code'),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: _isLoading ? null : widget.onBackToLogin,
                    child: const Text('Return to sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}