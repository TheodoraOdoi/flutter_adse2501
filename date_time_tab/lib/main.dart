// The application's home page

// Imports
import 'package:flutter/material.dart';

import 'screens/date_input.dart';
import 'screens/time_input.dart';
import 'screens/splashscreen.dart';
import 'screens/reservation_details.dart';

// Application's entry point (main function)
void main()
{
  runApp(const DateTimeApp());
}

class DateTimeApp extends StatelessWidget {
  const DateTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Date Time Tabs App",
      debugShowCheckedModeBanner: false,

      // Start with the splash screen
      initialRoute: '/splash',

      // The screens/routes in our app
      routes:
      {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const MyHomePage(),
        '/date': (context) => const DateInputScreen(),
        '/time': (context) => const TimeInputScreen(),
        '/details': (context) => const ReservationDetailsScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentIndex = 0;
  int _guestCount = 1; // Start at 1 guest

  /// Increment the number of guests if it is less than 20.
  ///
  /// This method is used to increase the number of guests in the
  /// [MyHomePage] widget. It will only increment the number of
  /// guests if it is currently less than 20. If the number of guests
  /// is 20 or more, this method does nothing.
  ///
  /// This method is used in the [MyHomePage] widget to increase the
  /// number of guests when the user taps the '+' button in the
  /// [MyHomePage] widget.
  void _incrementGuests() {
    if (_guestCount < 20) {
      setState(() => _guestCount++);
    }
  }

  void _decrementGuests() {
    if (_guestCount > 1) {
      setState(() => _guestCount--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Date Time Tabs Demo App"),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text("Menu",
                style: TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded, color: Colors.deepPurple,),
              title: const Text("Date Input"),
              onTap: ()
              {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/date',arguments: {'guests': _guestCount});
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_rounded, color: Colors.deepPurple,),
              title: const Text("Time Input"),
              onTap: ()
              {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/time', arguments: {'guests': _guestCount});
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home screen(index 0 when drawer is not yet used)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Use the drawer (≡) to choose your booking date and time.',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                // Operating hours information
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.deepPurple, size: 24),
                            SizedBox(width: 8),
                            Text("Operating Hours",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text("• Monday - Friday: 8:00 AM - 22:00 PM",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        const Text("• Saturday: 9:00 AM - 23:00 PM",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        const Text("Sunday: Closed. ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Select number of guests/ Guest selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: _decrementGuests,
                      icon: const Icon(Icons.remove_circle_rounded, color: Colors.deepPurple),),
                    Text("$_guestCount Guests",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    IconButton(onPressed: _incrementGuests,
                      icon: const Icon(Icons.add_circle_rounded, color: Colors.deepPurple),),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

