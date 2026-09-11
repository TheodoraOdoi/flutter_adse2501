// --------------------------------------------------------------------------
// Application's entry point
// --------------------------------------------------------------------------

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/app_constants.dart';
import 'screens/auth_gate.dart';

// Main function
Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------------------------
  // Initialise supabase before starting the flutter application
  // --------------------------------------------------------------------------

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publiKshableKey: AppConstants.supabasePublishableKey,
  );

  // Run our app
  runApp(const PersonalStudyPlannerApp());
}

class PersonalStudyPlannerApp extends StatelessWidget {
  const PersonalStudyPlannerApp({super.key});

  // --------------------------------------------------------------------------
  // App typography
  //
  //--------------------------------------------------------------------------
  // 'limelight: Gives a nice cursive font for the app title'
  // --------------------------------------------------------------------------
  TextTheme _buildTextTheme(TextTheme base)
  {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontFamily: 'Limelight',),
      displayMedium: base.displayMedium?.copyWith(fontFamily: 'Limelight',),
      displaySmall: base.displaySmall?.copyWith(fontFamily: 'Limelight',),
      headlineLarge: base.displayLarge?.copyWith(fontFamily: 'gvtime',),
      headlineMedium: base.displayMedium?.copyWith(fontFamily: 'gvtime',),
      headlineSmall: base.displaySmall?.copyWith(fontFamily: 'gvtime',),
      titleLarge: base.displayLarge?.copyWith(fontFamily: 'edge_bold',),
      titleMedium: base.displayMedium?.copyWith(fontFamily: 'edge_bold',),
      titleSmall: base.displaySmall?.copyWith(fontFamily: 'edge_bold',),
      bodyLarge: base.displayLarge?.copyWith(fontFamily: 'Limelight',),
      bodyMedium: base.displayMedium?.copyWith(fontFamily: 'caviar',),
      bodySmall: base.displaySmall?.copyWith(fontFamily: 'caviar',),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme data
    final ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo
      ),
      useMaterial3: true,
    );


    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      theme: theme.copyWith(
        textTheme: _buildTextTheme(theme.textTheme),
      ),

      home: const AuthGate(),
    );
  }
}
