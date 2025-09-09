import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker_app/services/budget_provider.dart';
import 'package:budget_tracker_app/screens/dashboard_screen.dart';
import 'package:budget_tracker_app/theme/app_theme.dart';

void main() {
  group('Budget Tracker App Tests', () {
    testWidgets('App loads and shows dashboard', (WidgetTester tester) async {
      // Create a mock provider for testing
      final budgetProvider = BudgetProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<BudgetProvider>(
          create: (context) => budgetProvider,
          child: MaterialApp(
            title: 'Budget Tracker',
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify that the dashboard loads
      expect(find.text('Budget Tracker'), findsOneWidget);
      expect(find.text('Manage your finances'), findsOneWidget);
    });

    testWidgets('BudgetProvider initial state', (WidgetTester tester) async {
      final provider = BudgetProvider();

      // Test initial values
      expect(provider.totalBudget, 0.0);
      expect(provider.totalExpenses, 0.0);
      expect(provider.remainingBudget, 0.0);
      expect(provider.expenses, isEmpty);
      expect(provider.wallets, isNotEmpty);
      expect(provider.goals, isEmpty);
    });

    testWidgets('BudgetProvider expense management', (
      WidgetTester tester,
    ) async {
      final provider = BudgetProvider();

      // Set initial budget
      provider.setBudget(1000.0);
      expect(provider.totalBudget, 1000.0);
      expect(provider.remainingBudget, 1000.0);

      // Add an expense
      provider.addExpense('Test expense', 100.0, 'Food', 'cash');
      expect(provider.totalExpenses, 100.0);
      expect(provider.remainingBudget, 900.0);
      expect(provider.expenses.length, 1);

      // Remove the expense
      final expenseId = provider.expenses.first['id'];
      provider.removeExpense(expenseId);
      expect(provider.totalExpenses, 0.0);
      expect(provider.remainingBudget, 1000.0);
      expect(provider.expenses, isEmpty);
    });

    testWidgets('Wallet management', (WidgetTester tester) async {
      final provider = BudgetProvider();

      // Test initial wallets
      expect(provider.wallets.length, greaterThan(0));
      expect(
        provider.totalWalletBalance,
        0.0,
      ); // All wallets start with 0 balance

      // Test wallet by ID
      final firstWallet = provider.wallets.first;
      final foundWallet = provider.getWalletById(firstWallet.id);
      expect(foundWallet, isNotNull);
      expect(foundWallet!.id, firstWallet.id);

      // Test non-existent wallet
      final nonExistentWallet = provider.getWalletById('non-existent');
      expect(nonExistentWallet, isNull);
    });
  });
}
