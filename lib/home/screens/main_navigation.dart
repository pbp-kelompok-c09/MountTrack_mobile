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
  Key _newsKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomePage(),
          const AllMountainsPage(),
          BookingLandingPage(
            onHome: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          NewsPage(key: _newsKey),
          const CommunityEventListPage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            if (index == 3) {
              // refresh news page
              _newsKey = UniqueKey();
            }
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
