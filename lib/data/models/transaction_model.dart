import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String categoryName;
  final DateTime date;
  final String note;
  final List<String> tags;
  final DateTime createdAt;
  final bool isRecurring;
  final String? recurringInterval; // 'daily' | 'weekly' | 'monthly'
  final String? receiptNumber;
  final String? paymentMethod;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.date,
    this.note = '',
    this.tags = const [],
    required this.createdAt,
    this.isRecurring = false,
    this.recurringInterval,
    this.receiptNumber,
    this.paymentMethod,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? 'Other',
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String? ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringInterval: data['recurringInterval'] as String?,
      receiptNumber: data['receiptNumber'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'date': Timestamp.fromDate(date),
      'note': note,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRecurring': isRecurring,
      'recurringInterval': recurringInterval,
      'receiptNumber': receiptNumber,
      'paymentMethod': paymentMethod,
    };
  }

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
}
