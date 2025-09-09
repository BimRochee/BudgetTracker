import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker_app/models/income.dart';
import 'package:budget_tracker_app/services/budget_provider.dart';

void main() {
  group('Income Model Tests', () {
    test('Income creation and properties', () {
      final now = DateTime.now();
      final income = Income(
        id: 1,
        source: 'ABC Company',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: now,
        description: 'Monthly salary',
        type: 'salary',
      );

      expect(income.id, 1);
      expect(income.source, 'ABC Company');
      expect(income.amount, 5000.0);
      expect(income.category, 'Salary');
      expect(income.walletId, 'bpi');
      expect(income.description, 'Monthly salary');
      expect(income.type, 'salary');
    });

    test('Income copyWith method', () {
      final now = DateTime.now();
      final originalIncome = Income(
        id: 1,
        source: 'ABC Company',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: now,
        description: 'Monthly salary',
        type: 'salary',
      );

      final updatedIncome = originalIncome.copyWith(
        amount: 6000.0,
        description: 'Updated salary',
      );

      expect(updatedIncome.id, 1);
      expect(updatedIncome.source, 'ABC Company');
      expect(updatedIncome.amount, 6000.0);
      expect(updatedIncome.description, 'Updated salary');
      expect(updatedIncome.category, 'Salary');
    });

    test('Income JSON serialization', () {
      final now = DateTime.now();
      final income = Income(
        id: 2,
        source: 'Freelance Client',
        amount: 1500.0,
        category: 'Freelance',
        walletId: 'gcash',
        date: now,
        description: 'Web development project',
        type: 'freelance',
      );

      final json = income.toJson();
      expect(json['id'], 2);
      expect(json['source'], 'Freelance Client');
      expect(json['amount'], 1500.0);
      expect(json['type'], 'freelance');

      final fromJsonIncome = Income.fromJson(json);
      expect(fromJsonIncome.id, income.id);
      expect(fromJsonIncome.source, income.source);
      expect(fromJsonIncome.amount, income.amount);
    });

    test('Income formatted amount', () {
      final income = Income(
        source: 'Test',
        amount: 1234.56,
        category: 'Test',
        walletId: 'cash',
        date: DateTime.now(),
        description: 'Test',
        type: 'other',
      );

      expect(income.formattedAmount, '₱1234.56');
    });

    test('Income formatted date', () {
      final income = Income(
        source: 'Test',
        amount: 100.0,
        category: 'Test',
        walletId: 'cash',
        date: DateTime(2024, 3, 15),
        description: 'Test',
        type: 'other',
      );

      expect(income.formattedDate, '15/3/2024');
    });

    test('Income type icon and color', () {
      final salaryIncome = Income(
        source: 'Company',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Salary',
        type: 'salary',
      );

      expect(salaryIncome.typeIcon, 'work');
      expect(salaryIncome.typeColor, '#4CAF50');

      final freelanceIncome = Income(
        source: 'Client',
        amount: 1000.0,
        category: 'Freelance',
        walletId: 'gcash',
        date: DateTime.now(),
        description: 'Project',
        type: 'freelance',
      );

      expect(freelanceIncome.typeIcon, 'business_center');
      expect(freelanceIncome.typeColor, '#2196F3');
    });

    test('Income categories and types', () {
      final categories = Income.getIncomeCategories();
      expect(categories.length, 7);
      expect(categories, contains('Salary'));
      expect(categories, contains('Freelance'));
      expect(categories, contains('Investment'));

      final types = Income.getIncomeTypes();
      expect(types.length, 7);
      expect(types, contains('salary'));
      expect(types, contains('freelance'));
      expect(types, contains('investment'));
    });
  });

  group('BudgetProvider Income State Tests', () {
    test('Initial income state', () {
      final provider = BudgetProvider();

      expect(provider.income, isEmpty);
      expect(provider.totalIncome, 0.0);
      expect(provider.netIncome, 0.0);
    });

    test('Income filtering by type (in-memory)', () {
      final provider = BudgetProvider();

      // Manually add income to the list (simulating database load)
      final income1 = Income(
        source: 'Company A',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Salary',
        type: 'salary',
      );

      final income2 = Income(
        source: 'Client B',
        amount: 1500.0,
        category: 'Freelance',
        walletId: 'gcash',
        date: DateTime.now(),
        description: 'Project',
        type: 'freelance',
      );

      final income3 = Income(
        source: 'Company C',
        amount: 3000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Bonus',
        type: 'salary',
      );

      // Manually add to provider's income list
      provider.income.addAll([income1, income2, income3]);

      final salaryIncome = provider.getIncomeByType('salary');
      expect(salaryIncome.length, 2);
      expect(salaryIncome.every((income) => income.type == 'salary'), isTrue);

      final freelanceIncome = provider.getIncomeByType('freelance');
      expect(freelanceIncome.length, 1);
      expect(freelanceIncome.first.type, 'freelance');
    });

    test('Income filtering by category (in-memory)', () {
      final provider = BudgetProvider();

      final income1 = Income(
        source: 'Company A',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Salary',
        type: 'salary',
      );

      final income2 = Income(
        source: 'Client B',
        amount: 1500.0,
        category: 'Freelance',
        walletId: 'gcash',
        date: DateTime.now(),
        description: 'Project',
        type: 'freelance',
      );

      provider.income.addAll([income1, income2]);

      final salaryCategory = provider.getIncomeByCategory('Salary');
      expect(salaryCategory.length, 1);
      expect(salaryCategory.first.category, 'Salary');

      final freelanceCategory = provider.getIncomeByCategory('Freelance');
      expect(freelanceCategory.length, 1);
      expect(freelanceCategory.first.category, 'Freelance');
    });

    test('Total income calculations (in-memory)', () {
      final provider = BudgetProvider();

      final income1 = Income(
        source: 'Company A',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Salary',
        type: 'salary',
      );

      final income2 = Income(
        source: 'Client B',
        amount: 1500.0,
        category: 'Freelance',
        walletId: 'gcash',
        date: DateTime.now(),
        description: 'Project',
        type: 'freelance',
      );

      final income3 = Income(
        source: 'Investment',
        amount: 500.0,
        category: 'Investment',
        walletId: 'seabank',
        date: DateTime.now(),
        description: 'Dividends',
        type: 'investment',
      );

      provider.income.addAll([income1, income2, income3]);

      expect(provider.totalIncome, 7000.0);
      expect(provider.getTotalIncomeByType('salary'), 5000.0);
      expect(provider.getTotalIncomeByType('freelance'), 1500.0);
      expect(provider.getTotalIncomeByType('investment'), 500.0);
      expect(provider.getTotalIncomeByCategory('Salary'), 5000.0);
      expect(provider.getTotalIncomeByCategory('Freelance'), 1500.0);
    });

    test('Net income calculation (in-memory)', () {
      final provider = BudgetProvider();

      // Add income manually
      final income = Income(
        source: 'Company',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Salary',
        type: 'salary',
      );
      provider.income.add(income);

      // Add expenses
      provider.addExpense('Food', 500.0, 'Food', 'cash');
      provider.addExpense('Transport', 200.0, 'Transportation', 'gcash');

      expect(provider.totalIncome, 5000.0);
      expect(provider.totalExpenses, 700.0);
      expect(provider.netIncome, 4300.0);
    });

    test('Get income by ID (in-memory)', () {
      final provider = BudgetProvider();

      final income1 = Income(
        id: 1,
        source: 'Test Company',
        amount: 5000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Salary',
        type: 'salary',
      );

      final income2 = Income(
        id: 2,
        source: 'Another Company',
        amount: 3000.0,
        category: 'Salary',
        walletId: 'bpi',
        date: DateTime.now(),
        description: 'Salary',
        type: 'salary',
      );

      provider.income.addAll([income1, income2]);

      final foundIncome = provider.getIncomeById(1);
      expect(foundIncome, isNotNull);
      expect(foundIncome!.source, 'Test Company');
      expect(foundIncome.amount, 5000.0);

      final nonExistentIncome = provider.getIncomeById(999);
      expect(nonExistentIncome, isNull);
    });
  });
}
