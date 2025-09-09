import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/budget_provider.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).loadGoals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                                  'Savings Goals',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track your financial goals',
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
                              Icons.flag,
                              color: AppTheme.warmOrange,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Bar
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.deepPurple.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.warmOrange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.softPink,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        tabs: [
                          Tab(
                            child: Text(
                              'Active (${budgetProvider.ongoingGoals.length})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Completed (${budgetProvider.completedGoals.length})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Content
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGoalsList(
                          budgetProvider.ongoingGoals,
                          budgetProvider,
                          false,
                        ),
                        _buildGoalsList(
                          budgetProvider.completedGoals,
                          budgetProvider,
                          true,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildGoalsList(
    List<Goal> goals,
    BudgetProvider budgetProvider,
    bool isCompleted,
  ) {
    if (goals.isEmpty) {
      return _buildEmptyState(isCompleted);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GoalCard(
            goal: goal,
            onContribute:
                () => _showContributeDialog(context, goal, budgetProvider),
            onDelete: () => _showDeleteDialog(context, goal, budgetProvider),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isCompleted) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.deepPurple.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.celebration : Icons.flag,
                size: 64,
                color: AppTheme.softPink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isCompleted ? 'No completed goals yet' : 'No active goals yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted
                  ? 'Complete some goals to see them here!'
                  : 'Create your first savings goal to get started!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.softPink),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalDialog(context),
        backgroundColor: AppTheme.warmOrange,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final durationController = TextEditingController();
    String selectedDurationType = 'days';

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: AppTheme.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Create New Goal',
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
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Goal Title',
                            labelStyle: TextStyle(color: AppTheme.softPink),
                            hintText: 'e.g., Buy Laptop',
                            hintStyle: TextStyle(color: AppTheme.softPink),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Target Amount (₱)',
                            labelStyle: TextStyle(color: AppTheme.softPink),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: durationController,
                                decoration: const InputDecoration(
                                  labelText: 'Duration',
                                  labelStyle: TextStyle(
                                    color: AppTheme.softPink,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: selectedDurationType,
                              dropdownColor: AppTheme.deepPurple,
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(
                                  value: 'days',
                                  child: Text('Days'),
                                ),
                                DropdownMenuItem(
                                  value: 'months',
                                  child: Text('Months'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedDurationType = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.wineRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.wineRed.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.softPink,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Daily saving required will be calculated automatically',
                                  style: TextStyle(
                                    color: AppTheme.softPink,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppTheme.softPink),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text;
                        final amount =
                            double.tryParse(amountController.text) ?? 0.0;
                        final duration =
                            int.tryParse(durationController.text) ?? 0;

                        if (title.isNotEmpty && amount > 0 && duration > 0) {
                          final durationDays =
                              selectedDurationType == 'months'
                                  ? duration * 30
                                  : duration;

                          await Provider.of<BudgetProvider>(
                            context,
                            listen: false,
                          ).createGoal(
                            title: title,
                            targetAmount: amount,
                            durationDays: durationDays,
                          );

                          if (mounted && dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Goal "$title" created successfully!',
                                ),
                                backgroundColor: AppTheme.warmOrange,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill in all fields with valid values',
                              ),
                              backgroundColor: AppTheme.roseRed,
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
                      child: const Text('Create'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showContributeDialog(
    BuildContext context,
    Goal goal,
    BudgetProvider budgetProvider,
  ) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppTheme.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Contribute to "${goal.title}"',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current: ₱${goal.currentAmount.toStringAsFixed(2)} / ₱${goal.targetAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount to contribute (₱)',
                    labelStyle: TextStyle(color: AppTheme.softPink),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.softPink),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (amount > 0) {
                    await budgetProvider.addContributionToGoal(
                      goal.id!,
                      amount,
                    );
                    if (mounted && dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added ₱${amount.toStringAsFixed(2)} to "${goal.title}"',
                          ),
                          backgroundColor: AppTheme.warmOrange,
                        ),
                      );
                    }
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
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Goal goal,
    BudgetProvider budgetProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppTheme.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Delete Goal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${goal.title}"? This action cannot be undone.',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.softPink),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await budgetProvider.deleteGoal(goal.id!);
                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Goal "${goal.title}" deleted'),
                        backgroundColor: AppTheme.roseRed,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.roseRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
