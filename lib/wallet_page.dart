import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Widget ini akan menjadi isi dari body Scaffold utama,
    // jadi kita tidak perlu Scaffold lagi di sini.
    return const Center(
      child: Text(
        'Halaman Wallet',
        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}