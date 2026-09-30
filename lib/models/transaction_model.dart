class TransactionModel {
  final int? id;
  final int userId;
  final String title;
  final double amount;
  final String type; // income or expense
  final int categoryId;
  final String date; 
  final String notes;
  final String paymentMethod;

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.notes = '',
    this.paymentMethod = 'Cash',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date,
      'notes': notes,
      'payment_method': paymentMethod,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category_id'] as int,
      date: map['date'] as String,
      notes: map['notes'] as String? ?? '',
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
    );
  }
}
