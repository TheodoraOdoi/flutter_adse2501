// screen to handle user registration/sigh-up(account creation)

//----------------------------------------------------------------------
//Import required packages
//------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/auth_error_messages.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onOpenLogin,
    required this.onRegistrationComplete
  });

  final VoidCallback onOpenLogin;
  final ValueChanged<String> onRegistrationComplete;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // superbase instant client
  final _client = Supabase.instance.client;

  //-------------------------------------------
  //Controllers for registration fields
  //---------------------------------------------
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      _confirmPasswordController.dispose();
      super.dispose();
  }

  //------------------------------------------------
  // Register the user
  //--------------------------------------------------
  Future<void> _register() async
  {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      _showMessage('Please enter your email address');
      return;
    }
    if (password.isEmpty) {
      _showMessage('Please enter a password');
      return;
    }
    if (password.length < 8) {
      _showMessage('Please enter a password with 8 or more characters.');
      return;
    }
    if (password.isEmpty) {
      _showMessage('Please enter your email address');
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
      final response = await _client.auth.signUp(
          email: email, password: password);
      final user = response.user;

      if (user == null) {
        _showMessage(
            'Sorry, we could not create the account.Please try again.');
        return;
      }

      // Supabase returns a user without a session when email confirmation is enabled
      widget.onRegistrationComplete(email);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(getAuthErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //--------------------------------
  // User feedback method
  //-----------------------------------------
  void _showMessage(String message)
  {
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
        title: const Text('Create Account'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create your account',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Use your Collage or personal email'
                        'address to create your study planner account'
                  ),

                  const SizedBox(height: 32.0),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword ? Icons.visibility: Icons.visibility_off
                          ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _register(),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility: Icons.visibility_off
                          ),
                      ),
                    ),
                    ),

                  const SizedBox(height: 24.0),

                  FilledButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: _isLoading ? null : widget.onOpenLogin,
                    child: const Text('Already have an account? Sign-In'),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
