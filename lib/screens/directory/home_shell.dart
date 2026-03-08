import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'directory_screen.dart';
import '../listings/my_listings_screen.dart';
import '../map/map_screen.dart';
import '../settings/settings_screen.dart';
import '../reviews/reviews_screen.dart';

// main shell that holds all 5 tabs and the bottom navigation bar
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  // all 5 screens loaded at once using IndexedStack
  final List<Widget> _screens = const [
    DirectoryScreen(),
    MyListingsScreen(),
    ReviewsScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.navyBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          // 5 tab items with emoji icons
          items: [
            BottomNavigationBarItem(
              icon: const Text('🏠', style: TextStyle(fontSize: 22)),
              activeIcon: const Text('🏠', style: TextStyle(fontSize: 24)),
              label: 'Directory',
            ),
            BottomNavigationBarItem(
              icon: const Text('📋', style: TextStyle(fontSize: 22)),
              activeIcon: const Text('📋', style: TextStyle(fontSize: 24)),
              label: 'My Listings',
            ),
            BottomNavigationBarItem(
              icon: const Text('⭐', style: TextStyle(fontSize: 22)),
              activeIcon: const Text('⭐', style: TextStyle(fontSize: 24)),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: const Text('🗺', style: TextStyle(fontSize: 22)),
              activeIcon: const Text('🗺', style: TextStyle(fontSize: 24)),
              label: 'Map View',
            ),
            BottomNavigationBarItem(
              icon: const Text('⚙️', style: TextStyle(fontSize: 22)),
              activeIcon: const Text('⚙️', style: TextStyle(fontSize: 24)),
              label: 'Settings',
            ),
          ],
          selectedLabelStyle:
              GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        ),
      ),
    );
  }
}
