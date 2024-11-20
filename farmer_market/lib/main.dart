import 'package:flutter/material.dart';
import 'routes/routes.dart';

void main() {
  runApp(FarmerMarketApp());
}

class FarmerMarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Market System',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Ensure this points to the Role Selection Screen
      routes: appRoutes,
    );
  }
}
