import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/budget_provider.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Consumer<BudgetProvider>(
            builder: (context, budgetProvider, child) {
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                      child: Row(
                        children: [
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title and Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Wallets',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage your accounts',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.softPink),
                                ),
                              ],
                            ),
                          ),
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.warmOrange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.warmOrange.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.warmOrange,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Total Balance Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildTotalBalanceCard(context, budgetProvider),
                    ),
                  ),

                  // Wallets List
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Your Wallets',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final wallet = budgetProvider.wallets[index];
                      return _buildWalletCard(context, wallet, budgetProvider);
                    }, childCount: budgetProvider.wallets.length),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildTotalBalanceCard(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warmOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: AppTheme.warmOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Total Balance',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  '₱${budgetProvider.totalWalletBalance.toStringAsFixed(2)}',
                  key: ValueKey(budgetProvider.totalWalletBalance),
                  style: const TextStyle(
                    color: AppTheme.warmOrange,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    Wallet wallet,
    BudgetProvider budgetProvider,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => _showWalletDetailsDialog(context, wallet, budgetProvider),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.deepPurple.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.softPink.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(wallet.color.replaceFirst('#', '0xFF')),
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getWalletIcon(wallet.icon),
                    color: Color(
                      int.parse(wallet.color.replaceFirst('#', '0xFF')),
                    ),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wallet.type.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.softPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${wallet.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.warmOrange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance',
                      style: const TextStyle(
                        color: AppTheme.softPink,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddWalletDialog(context),
        backgroundColor: AppTheme.warmOrange,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('Add Wallet'),
      ),
    );
  }

  IconData _getWalletIcon(String iconName) {
    switch (iconName) {
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'money':
        return Icons.money;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.account_balance_wallet;
    }
  }

  void _showWalletDetailsDialog(
    BuildContext context,
    Wallet wallet,
    BudgetProvider budgetProvider,
  ) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '${wallet.name} Details',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _getWalletIcon(wallet.icon),
                      color: Color(
                        int.parse(wallet.color.replaceFirst('#', '0xFF')),
                      ),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Current Balance: ₱${wallet.balance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Add/Subtract Amount',
                    labelStyle: TextStyle(color: AppTheme.softPink),
                    hintText:
                        'Enter amount (positive to add, negative to subtract)',
                    hintStyle: TextStyle(color: AppTheme.softPink),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.softPink),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (amount != 0) {
                    budgetProvider.updateWalletBalance(wallet.id, amount);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          amount > 0
                              ? 'Added ₱${amount.toStringAsFixed(2)} to ${wallet.name}'
                              : 'Subtracted ₱${(-amount).toStringAsFixed(2)} from ${wallet.name}',
                        ),
                        backgroundColor: AppTheme.warmOrange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                        backgroundColor: AppTheme.roseRed,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warmOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'gcash';
    String selectedIcon = 'account_balance_wallet';
    String selectedColor = '#00A651';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: AppTheme.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Add New Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Wallet Name',
                            labelStyle: TextStyle(color: AppTheme.softPink),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: balanceController,
                          decoration: const InputDecoration(
                            labelText: 'Initial Balance',
                            labelStyle: TextStyle(color: AppTheme.softPink),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Wallet Type',
                            labelStyle: TextStyle(color: AppTheme.softPink),
                          ),
                          dropdownColor: AppTheme.deepPurple,
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(
                              value: 'gcash',
                              child: Text('GCash'),
                            ),
                            DropdownMenuItem(
                              value: 'seabank',
                              child: Text('SeaBank'),
                            ),
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'bank',
                              child: Text('Bank'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                              if (value == 'gcash') {
                                selectedColor = '#00A651';
                                selectedIcon = 'account_balance_wallet';
                              } else if (value == 'seabank') {
                                selectedColor = '#0066CC';
                                selectedIcon = 'savings';
                              } else if (value == 'cash') {
                                selectedColor = '#FFD700';
                                selectedIcon = 'money';
                              } else if (value == 'bank') {
                                selectedColor = '#E31E24';
                                selectedIcon = 'account_balance';
                              } else {
                                selectedColor = '#9C27B0';
                                selectedIcon = 'account_balance_wallet';
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppTheme.softPink),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text;
                        final balance =
                            double.tryParse(balanceController.text) ?? 0.0;

                        if (name.isNotEmpty) {
                          final wallet = Wallet(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: name,
                            type: selectedType,
                            balance: balance,
                            icon: selectedIcon,
                            color: selectedColor,
                          );

                          Provider.of<BudgetProvider>(
                            context,
                            listen: false,
                          ).addWallet(wallet);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warmOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }
}
