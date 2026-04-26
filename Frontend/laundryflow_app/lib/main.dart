import 'package:flutter/material.dart';
import 'package:laundryflow_app/screens/main_screen.dart';
import 'services/api_services.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Restore session BEFORE app starts
  await ApiService.restoreSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 AUTO REDIRECT
      home: ApiService.isAuthenticated
    ? const MainScreen()
    : const LoginScreen(),
    );
  }
}