import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/views/transactions/add_edit_transaction_view.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({super.key});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  final _searchController = TextEditingController();
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  final List<CategoryModel> _defaultCategories = [
    CategoryModel(id: 1, categoryName: 'Food', icon: 'restaurant'),
    CategoryModel(id: 2, categoryName: 'Transport', icon: 'directions_bus'),
    CategoryModel(id: 3, categoryName: 'Shopping', icon: 'shopping_bag'),
    CategoryModel(id: 4, categoryName: 'Bills', icon: 'receipt_long'),
    CategoryModel(id: 5, categoryName: 'Entertainment', icon: 'movie'),
    CategoryModel(id: 6, categoryName: 'Education', icon: 'school'),
    CategoryModel(id: 7, categoryName: 'Healthcare', icon: 'medical_services'),
    CategoryModel(id: 8, categoryName: 'Travel', icon: 'flight'),
    CategoryModel(id: 9, categoryName: 'Salary', icon: 'payments'),
    CategoryModel(id: 10, categoryName: 'Investment', icon: 'trending_up'),
    CategoryModel(id: 11, categoryName: 'Others', icon: 'more_horiz'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_bus': return Icons.directions_bus;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'receipt_long': return Icons.receipt_long;
      case 'movie': return Icons.movie;
      case 'school': return Icons.school;
      case 'medical_services': return Icons.medical_services;
      case 'flight': return Icons.flight;
      case 'payments': return Icons.payments;
      case 'trending_up': return Icons.trending_up;
      case 'more_horiz': return Icons.more_horiz;
      default: return Icons.category;
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _bulkDelete() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected?'),
        content: Text('Are you sure you want to delete ${_selectedIds.length} transactions?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await txProvider.deleteMultipleTransactions(_selectedIds.toList(), user.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted ${_selectedIds.length} transactions'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _selectedIds.clear();
          _isSelectionMode = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txProvider = Provider.of<TransactionProvider>(context);

    final filteredTransactions = txProvider.getFilteredTransactions(_defaultCategories);

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedIds.length} Selected')
            : const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: _bulkDelete,
            )
        ],
      ),
      body: Column(
        children: [
          // Search 
          if (!_isSelectionMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search title, date, notes...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            txProvider.searchQuery = '';
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (val) {
                  txProvider.searchQuery = val;
                },
              ),
            ),

          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions match your filters!',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      final isExpense = tx.type == 'expense';
                      final isSelected = _selectedIds.contains(tx.id);
                      final category = _defaultCategories.firstWhere(
                        (c) => c.id == tx.categoryId,
                        orElse: () => CategoryModel(id: 11, categoryName: 'Others', icon: 'more_horiz'),
                      );

                      // Left to Right delete 
                      return Dismissible(
                        key: Key('history_tx_${tx.id}'),
                        // Left-to-Right swipe limit specify karta hai
                        direction: DismissDirection.startToEnd, 
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          
                          final success = await txProvider.deleteTransaction(tx.id!, tx.userId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Transaction deleted' : 'Delete failed'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isSelected
                                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                                : BorderSide.none,
                          ),
                          child: InkWell(
                            onLongPress: () {
                              setState(() {
                                _isSelectionMode = true;
                                _toggleSelection(tx.id!);
                              });
                            },
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelection(tx.id!);
                              } else {
                                // tap to edit
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditTransactionView(transaction: tx),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ListTile(
                                leading: _isSelectionMode
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: (val) {
                                          _toggleSelection(tx.id!);
                                        },
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isExpense
                                              ? Colors.redAccent.withOpacity(0.1)
                                              : Colors.greenAccent.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getIconData(category.icon),
                                          color: isExpense ? Colors.redAccent : Colors.green,
                                        ),
                                      ),
                                title: Text(
                                  tx.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  tx.notes.isNotEmpty ? tx.notes : category.categoryName,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Text(
                                  '${isExpense ? '-' : '+'}${txProvider.format(tx.amount)}',
                                  style: TextStyle(
                                    color: isExpense ? Colors.redAccent : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}