import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final String role; // Added to pass the role dynamically

  const CustomNavbar({
    required this.selectedIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor:
          const Color.fromARGB(255, 64, 175, 68), // Green when selected
      unselectedItemColor:
          const Color.fromARGB(255, 84, 84, 84), // Dark grey when not selected
      type: BottomNavigationBarType.fixed, // Ensures all items are shown
      items: [
        // Home
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        // Messages
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        // Cart for Buyers, Orders for Farmers
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Orders',
        ),
        // Settings
        BottomNavigationBarItem(
          icon: Icon(role == 'Farmer' ? Icons.analytics : Icons.shopping_cart),
          label: role == 'Farmer' ? 'Analytics' : 'Cart',
        ),
        // My Profile
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
