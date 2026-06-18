import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id; // "$categoryId-$year-$month"

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late String categoryName;

  @HiveField(3)
  late double limitAmount;

  @HiveField(4)
  late int month; // 1–12

  @HiveField(5)
  late int year;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  static String makeId(String categoryId, int year, int month) =>
      '$categoryId-$year-$month';

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    double? limitAmount,
    int? month,
    int? year,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
