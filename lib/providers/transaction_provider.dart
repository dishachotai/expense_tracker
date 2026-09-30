import 'package:flutter/material.dart';
import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/models/category_model.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<TransactionModel> _transactions = [];

  // Stores the current search query.
  String _searchQuery = '';

  List<TransactionModel> get allTransactions => _transactions;

  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  // Fetches all transactions for the specified user from the database.
  Future<void> fetchTransactions(int userId) async {
    _transactions = await _dbHelper.getTransactions(userId);
    notifyListeners();
  }

  // CRUD operations: Add, Update, and Delete transactions.
  Future<bool> addTransaction(TransactionModel tx) async {
    final id = await _dbHelper.insertTransaction(tx);

    if (id > 0) {
      await fetchTransactions(tx.userId);
      return true;
    }

    return false;
  }

  Future<bool> updateTransaction(TransactionModel tx) async {
    final rows = await _dbHelper.updateTransaction(tx);

    if (rows > 0) {
      await fetchTransactions(tx.userId);
      return true;
    }

    return false;
  }

  Future<bool> deleteTransaction(int id, int userId) async {
    final rows = await _dbHelper.deleteTransaction(id, userId);

    if (rows > 0) {
      await fetchTransactions(userId);
      return true;
    }

    return false;
  }

  Future<bool> deleteMultipleTransactions(
      List<int> ids, int userId) async {
    final rows = await _dbHelper.deleteMultipleTransactions(ids, userId);

    if (rows > 0) {
      await fetchTransactions(userId);
      return true;
    }

    return false;
  }

  // Filters transactions based only on the search query.
  // No date, amount, or transaction type filters are applied.
  List<TransactionModel> getFilteredTransactions(
      List<CategoryModel> categories) {
    List<TransactionModel> list = List.from(_transactions);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      list = list.where((tx) {
        final cat = categories.firstWhere(
          (c) => c.id == tx.categoryId,
          orElse: () => CategoryModel(
            categoryName: 'Unknown',
            icon: '',
          ),
        );

        return tx.title.toLowerCase().contains(query) ||
            tx.notes.toLowerCase().contains(query) ||
            tx.paymentMethod.toLowerCase().contains(query) ||
            cat.categoryName.toLowerCase().contains(query) ||
            tx.amount.toString().contains(query) ||
            tx.date.contains(query);
      }).toList();
    }

    return list;
  }

  // Calculates the total income from all transactions.
  double getTotalIncome() {
    return _transactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Calculates the total expenses from all transactions.
  double getTotalExpenses() {
    return _transactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Calculates the current balance by subtracting expenses from income.
  double getBalance() {
    return getTotalIncome() - getTotalExpenses();
  }

  // Calculates monthly savings for the specified year and month.
  double getMonthlySavings(int year, int month) {
    final income = _transactions
        .where(
          (tx) =>
              tx.type == 'income' &&
              _isTxInMonth(tx, year, month),
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final expense = _transactions
        .where(
          (tx) =>
              tx.type == 'expense' &&
              _isTxInMonth(tx, year, month),
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);

    return income - expense;
  }

  // Checks whether a transaction belongs to the specified year and month.
  bool _isTxInMonth(TransactionModel tx, int year, int month) {
    final parsed = DateTime.tryParse(tx.date);

    if (parsed == null) return false;

    return parsed.year == year && parsed.month == month;
  }

  // Formats the amount as Indian Rupees with two decimal places.
  String format(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}