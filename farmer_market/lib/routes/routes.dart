import 'package:flutter/material.dart';
import '../screens/common/role_selection_screen.dart';
import '../screens/common/login_screen.dart';
import '../screens/common/register_screen.dart';
import '../screens/farmer/dashboard_screen.dart';
import '../screens/buyer/dashboard_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => RoleSelectionScreen(),
  '/login': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/farmer/dashboard': (context) => FarmerDashboardScreen(),
  '/buyer/dashboard': (context) => BuyerDashboardScreen(), // New route
};
