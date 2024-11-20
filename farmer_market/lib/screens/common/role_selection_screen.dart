import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please choose your role',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.agriculture, size: 40, color: Colors.green),
              title: Text('I’m a Farmer'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, size: 40, color: Colors.green),
              title: Text('I’m a Buyer'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
