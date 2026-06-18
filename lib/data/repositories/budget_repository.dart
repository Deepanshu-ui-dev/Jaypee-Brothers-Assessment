import '../local/hive_service.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  List<BudgetModel> getAll() {
    return HiveService.budgets.values.toList();
  }

  List<BudgetModel> getForMonth(int year, int month) {
    return HiveService.budgets.values
        .where((b) => b.year == year && b.month == month)
        .toList();
  }

  BudgetModel? getForCategory(String categoryId, int year, int month) {
    final key = BudgetModel.makeId(categoryId, year, month);
    return HiveService.budgets.get(key);
  }

  Future<void> set(BudgetModel budget) async {
    await HiveService.budgets.put(budget.id, budget);
  }

  Future<void> delete(String categoryId, int year, int month) async {
    final key = BudgetModel.makeId(categoryId, year, month);
    await HiveService.budgets.delete(key);
  }
}
