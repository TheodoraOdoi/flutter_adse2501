// --------------------------------------------------------------------------
// File to handle authentication state and navigation
// --------------------------------------------------------------------------

// Imports
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'email_verification_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'password_reset_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';

enum AuthPage {
  login,
  register,
  verifyEmail,
  passwordReset,
  home,
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _client = Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;

  Session? _session;

  AuthPage _currentPage = AuthPage.login;

  String? _verificationEmail;
  String? _resetEmail;

  bool _isCheckingSession = true;
  bool _isPasswordRecovery = false;

  @override
  void initState() {
    super.initState();

    _listenToAuthChanges();
    _checkInitialSession();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Session initialisation
  // ---------------------------------------------------------------------------

  Future<void> _checkInitialSession() async {
    try {
      final session = await _client.auth.getSession();

      if (!mounted) {
        return;
      }

      _session = session;

      if (session == null) {
        setState(() {
          _currentPage = AuthPage.login;
          _isCheckingSession = false;
        });

        return;
      }

      final user = session.user;

      if (user.emailConfirmedAt == null) {
        setState(() {
          _verificationEmail = user.email;
          _currentPage = AuthPage.verifyEmail;
          _isCheckingSession = false;
        });

        return;
      }

      setState(() {
        _currentPage = AuthPage.home;
        _isCheckingSession = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _session = null;
        _currentPage = AuthPage.login;
        _isCheckingSession = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Authentication state listener
  // ---------------------------------------------------------------------------

  void _listenToAuthChanges() {
    _authSubscription = _client.auth.onAuthStateChange.listen(
          (authState) {
        if (!mounted) {
          return;
        }

        final event = authState.event;
        final session = authState.session;

        if (event == AuthChangeEvent.signedOut) {
          setState(() {
            _session = null;
            _verificationEmail = null;
            _resetEmail = null;
            _isPasswordRecovery = false;
            _currentPage = AuthPage.login;
          });

          return;
        }

        if (event == AuthChangeEvent.passwordRecovery) {
          setState(() {
            _session = session;
            _resetEmail = session?.user.email;
            _isPasswordRecovery = true;
            _currentPage = AuthPage.passwordReset;
          });

          return;
        }

        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed ||
            event == AuthChangeEvent.userUpdated) {
          _session = session;

          if (session == null) {
            setState(() {
              _currentPage = AuthPage.login;
            });

            return;
          }

          // Do not leave the password reset screen while the recovery
          // session is being used to choose the new password.
          if (_currentPage == AuthPage.passwordReset) {
            return;
          }

          final user = session.user;

          if (user.emailConfirmedAt == null) {
            setState(() {
              _verificationEmail = user.email;
              _currentPage = AuthPage.verifyEmail;
            });

            return;
          }

          setState(() {
            _currentPage = AuthPage.home;
          });
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted) {
          return;
        }

        setState(() {
          _session = null;
          _currentPage = AuthPage.login;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Authentication page navigation
  // ---------------------------------------------------------------------------

  void _showLogin() {
    setState(() {
      _currentPage = AuthPage.login;
    });
  }

  void _showRegister() {
    setState(() {
      _currentPage = AuthPage.register;
    });
  }

  void _showPasswordReset() {
    setState(() {
      _resetEmail = null;
      _isPasswordRecovery = false;
      _currentPage = AuthPage.passwordReset;
    });
  }

  void _showVerification(String email) {
    setState(() {
      _verificationEmail = email;
      _currentPage = AuthPage.verifyEmail;
    });
  }

  void _showHome() {
    final session = _client.auth.currentSession;

    if (session == null) {
      _showLogin();
      return;
    }

    setState(() {
      _session = session;
      _currentPage = AuthPage.home;
    });
  }

  void _handleRegistration(String email) {
    setState(() {
      _verificationEmail = email;
      _currentPage = AuthPage.verifyEmail;
    });
  }

  void _handlePasswordRecoveryComplete() {
    _showLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const SplashScreen();
    }

    switch (_currentPage) {
      case AuthPage.login:
        return LoginScreen(
          onOpenRegister: _showRegister,
          onOpenPasswordReset: _showPasswordReset,
          onOpenVerification: _showVerification,
          onLoggedIn: _showHome,
        );

      case AuthPage.register:
        return RegisterScreen(
          onOpenLogin: _showLogin,
          onRegistrationComplete: _handleRegistration,
        );

      case AuthPage.verifyEmail:
        return EmailVerificationScreen(
          email: _verificationEmail ?? '',
          onVerificationComplete: _showHome,
          onBackToLogin: _showLogin,
        );

      case AuthPage.passwordReset:
        return PasswordResetScreen(
          initialEmail: _resetEmail,
          recoveryMode: _isPasswordRecovery,
          onBackToLogin: _showLogin,
          onPasswordResetComplete: _handlePasswordRecoveryComplete,
        );

      case AuthPage.home:
        return HomeScreen(
          session: _session,
        );
    }
  }
}