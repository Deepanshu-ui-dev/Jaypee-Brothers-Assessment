import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('transactions');

  /// Real-time stream of all transactions, ordered by date desc
  Stream<List<TransactionModel>> watchAll(String uid) {
    return _col(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());
  }

  /// Add a new transaction
  Future<void> add(String uid, TransactionModel txn) async {
    await _col(uid).add(txn.toFirestore());
  }

  /// Update an existing transaction by id
  Future<void> update(String uid, TransactionModel txn) async {
    await _col(uid).doc(txn.id).update(txn.toFirestore());
  }

  /// Delete a transaction by id
  Future<void> delete(String uid, String transactionId) async {
    await _col(uid).doc(transactionId).delete();
  }

  /// Get transactions for a specific month (for analytics)
  Stream<List<TransactionModel>> watchMonth(
      String uid, int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return _col(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());
  }
}
