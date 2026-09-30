class BudgetModel {
  final int? id;
  final int userId;
  final int? categoryId; // null represents overall monthly budget
  final double amount;
  final String startDate; 
  final String endDate; 

  BudgetModel({
    this.id,
    required this.userId,
    this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      categoryId: map['category_id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
    );
  }
}
