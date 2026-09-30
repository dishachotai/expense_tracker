import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';

class AddEditTransactionView extends StatefulWidget {
  final TransactionModel? transaction;
  final String? initialType; // 'income' or 'expense'

  const AddEditTransactionView({super.key, this.transaction, this.initialType});

  @override
  State<AddEditTransactionView> createState() => _AddEditTransactionViewState();
}

class _AddEditTransactionViewState extends State<AddEditTransactionView> {
  final _formKey = GlobalKey<FormState>();
  
  late String _type; //expense or income
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  int? _selectedCategoryId;
  late DateTime _selectedDate;
  late String _paymentMethod;
  
  bool _isLoading = false;

  final List<String> _paymentMethods = ['Cash', 'Card', 'UPI', 'NetBanking', 'Others'];

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
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _type = tx.type;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toString();
      _notesController.text = tx.notes;
      _selectedCategoryId = tx.categoryId;
      _selectedDate = DateTime.tryParse(tx.date) ?? DateTime.now();
      _paymentMethod = tx.paymentMethod;
    } else {
      _type = widget.initialType ?? 'expense';
      _selectedDate = DateTime.now();
      _paymentMethod = 'Cash';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    final amt = double.tryParse(_amountController.text) ?? 0.0;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final tx = TransactionModel(
      id: widget.transaction?.id,
      userId: user.id!,
      title: _titleController.text.trim(),
      amount: amt,
      type: _type,
      categoryId: _selectedCategoryId!,
      date: dateStr,
      notes: _notesController.text.trim(),
      paymentMethod: _paymentMethod,
    );

    bool success;
    if (widget.transaction == null) {
      success = await txProvider.addTransaction(tx);
    } else {
      success = await txProvider.updateTransaction(tx);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, tx);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.transaction == null
              ? 'Transaction added successfully!'
              : 'Transaction updated successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save transaction. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? (_type == 'income' ? 'Add Your Income' : 'Add Your Expense')
              : (_type == 'income' ? 'Edit Your Income' : 'Edit Your Expense'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Transaction Title',
                  hintText: 'e.g. Groceries, Rent, Salary',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  hintText: '0.00',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        '₹',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amt = double.tryParse(value);
                  if (amt == null || amt <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
               
                items: _defaultCategories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Row(
                      children: [
                        Icon(_getIconData(cat.icon), size: 20),
                        const SizedBox(width: 12),
                        Text(cat.categoryName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategoryId = val;
                      // Category ID 9 (Salary) and 10 (Investment) are Income others are Expense
                      if (val == 9 || val == 10) {
                        _type = 'income';
                      } else {
                        _type = 'expense';
                      }
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date Picker Card
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(DateFormat('dd-MMM-yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_drop_down_rounded, size: 30),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon: const Icon(Icons.payment_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _paymentMethod = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add specific details here...',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(widget.transaction == null ? 'ADD RECORD' : 'SAVE CHANGES',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
