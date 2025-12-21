import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';
import 'homepage.dart';
import '../../mountains/screens/all_mountains.dart';
import '../../booking/screens/booking_landing.dart';
import '../../news/screen/news_page.dart';
import '../../community/screens/event_list.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomePage(),
      const AllMountainsPage(),
      const BookingLandingPage(),
      const NewsPage(),
      const CommunityEventListPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
