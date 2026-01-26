import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_crop_screen.dart';

// 1. Create a Global Notifier for the theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() => runApp(SmartFarmingApp());

class SmartFarmingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 2. Wrap MaterialApp with ValueListenableBuilder
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Farming',

          // Light Theme Settings
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.grey[50],
            fontFamily: 'Poppins',
          ),

          // Dark Theme Settings
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            fontFamily: 'Poppins',
          ),

          themeMode: currentMode, // Uses the global notifier value

          initialRoute: '/',
          routes: {
            '/': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/dashboard': (context) => DashboardScreen(),
            '/add-crop': (context) => AddCropScreen(),
          },
        );
      },
    );
  }
}
