import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/views/transactions/transaction_list_view.dart';
import 'package:expense_tracker/views/transactions/add_edit_transaction_view.dart';
import 'package:expense_tracker/views/profile/profile_view.dart';
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}
class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<TransactionProvider>(context, listen: false).fetchTransactions(user.id!);
      }
      _isInit = false;
    }
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Unauthorized')));
    }

    final List<Widget> children = [
      DashboardHome(onViewAllTransactions: () => _changeTab(1)),
      const TransactionListView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: children,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditTransactionView(),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class DashboardHome extends StatelessWidget {
  final VoidCallback onViewAllTransactions;

  const DashboardHome({super.key, required this.onViewAllTransactions});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final txProvider = Provider.of<TransactionProvider>(context);

    // Calc totals
    final double income = txProvider.getTotalIncome();
    final double expenses = txProvider.getTotalExpenses();
    final double balance = txProvider.getBalance();

    final recentTransactions = txProvider.allTransactions.take(5).toList();

    // Static default categories list for lookup
    final List<CategoryModel> categories = [
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

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        user.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.account_circle,
                    size: 40,
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Total Balance Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withRed(100).withBlue(220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      txProvider.format(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Income
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.greenAccent,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  txProvider.format(income),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Expenses
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expenses',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  txProvider.format(expenses),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAllTransactions,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (recentTransactions.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions recorded yet!',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap the + button below to add your first entry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onBackground.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = recentTransactions[index];
                    final isExpense = tx.type == 'expense';
                    
                    final category = categories.firstWhere(
                      (c) => c.id == tx.categoryId,
                      orElse: () => CategoryModel(id: 11, categoryName: 'Others', icon: 'more_horiz'),
                    );

                    //Left-to-Right swipe delete 
                    return Dismissible(
                      key: Key('dashboard_tx_${tx.id}'),
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
                        ),
                        child: ListTile(
                          leading: Container(
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
                          onTap: () {
                            // tap to edit
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTransactionView(transaction: tx),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80), // buffer space
            ],
          ),
        ),
      ),
    );
  }
}
