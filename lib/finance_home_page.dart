import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'wallet_page.dart';
import 'home_content.dart';

// Model sederhana untuk data aktivitas
class Activity {
  final String icon;
  final String title;
  final String category;
  final double amount;
  final Color color;
  final bool isIncome;

  Activity({
    required this.icon,
    required this.title,
    required this.category,
    required this.amount,
    required this.color,
    this.isIncome = false,
  });
}

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => FinanceHomePageState();
}

class FinanceHomePageState extends State<FinanceHomePage> {
  int _selectedIndex = 0;

  // Data dummy untuk daftar aktivitas
  final List<Activity> _activities = [
    Activity(icon: '🐔', title: 'Ayam Geprek', category: 'Makan', amount: 75000, color: const Color(0xFFD27A62)),
    Activity(icon: '⛽', title: 'Bensin', category: 'Transportasi', amount: 41000, color: const Color(0xFFE55A5A)),
    Activity(icon: '💸', title: 'Samsul Bayar', category: 'Hutang', amount: 223000, color: const Color(0xFFFFC107)),
    Activity(icon: '💰', title: 'Gaji Bulan', category: 'Pendapatan', amount: 229000, color: const Color(0xFFFFD54F), isIncome: true),
    Activity(icon: '☕', title: 'Kopi Kenangan', category: 'Makan', amount: 22000, color: const Color(0xFFD27A62)),
  ];

  // Daftar widget untuk setiap halaman/tab
  static final List<Widget> _pages = <Widget>[
    const HomeContent(), // Menggunakan widget dari file baru
    const WalletPage(),   // Halaman Wallet yang baru dibuat
    const Center(child: Text('Halaman Tambah', style: TextStyle(color: Colors.white, fontSize: 24))), // Placeholder
    const Center(child: Text('Halaman Insights', style: TextStyle(color: Colors.white, fontSize: 24))), // Placeholder
    const Center(child: Text('Halaman Settings', style: TextStyle(color: Colors.white, fontSize: 24))), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      color: const Color(0xFF1976D2),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Balance',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
            ),
          ),
          const SizedBox(height: 5),
          const Center(
            child: Text(
              'Rp 365,500',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          buildBarChart(),
          const SizedBox(height: 20),
          buildChartLegend(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  
  // Widget baru untuk tombol header agar bisa ditumpuk di atas
  Widget buildHeaderButtons() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Icon(Icons.arrow_back, color: Colors.white, size: 28), Icon(Icons.add, color: Colors.white, size: 28)],
      ),
    );
  }

  // Widget untuk membangun grafik batang menggunakan fl_chart
  Widget buildBarChart() {
    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          maxY: 6, // PERUBAHAN: Menyesuaikan nilai Y maksimal
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 2, // Menampilkan label setiap interval 2
                getTitlesWidget: (value, meta) {
                  // PERUBAHAN: Membuat label Y lebih linear
                  if (value == 0) return const Text('\$0', style: TextStyle(color: Colors.white70, fontSize: 12));
                  if (value == 2) return const Text('\$20', style: TextStyle(color: Colors.white70, fontSize: 12));
                  if (value == 4) return const Text('\$40', style: TextStyle(color: Colors.white70, fontSize: 12));
                  if (value == 6) return const Text('\$60', style: TextStyle(color: Colors.white70, fontSize: 12));
                  return Container();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Mar'; break;
                    case 1: text = 'Apr'; break;
                    case 2: text = 'May'; break;
                    case 3: text = 'Jui'; break;
                    case 4: text = 'Aug'; break;
                    default: return Container();
                  }
                  return Text(text, style: style);
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          // Data untuk setiap batang
          barGroups: [
            makeGroupData(0, 2, 0),    // Mar: Earned 2, Spent 0
            makeGroupData(1, 3, 0),    // Apr: Earned 3, Spent 0
            makeGroupData(2, 2, 1),    // May: Earned 2, Spent 1
            makeGroupData(3, 2.5, 0),  // Jui: Earned 2.5, Spent 0
            makeGroupData(4, 1, 3.5),  // Aug: Earned 1, Spent 3.5
          ],
        ),
      ),
    );
  }

  // PERUBAHAN UTAMA DI FUNGSI INI
  // Fungsi helper untuk membuat data grup batang bertumpuk (stacked)
  BarChartGroupData makeGroupData(int x, double earned, double spent) {
    const double width = 16;
    const Color earnedColor = Colors.white;
    const Color spentColor = Color(0xFFF44336);

    return BarChartGroupData(
      x: x,
      barRods: [
        // Hanya menggunakan SATU BarChartRodData
        BarChartRodData(
          toY: earned + spent, // Tinggi total adalah penjumlahan earned dan spent
          width: width,
          // Gunakan rodStackItems untuk menumpuk data
          rodStackItems: [
            // Bagian bawah untuk 'Earned'
            BarChartRodStackItem(0, earned, earnedColor),
            // Bagian atas untuk 'Spent', dimulai dari akhir 'Earned'
            BarChartRodStackItem(earned, earned + spent, spentColor),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ],
    );
  }

  Widget buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildLegendItem(Colors.white, 'Earned'),
        const SizedBox(width: 20),
        buildLegendItem(const Color(0xFFF44336), 'Spent'),
      ],
    );
  }

  Widget buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget buildRecentActivity(ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 20.0),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return buildActivityItem(activity);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActivityItem(Activity activity) {
    final currencyFormatter = NumberFormat.decimalPattern('id_ID');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: activity.color.withOpacity(0.2),
                child: Text(activity.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(activity.category, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              Text(
                '${activity.isIncome ? '' : '- '}${currencyFormatter.format(activity.amount)}',
                style: TextStyle(
                  color: activity.isIncome ? Colors.green : const Color(0xFFF44336),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex > 1 ? _selectedIndex -1 : _selectedIndex,
      onTap: (index) {
        // Jika tombol tengah (index 2) ditekan, jangan lakukan apa-apa (atau panggil aksi tambah)
        if (index == 2) {
          // TODO: Tambahkan aksi untuk tombol tambah, misalnya menampilkan dialog.
          print('Tombol Tambah ditekan!');
          return;
        }

        // Sesuaikan index untuk state karena item 'Tambah' tidak dihitung sebagai halaman
        final newIndex = index > 1 ? index + 1 : index;
        setState(() => _selectedIndex = newIndex);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1976D2),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
        // Tombol Tambah di tengah yang tidak akan mengubah halaman
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 36, color: Color(0xFF1976D2)),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}