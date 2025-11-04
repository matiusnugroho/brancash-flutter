import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/database_helper.dart';
import 'home_content.dart';
import 'models/transaction_entry.dart';
import 'wallet_page.dart';
import 'widgets/add_transaction_sheet.dart';

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => FinanceHomePageState();
}

class FinanceHomePageState extends State<FinanceHomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  int _selectedIndex = 0;
  bool _isLoading = true;

  List<TransactionEntry> _recentTransactions = const [];
  late List<_DailySummary> _weeklySummaries;
  double _totalIncome = 0;
  double _totalExpense = 0;

  double get _balance => _totalIncome - _totalExpense;

  static final List<Widget> _pages = <Widget>[
    const HomeContent(),
    const WalletPage(),
    const SizedBox.shrink(),
    const Center(
      child: Text('Halaman Insights', style: TextStyle(color: Colors.white, fontSize: 24)),
    ),
    const Center(
      child: Text('Halaman Settings', style: TextStyle(color: Colors.white, fontSize: 24)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    final totals = await _databaseHelper.getTotals();
    final recentTransactions = await _databaseHelper.getRecentTransactions();

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startRange = startOfToday.subtract(const Duration(days: 6));
    final endRange = startOfToday.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    final transactionsInRange =
        await _databaseHelper.getTransactionsBetween(startRange, endRange);

    final summaries = <DateTime, _DailySummary>{};
    for (int i = 0; i < 7; i++) {
      final date = startRange.add(Duration(days: i));
      summaries[date] = _DailySummary(date: date);
    }

    for (final entry in transactionsInRange) {
      final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      final summary = summaries[normalizedDate];
      if (summary == null) continue;
      if (entry.isIncome) {
        summary.income += entry.amount;
      } else {
        summary.expense += entry.amount;
      }
    }

    setState(() {
      _totalIncome = totals[TransactionType.income] ?? 0;
      _totalExpense = totals[TransactionType.expense] ?? 0;
      _recentTransactions = recentTransactions;
      _weeklySummaries = summaries.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      _isLoading = false;
    });
  }

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
          Center(
            child: Text(
              _currencyFormatter.format(_balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total pemasukan ${_currencyFormatter.format(_totalIncome)} · '
            'Total pengeluaran ${_currencyFormatter.format(_totalExpense)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget buildHeaderButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          IconButton(
            onPressed: _showAddTransactionSheet,
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget buildBarChart() {
    if (_isLoading) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final double maxTotal = _weeklySummaries.isEmpty
        ? 0.0
        : _weeklySummaries
            .map((summary) => summary.income + summary.expense)
            .fold<double>(0, (previous, element) => element > previous ? element : previous);
    final double maxY = maxTotal == 0.0 ? 500000.0 : maxTotal * 1.2;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const Text('0', style: TextStyle(color: Colors.white70, fontSize: 12));
                  }
                  final formatted = _currencyFormatter.format(value).replaceAll('Rp ', '');
                  return Text(formatted, style: const TextStyle(color: Colors.white70, fontSize: 12));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= _weeklySummaries.length) {
                    return const SizedBox.shrink();
                  }
                  final date = _weeklySummaries[value.toInt()].date;
                  final text = DateFormat('E', 'id_ID').format(date);
                  return Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            for (int i = 0; i < _weeklySummaries.length; i++)
              _makeGroupData(i, _weeklySummaries[i].income, _weeklySummaries[i].expense)
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double income, double expense) {
    const double width = 16;
    const Color incomeColor = Colors.white;
    const Color expenseColor = Color(0xFFF44336);

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income + expense,
          width: width,
          rodStackItems: [
            BarChartRodStackItem(0, income, incomeColor),
            BarChartRodStackItem(income, income + expense, expenseColor),
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
        buildLegendItem(Colors.white, 'Pemasukan'),
        const SizedBox(width: 20),
        buildLegendItem(const Color(0xFFF44336), 'Pengeluaran'),
      ],
    );
  }

  Widget buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentTransactions.isEmpty
                    ? const Center(child: Text('Belum ada transaksi. Yuk tambah dulu!'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 20.0),
                        itemCount: _recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _recentTransactions[index];
                          return buildActivityItem(transaction);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget buildActivityItem(TransactionEntry transaction) {
    final currencyText = _currencyFormatter.format(transaction.amount);
    final dateText = DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date);

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
                backgroundColor:
                    (transaction.isIncome ? Colors.green : const Color(0xFFF44336)).withOpacity(0.15),
                child: Text(
                  transaction.isIncome ? '⬆️' : '⬇️',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${transaction.category} · $dateText',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Text(
                transaction.isIncome ? currencyText : '- $currencyText',
                style: TextStyle(
                  color: transaction.isIncome ? Colors.green : const Color(0xFFF44336),
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

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex > 1 ? _selectedIndex - 1 : _selectedIndex,
      onTap: (index) {
        if (index == 2) {
          _showAddTransactionSheet();
          return;
        }

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
        BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 36, color: Color(0xFF1976D2)), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  Future<void> _showAddTransactionSheet() async {
    final entry = await showModalBottomSheet<TransactionEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );

    if (entry != null) {
      await _databaseHelper.insertTransaction(entry);
      await _initializeData();
    }
  }
}

class _DailySummary {
  _DailySummary({required this.date, this.income = 0, this.expense = 0});

  final DateTime date;
  double income;
  double expense;
}
