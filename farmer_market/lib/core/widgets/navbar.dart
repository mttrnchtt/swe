import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'My products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ],
    );
  }
}
