// screen to handle user login/sigh-ip(account creation)

//----------------------------------------------------------------------
//Import required packages
//------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/auth_error_messages.dart';

class PasswordResetScreen extends StatefulWidget {
  // Fields
  final String? initialEmail;
  final bool recoveryMode;
  final VoidCallback onBackToLogin;
  final VoidCallback onPasswordResetComplete;

  // Constructor
  const PasswordResetScreen(
      {
        super.key,
        required this.initialEmail,
        required this.recoveryMode,
        required this.onBackToLogin,
        required this.onPasswordResetComplete
      });

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  // Supabase client
  final _client = Supabase.instance.client;

  //----------------------------------------------------------
  // Controllers for password reset/recovery fields
  //------------------------------------------------------------
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  bool _recoveryMode = false;

  @override
  void initState() {
    super.initState();

    _emailController.text = widget.initialEmail ?? "";
    _recoveryMode = widget.recoveryMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //-------------------------------------------------------
  // Method to send password recovery email
  //-------------------------------------------------------
  Future<void> _sendRecoveryEmail() async
  {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _client.auth.resetPasswordForEmail(email);

      if (!mounted) {
        return;
      }
      setState(() {
        _emailSent = true;
      });

      _showMessage(
          'If there is an account for this email address, a recovery code has been sent.');
    }
    catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(getAuthErrorMessage(error));
    }
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //------------------------------------------
  // Method to verify password recovery OTP
  //---------------------------------------------
  Future<void> _verifyRecoveryCode() async
  {
    final email = _emailController.text.trim();
    final token = _otpController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address');
      return;
    }
    if (token.isEmpty) {
      _showMessage('Please enter the recovery code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _client.auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.recovery
      );

      if (response.session == null) {
        _showMessage(
            'The recovery code could not create a valid recovery session.');
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _recoveryMode = true;
      });
    }
    catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(getAuthErrorMessage(error));
    }
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //-----------------------------------------------
  // Method to update password
  //-------------------------------------------------
  Future<void> _updatePassword() async
  {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      _showMessage('Please enter a new password');
      return;
    }
    if (password.length < 8) {
      _showMessage('Please enter a password with 8 or more characters');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('The passwords entered do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _client.auth.updateUser(UserAttributes(password: password),);
      await _client.auth.signOut();
      if (!mounted) {
        return;
      }
      _showMessage('Your password has been changed. Please login/sign-in with'
          'your new password.');

      widget.onPasswordResetComplete();
    }
    catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(getAuthErrorMessage(error));
    }
    finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  //-----------------------------------------
  // User feedback method
  //-------------------------------------------
  void _showMessage(String message)
  {
    ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message)),
    );
  }

  Widget _buildEmailField()
  {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showPasswordFields = _recoveryMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
        leading: IconButton(
          onPressed: _isLoading? null: widget.onBackToLogin,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: 500
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset_rounded, size: 72,),
                  const SizedBox(height: 24.0),
                  Text(showPasswordFields
                  ? 'Choose a new password'
                  : 'Reset your password',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0),

                  Text(showPasswordFields
                      ? 'Enter a new password for your account'
                      : 'Enter your email address and we will send you a recovery code.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),
                ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
