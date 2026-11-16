import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahan untuk Firebase
import 'views/login_page.dart';

void main() async {
  // Wajib dipanggil agar engine Flutter siap sebelum memanggil plugin async
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menghubungkan aplikasi dengan konfigurasi Firebase (aman dengan try-catch untuk web/lokal)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error (diabaikan untuk web lokal): $e");
  }

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