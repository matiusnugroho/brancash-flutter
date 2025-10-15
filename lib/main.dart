import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'finance_home_page.dart';

void main() {
  // Memastikan Flutter binding sudah siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  // Mengatur orientasi aplikasi hanya potrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BranCash',
      theme: ThemeData(
        // Mengatur warna utama aplikasi
        primarySwatch: Colors.blue,
        // Mengatur warna latar belakang scaffold utama agar sesuai dengan header
        scaffoldBackgroundColor: const Color(0xFF1976D2),
        // Menggunakan font Poppins sebagai tema teks default
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const FinanceHomePage(),
    );
  }
}