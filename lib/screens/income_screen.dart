import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/budget_provider.dart';
import '../models/income.dart';
import '../theme/app_theme.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadIncome();
    });
  }

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
                                  'Income',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track your earnings',
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
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Income Summary Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppTheme.cardGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Income',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.softPink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '₱${budgetProvider.totalIncome.toStringAsFixed(2)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Net Income',
                                    '₱${budgetProvider.netIncome.toStringAsFixed(2)}',
                                    budgetProvider.netIncome >= 0
                                        ? AppTheme.warmOrange
                                        : AppTheme.roseRed,
                                    Icons.account_balance_wallet,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'This Month',
                                    '₱${_getMonthlyIncome(budgetProvider).toStringAsFixed(2)}',
                                    AppTheme.warmOrange,
                                    Icons.calendar_month,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Filter Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', _selectedFilter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Salary', _selectedFilter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Freelance', _selectedFilter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Other', _selectedFilter),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Income List
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final filteredIncome = _getFilteredIncome(budgetProvider);
                      if (index >= filteredIncome.length) return null;

                      final income = filteredIncome[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: _buildIncomeCard(income, budgetProvider),
                      );
                    }, childCount: _getFilteredIncome(budgetProvider).length),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(context),
        backgroundColor: AppTheme.warmOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.softPink,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedFilter) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.warmOrange
                  : AppTheme.softPink.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.warmOrange
                    : AppTheme.softPink.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.softPink,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeCard(Income income, BudgetProvider budgetProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warmOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(income.typeIcon),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.source,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  income.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.softPink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        income.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.warmOrange,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: AppTheme.softPink.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        income.formattedDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.softPink.withValues(alpha: 0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                income.formattedAmount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.warmOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                income.type.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.softPink.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'business_center':
        return Icons.business_center;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }

  List<Income> _getFilteredIncome(BudgetProvider budgetProvider) {
    List<Income> filtered = budgetProvider.income;

    if (_selectedFilter != 'All') {
      filtered =
          filtered
              .where((income) => income.type == _selectedFilter.toLowerCase())
              .toList();
    }

    return filtered;
  }

  double _getMonthlyIncome(BudgetProvider budgetProvider) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return budgetProvider.income
        .where(
          (income) =>
              income.date.isAfter(
                startOfMonth.subtract(const Duration(days: 1)),
              ) &&
              income.date.isBefore(endOfMonth.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, income) => sum + income.amount);
  }

  void _showAddIncomeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final sourceController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = Income.getIncomeCategories().first;
    String selectedType = Income.getIncomeTypes().first;
    String selectedWallet = 'cash';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Income',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Source
                        TextFormField(
                          controller: sourceController,
                          decoration: InputDecoration(
                            labelText: 'Source',
                            hintText: 'e.g., Company Name, Client',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter income source';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Amount
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '₱',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items:
                              Income.getIncomeCategories()
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Type
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          items:
                              Income.getIncomeTypes()
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Type'),
                        ),
                        const SizedBox(height: 16),

                        // Wallet
                        DropdownButtonFormField<String>(
                          value: selectedWallet,
                          items:
                              context
                                  .read<BudgetProvider>()
                                  .wallets
                                  .map(
                                    (wallet) => DropdownMenuItem(
                                      value: wallet.id,
                                      child: Text(wallet.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedWallet = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Wallet',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Date Picker
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.softPink.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: AppTheme.softPink.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await context.read<BudgetProvider>().addIncome(
                        source: sourceController.text,
                        amount: double.parse(amountController.text),
                        category: selectedCategory,
                        walletId: selectedWallet,
                        description: descriptionController.text,
                        type: selectedType,
                        date: selectedDate,
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warmOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Income'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
