import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';

class ExportService {
  static Future<void> exportTransactionsCsv(
    List<TransactionModel> transactions, {
    String? filterLabel,
  }) async {
    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Category', 'Amount', 'Note'],
    ];

    final dateFormat = DateFormat('dd MMM yyyy');

    for (final txn in transactions) {
      rows.add([
        dateFormat.format(txn.date),
        txn.type == TransactionType.income ? 'Income' : 'Expense',
        txn.categoryName,
        txn.amount.toStringAsFixed(2),
        txn.note,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/fintrack_export_$timestamp.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'FinTrack Transactions Export',
      text: filterLabel != null
          ? 'FinTrack transactions export ($filterLabel)'
          : 'FinTrack transactions export',
    );
  }
}
