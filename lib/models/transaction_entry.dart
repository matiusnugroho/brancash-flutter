import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionEntry {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;

  const TransactionEntry({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
  });

  bool get isIncome => type == TransactionType.income;

  Color get typeColor => isIncome ? Colors.green : const Color(0xFFF44336);

  TransactionEntry copyWith({
    int? id,
    String? title,
    String? category,
    double? amount,
    TransactionType? type,
    DateTime? date,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionEntry.fromMap(Map<String, dynamic> map) {
    return TransactionEntry(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: (map['type'] as String) == TransactionType.income.name
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
