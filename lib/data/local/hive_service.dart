import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';

class HiveService {
  static const String _transactionsBox = 'transactions';
  static const String _categoriesBox = 'categories';
  static const String _budgetsBox = 'budgets';
  static const String _settingsBox = 'settings';

  static Box<TransactionModel> get transactions =>
      Hive.box<TransactionModel>(_transactionsBox);
  static Box<CategoryModel> get categories =>
      Hive.box<CategoryModel>(_categoriesBox);
  static Box<BudgetModel> get budgets =>
      Hive.box<BudgetModel>(_budgetsBox);
  static Box get settings => Hive.box(_settingsBox);

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (order matters — typeIds must not conflict)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }

    // Open boxes
    await Future.wait([
      Hive.openBox<TransactionModel>(_transactionsBox),
      Hive.openBox<CategoryModel>(_categoriesBox),
      Hive.openBox<BudgetModel>(_budgetsBox),
      Hive.openBox(_settingsBox),
    ]);
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
