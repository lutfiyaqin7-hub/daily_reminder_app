import 'package:flutter/material.dart';
import 'views/login_page.dart';

void main() {
  runApp(const DailyReminderApp());
}

class DailyReminderApp extends StatelessWidget {
  const DailyReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Task & Activity Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}