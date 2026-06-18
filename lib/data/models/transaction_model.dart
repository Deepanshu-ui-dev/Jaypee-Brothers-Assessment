import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late TransactionType type;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  late String categoryName;

  @HiveField(5)
  late DateTime date;

  @HiveField(6)
  late String note;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late bool isRecurring;

  @HiveField(9)
  String? recurringInterval;

  @HiveField(10)
  String? receiptNumber;

  @HiveField(11)
  String? paymentMethod;

  @HiveField(12)
  late List<String> tags;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.date,
    this.note = '',
    required this.createdAt,
    this.isRecurring = false,
    this.recurringInterval,
    this.receiptNumber,
    this.paymentMethod,
    this.tags = const [],
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? categoryName,
    DateTime? date,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
    bool? isRecurring,
    String? recurringInterval,
    String? receiptNumber,
    String? paymentMethod,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      date: date ?? this.date,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'isRecurring': isRecurring,
        'recurringInterval': recurringInterval,
        'receiptNumber': receiptNumber,
        'paymentMethod': paymentMethod,
        'tags': tags,
      };
}

// ── Icon data helper (kept for category lookups) ──────────────────────────────
class IconDataHelper {
  static IconData fromCodePoint(int codePoint, {String fontFamily = 'MaterialIcons'}) {
    return IconData(codePoint, fontFamily: fontFamily);
  }
}
