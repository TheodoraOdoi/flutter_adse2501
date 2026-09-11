// --------------------------------------------------------------------------
// Authenticated landing/home Screen
// --------------------------------------------------------------------------
// This is the landing page of an authenticated or signed-in user/student.It
// hosts a bottom navigation bar with one table per main feature area. Each tab
// owns its own AppBar, so this screen does not render one of its own.

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'assignments/assignment_list_screen.dart';
import 'course_list_screen.dart';
import 'profile_screen.dart';
import 'study_sessions/study_session_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.session,
  });

  final Session? session;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ---------------------------------------------------------------------------
  // Tabs
  //
  // Wrapped in IndexedStack (rather than swapping widgets in and out) so
  // that each tab keeps its scroll position and loaded data when the user
  // switches away and back.
  // ---------------------------------------------------------------------------

  static const _tabs = [
    _HomeTab(
      screen: CourseListScreen(),
      label: 'Courses',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
    ),
    _HomeTab(
      screen: AssignmentListScreen(),
      label: 'Assignments',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
    ),
    _HomeTab(
      screen: StudySessionListScreen(),
      label: 'Study Sessions',
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
    ),
    _HomeTab(
      screen: ProfileScreen(),
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final tab in _tabs) tab.screen,
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// A single bottom navigation tab: the screen it hosts plus its icon/label.
// ---------------------------------------------------------------------------

class _HomeTab {
  const _HomeTab({
    required this.screen,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final Widget screen;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}