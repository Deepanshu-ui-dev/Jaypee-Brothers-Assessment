import 'package:uuid/uuid.dart';
import '../local/hive_service.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  static const _uuid = Uuid();

  List<TransactionModel> getAll() {
    final box = HiveService.transactions;
    return box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(TransactionModel txn) async {
    final id = txn.id.isEmpty ? _uuid.v4() : txn.id;
    final toSave = txn.copyWith(id: id);
    await HiveService.transactions.put(id, toSave);
  }

  Future<void> update(TransactionModel txn) async {
    await HiveService.transactions.put(txn.id, txn);
  }

  Future<void> delete(String id) async {
    await HiveService.transactions.delete(id);
  }

  TransactionModel? getById(String id) {
    return HiveService.transactions.get(id);
  }

  List<TransactionModel> getByMonth(int year, int month) {
    return getAll().where((t) =>
        t.date.year == year && t.date.month == month).toList();
  }
}
