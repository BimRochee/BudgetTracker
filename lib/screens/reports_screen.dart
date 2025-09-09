import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/budget_provider.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<BudgetProvider>(
              builder: (context, budgetProvider, child) {
                return CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reports',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track your spending patterns',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.softPink),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.warmOrange.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.warmOrange.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Spending Overview Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSpendingOverviewCard(
                          context,
                          budgetProvider,
                        ),
                      ),
                    ),

                    // Category Breakdown
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildCategoryBreakdownCard(
                          context,
                          budgetProvider,
                        ),
                      ),
                    ),

                    // Monthly Trends
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildMonthlyTrendsCard(context, budgetProvider),
                      ),
                    ),

                    // Income vs Expenses Chart
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildIncomeVsExpensesCard(
                          context,
                          budgetProvider,
                        ),
                      ),
                    ),

                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingOverviewCard(
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
                      Icons.trending_up,
                      color: AppTheme.warmOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Spending Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildOverviewRow(
                'Total Spent This Month',
                budgetProvider.totalExpenses,
                AppTheme.roseRed,
                Icons.trending_down,
              ),
              const SizedBox(height: 16),
              _buildOverviewRow(
                'Average Daily Spending',
                budgetProvider.totalExpenses / 30, // Assuming 30 days
                AppTheme.warmOrange,
                Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildOverviewRow(
                'Largest Expense',
                _getLargestExpense(budgetProvider),
                AppTheme.softPink,
                Icons.receipt_long,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final categoryTotals = _getCategoryTotals(budgetProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.deepPurple, AppTheme.wineRed],
          ),
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
                      color: AppTheme.softPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.pie_chart,
                      color: AppTheme.softPink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Category Breakdown',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (categoryTotals.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 64,
                        color: AppTheme.softPink.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses to categorize',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.softPink),
                      ),
                    ],
                  ),
                )
              else
                ...categoryTotals.entries.map((entry) {
                  final percentage =
                      (entry.value / budgetProvider.totalExpenses) * 100;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCategoryRow(
                      entry.key,
                      entry.value,
                      percentage,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendsCard(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.wineRed, AppTheme.roseRed],
          ),
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
                      Icons.timeline,
                      color: AppTheme.warmOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Monthly Trends',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 64,
                      color: AppTheme.softPink.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Monthly trends coming soon',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.softPink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your spending patterns over time',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.softPink.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeVsExpensesCard(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.roseRed, AppTheme.warmOrange],
          ),
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
                      color: AppTheme.softPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.compare_arrows,
                      color: AppTheme.softPink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Income vs Expenses',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildComparisonRow(
                'Total Income',
                budgetProvider.totalIncome,
                Colors.green,
                Icons.trending_up,
              ),
              const SizedBox(height: 16),
              _buildComparisonRow(
                'Total Expenses',
                budgetProvider.totalExpenses,
                AppTheme.roseRed,
                Icons.trending_down,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      budgetProvider.netIncome >= 0
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppTheme.roseRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        budgetProvider.netIncome >= 0
                            ? Colors.green.withValues(alpha: 0.3)
                            : AppTheme.roseRed.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: _buildComparisonRow(
                  'Net Income',
                  budgetProvider.netIncome,
                  budgetProvider.netIncome >= 0
                      ? Colors.green
                      : AppTheme.roseRed,
                  budgetProvider.netIncome >= 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewRow(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.softPink,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 1,
          child: Text(
            '₱${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String category, double amount, double percentage) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.softPink.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warmOrange),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppTheme.softPink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.softPink,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 1,
          child: Text(
            '₱${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  double _getLargestExpense(BudgetProvider budgetProvider) {
    if (budgetProvider.expenses.isEmpty) return 0.0;
    return budgetProvider.expenses
        .map((expense) => expense['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  Map<String, double> _getCategoryTotals(BudgetProvider budgetProvider) {
    final Map<String, double> categoryTotals = {};
    for (var expense in budgetProvider.expenses) {
      final category = expense['category'] as String;
      final amount = expense['amount'] as double;
      categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
    }
    return categoryTotals;
  }
}
