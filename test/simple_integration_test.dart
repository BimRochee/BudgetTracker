import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker_app/services/budget_provider.dart';
import 'package:budget_tracker_app/screens/dashboard_screen.dart';
import 'package:budget_tracker_app/screens/wallet_screen.dart';

void main() {
  group('Simple Integration Tests', () {
    testWidgets('Budget management flow', (WidgetTester tester) async {
      final budgetProvider = BudgetProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<BudgetProvider>(
          create: (context) => budgetProvider,
          child: MaterialApp(home: const DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Test setting budget
      budgetProvider.setBudget(5000.0);
      expect(budgetProvider.totalBudget, 5000.0);
      expect(budgetProvider.remainingBudget, 5000.0);

      // Test adding expenses
      budgetProvider.addExpense('Groceries', 200.0, 'Food', 'cash');
      budgetProvider.addExpense('Gas', 50.0, 'Transportation', 'gcash');

      expect(budgetProvider.totalExpenses, 250.0);
      expect(budgetProvider.remainingBudget, 4750.0);
      expect(budgetProvider.expenses.length, 2);

      // Test removing expense
      final firstExpenseId = budgetProvider.expenses.first['id'];
      budgetProvider.removeExpense(firstExpenseId);

      expect(budgetProvider.totalExpenses, 50.0);
      expect(budgetProvider.remainingBudget, 4950.0);
      expect(budgetProvider.expenses.length, 1);
    });

    testWidgets('Wallet management flow', (WidgetTester tester) async {
      final budgetProvider = BudgetProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<BudgetProvider>(
          create: (context) => budgetProvider,
          child: MaterialApp(home: const WalletScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Test initial wallet state
      expect(budgetProvider.wallets.length, 5);
      expect(budgetProvider.totalWalletBalance, 0.0);

      // Test wallet balance updates
      budgetProvider.updateWalletBalance('cash', 1000.0);
      budgetProvider.updateWalletBalance('gcash', 500.0);

      expect(budgetProvider.totalWalletBalance, 1500.0);

      final cashWallet = budgetProvider.getWalletById('cash');
      expect(cashWallet?.balance, 1000.0);

      final gcashWallet = budgetProvider.getWalletById('gcash');
      expect(gcashWallet?.balance, 500.0);
    });

    testWidgets('Error handling', (WidgetTester tester) async {
      final budgetProvider = BudgetProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<BudgetProvider>(
          create: (context) => budgetProvider,
          child: MaterialApp(home: const DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Test removing non-existent expense
      expect(
        () => budgetProvider.removeExpense('non-existent'),
        throwsA(isA<StateError>()),
      );

      // Test getting non-existent wallet
      final nonExistentWallet = budgetProvider.getWalletById('non-existent');
      expect(nonExistentWallet, isNull);

      // Test getting non-existent goal
      final nonExistentGoal = budgetProvider.getGoalById(999);
      expect(nonExistentGoal, isNull);
    });

    testWidgets('Expense category management', (WidgetTester tester) async {
      final budgetProvider = BudgetProvider();

      // Test different expense categories
      budgetProvider.addExpense('Lunch', 25.0, 'Food', 'cash');
      budgetProvider.addExpense('Uber', 15.0, 'Transportation', 'gcash');
      budgetProvider.addExpense('Movie', 12.0, 'Entertainment', 'bpi');
      budgetProvider.addExpense('Medicine', 50.0, 'Healthcare', 'seabank');

      expect(budgetProvider.expenses.length, 4);
      expect(budgetProvider.totalExpenses, 102.0);

      // Test expense filtering by category
      final foodExpenses =
          budgetProvider.expenses
              .where((exp) => exp['category'] == 'Food')
              .toList();
      expect(foodExpenses.length, 1);
      expect(foodExpenses.first['amount'], 25.0);

      final transportExpenses =
          budgetProvider.expenses
              .where((exp) => exp['category'] == 'Transportation')
              .toList();
      expect(transportExpenses.length, 1);
      expect(transportExpenses.first['amount'], 15.0);
    });

    testWidgets('Wallet balance consistency', (WidgetTester tester) async {
      final budgetProvider = BudgetProvider();

      // Set initial wallet balances
      budgetProvider.updateWalletBalance('cash', 1000.0);
      budgetProvider.updateWalletBalance('gcash', 500.0);
      budgetProvider.updateWalletBalance('bpi', 2000.0);

      expect(budgetProvider.totalWalletBalance, 3500.0);

      // Add expenses from different wallets
      budgetProvider.addExpense('Cash purchase', 100.0, 'Food', 'cash');
      budgetProvider.addExpense(
        'GCash payment',
        50.0,
        'Transportation',
        'gcash',
      );
      budgetProvider.addExpense('BPI transfer', 200.0, 'Bills', 'bpi');

      // Check that wallet balances are updated correctly
      final cashWallet = budgetProvider.getWalletById('cash');
      expect(cashWallet?.balance, 900.0); // 1000 - 100

      final gcashWallet = budgetProvider.getWalletById('gcash');
      expect(gcashWallet?.balance, 450.0); // 500 - 50

      final bpiWallet = budgetProvider.getWalletById('bpi');
      expect(bpiWallet?.balance, 1800.0); // 2000 - 200

      // Total should still be consistent
      expect(budgetProvider.totalWalletBalance, 3150.0); // 3500 - 350
    });
  });
}
