// Import the flutter material package
import 'package:flutter/material.dart';

// Import our custom packages
import 'state/theme_state.dart';

import 'screens/burgers.dart';
import 'screens/drinks.dart';
import 'screens/cart.dart';
import 'screens/desserts.dart';
import 'screens/pizzas.dart';
import 'screens/salads.dart';

void main() {
  runApp(const HotelTabs2501());
}

class HotelTabs2501 extends StatelessWidget {
  const HotelTabs2501({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeState.instance,
      builder: (context,child){
        return MaterialApp(
        title: 'Hotel Tabs 2501',
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: ThemeState.instance.themeMode,
          home: const HotelTabsHome(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  // Method to determine the app's theme/display mode
  ThemeData _buildTheme(Brightness brightness) 
  {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: brightness,
    );

    // Our app's theme data
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'caviar',
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 1,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontFamily: 'edge_bold'),
        titleMedium: TextStyle(fontFamily: 'limelight'),
      ),
    );
  }
}

class HotelTabsHome extends StatelessWidget {
  const HotelTabsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hotel Tabs ADSE2501'),
          actions: const [_ThemeModeMenu()],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text:'🍔  Burgers'),
              Tab(text:'🍕  Pizzas'),
              Tab(text:'🍹  Drinks'),
              Tab(text:'🥗  Salads'),
              Tab(text:'🍨  Desserts'),
              Tab(text:'🛒  Cart'),
            ]
          ),
        ),
        body: const TabBarView(
          children: [
            BurgersScreen(),
            PizzasScreen(),
            DrinksScreen(),
            SaladsScreen(),
            DessertsScreen(),
            CartScreen(),
          ],
        ),
      ),
    );
  }
}


//Private class to control the application/s light/dark/system theme
class _ThemeModeMenu extends StatelessWidget {
  const _ThemeModeMenu();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeState.instance,
      builder: (context, child) {
        return PopupMenuButton<ThemeMode>(
          tooltip: 'Change theme',
          initialValue: ThemeState.instance.themeMode,
          icon: Icon(_themeModeIcon(ThemeState.instance.themeMode)),
          onSelected: ThemeState.instance.setThemeMode,
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: ListTile(
                  leading: Icon(Icons.brightness_auto),
                  title: Text('System'),
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: ListTile(
                  leading: Icon(Icons.light_mode),
                  title: Text('Light'),
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: ListTile(
                  leading: Icon(Icons.dark_mode),
                  title: Text('Dark'),
                ),
              ),
            ];
          },
        );
      },
    );
  }

  IconData _themeModeIcon(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
      ThemeMode.system => Icons.brightness_auto,
    };
  }
}
