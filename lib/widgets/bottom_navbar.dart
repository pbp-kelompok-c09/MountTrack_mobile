import 'package:flutter/material.dart';

const kombuGreen = Color(0xFF354024);
const bone = Color(0xFFE5D7C4);

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,  
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {  
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: kombuGreen, 
      selectedItemColor: bone,
      unselectedItemColor: bone.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.terrain), label: 'Mountains'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
      ],
    );
  }
}
