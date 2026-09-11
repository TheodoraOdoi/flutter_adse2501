// --------------------------------------------------------------------------
// Application's Splash Screen
// --------------------------------------------------------------------------

// Imports
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'gvtime',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            const CircularProgressIndicator(),
            const SizedBox(height: 16.0),
            const Text('Check your session...')
          ],
        ),
      ),
    );
  }
}
