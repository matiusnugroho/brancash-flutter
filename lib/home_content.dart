import 'package:flutter/material.dart';
import 'finance_home_page.dart';

// Widget ini sekarang menjadi publik dan berada di filenya sendiri.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // State masih perlu diakses dari parent-nya (_FinanceHomePageState)
    // karena data dan metode buildernya ada di sana.
    final state = context.findAncestorStateOfType<FinanceHomePageState>();

    // Jika state tidak ditemukan (seharusnya tidak mungkin dalam kasus ini),
    // tampilkan error atau widget placeholder.
    if (state == null) {
      return const Center(
        child: Text('Error: Could not find FinanceHomePage state.'),
      );
    }

    // Menggunakan Stack untuk menumpuk DraggableScrollableSheet di atas header
    return Stack(
      children: [
        // Header akan menjadi latar belakang
        state.buildHeader(),
        // Sheet yang bisa ditarik dari bawah
        DraggableScrollableSheet(
          initialChildSize: 0.45, // Tinggi awal sheet (45% dari layar)
          minChildSize: 0.45,     // Tinggi minimum saat ditarik ke bawah
          maxChildSize: 0.9,      // Tinggi maksimum saat ditarik ke atas
          builder: (BuildContext context, ScrollController scrollController) {
            // buildRecentActivity sekarang menerima scrollController
            // untuk dihubungkan ke ListView di dalamnya.
            return state.buildRecentActivity(scrollController);
          },
        ),
        // Menambahkan SafeArea di atas untuk memastikan tombol header tidak terhalang notch
        SafeArea(child: state.buildHeaderButtons()),
      ],
    );
  }
}