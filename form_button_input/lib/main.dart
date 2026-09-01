import 'package:flutter/material.dart';
import 'package:form_button_input/screens/buttons.dart';
import 'package:form_button_input/widgets/rounded_button.dart';
import 'screens/input.dart';
import 'screens/register.dart';

// Application's entry point
void main()
{
  runApp(const StackButtonInputApp());
}

class StackButtonInputApp extends StatelessWidget {
  const StackButtonInputApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Stack Button Form Inputs App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontFamily: 'limelight'),
          titleMedium: TextStyle(fontFamily: 'limelight'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // set a solid background colour
          foregroundColor: Colors.white, // set text colour to white
          titleTextStyle: const TextStyle(
            fontFamily: 'limelight',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Ensure the text is white
          ),
        ),
      ),
      // set the home screen
      home: const SafeArea(child: MainScreen()),
    );
  }
}

// Home Screen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      // Home Screen
      Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset("assets/images/mocktail_02.jpg",
              fit: BoxFit.cover,
              color: const Color.fromRGBO(255, 255, 255, .2),
              colorBlendMode: BlendMode.modulate,
            ),
          ),

          // Centered Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Stack Buttons & Form Input App',
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 3.0, color: Colors.black54),
                  ],
                ),
                ),
                const SizedBox(height: 40),
                RoundedButton(
                  text: 'Go to Buttons',
                  colour: Colors.blue,
                  onPressed: _navigateToButtons,// TODO: To be created/coded
                ),
                const SizedBox(height: 40),
                RoundedButton(
                  text: 'Go to Inputs',
                  colour: Colors.orangeAccent,
                  onPressed: _navigateToInputs,// TODO: To be created/coded
                ),
                const SizedBox(height: 40),
                RoundedButton(
                  text: 'Go to Register',
                  colour: Colors.purple,
                  onPressed: _navigateToRegister,// TODO: To be created/coded
                ),
              ],
            ),
          ),
        ],
      ),
      const Center(child: Text('Search Screen'),),
      const Center(child: Text('Favourite Screen'),),
      const Center(child: Text('Profile Screen'),),
    ];
  }

  // Navigation functions
  void _navigateToButtons()
  {
    Navigator.push(context,
    MaterialPageRoute(builder: (context) => const ButtonsScreen(),)
    );
  }

  void _navigateToInputs()
  {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const InputScreen(),)
    );
  }

  void _navigateToRegister()
  {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SignUpPage(),)
    );
  }

  void _onItemTapped(int index)
  {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stack Buttons & Form Inputs App'),),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),

    );
  }
}

