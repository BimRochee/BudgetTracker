import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../models/goal.dart';
import '../models/income.dart';
import '../utils/error_handler.dart';
import 'database_helper.dart';

class BudgetProvider extends ChangeNotifier {
  double _totalBudget = 0.0;
  double _totalExpenses = 0.0;
  List<Map<String, dynamic>> _expenses = [];
  List<Income> _income = [];
  List<Wallet> _wallets = Wallet.getDefaultWallets();
  List<Goal> _goals = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double get totalBudget => _totalBudget;
  double get totalExpenses => _totalExpenses;
  double get totalIncome =>
      _income.fold(0.0, (sum, income) => sum + income.amount);
  double get remainingBudget => _totalBudget - _totalExpenses;
  double get netIncome => totalIncome - totalExpenses;
  List<Map<String, dynamic>> get expenses => _expenses;
  List<Income> get income => _income;
  List<Wallet> get wallets => _wallets;
  List<Goal> get goals => _goals;
  double get totalWalletBalance =>
      _wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  List<Goal> get ongoingGoals =>
      _goals.where((goal) => goal.status == 'ongoing').toList();
  List<Goal> get completedGoals =>
      _goals.where((goal) => goal.status == 'completed').toList();

  Future<void> setBudget(double amount) async {
    _totalBudget = amount;
    await _databaseHelper.setBudget(_totalBudget, _totalExpenses);
    notifyListeners();
  }

  Future<void> addExpense(
    String description,
    double amount,
    String category,
    String walletId,
  ) async {
    try {
      ErrorHandler.logInfo(
        'BudgetProvider.addExpense called with: description=$description, amount=$amount, category=$category, walletId=$walletId',
      );

      final expense = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'description': description,
        'amount': amount,
        'category': category,
        'walletId': walletId,
        'date': DateTime.now().toIso8601String(),
      };

      // Save to database
      await _databaseHelper.insertExpense(expense);

      // Update memory
      _expenses = [expense, ..._expenses];
      _totalExpenses += amount;

      // Deduct from wallet balance
      await _updateWalletBalance(walletId, -amount);

      // Update budget in database
      await _databaseHelper.setBudget(_totalBudget, _totalExpenses);

      notifyListeners();

      ErrorHandler.logInfo(
        'Expense added successfully. Total expenses: $_totalExpenses',
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        'Error in BudgetProvider.addExpense',
        e,
        stackTrace,
      );
    }
  }

  Future<void> removeExpense(String id) async {
    final expense = _expenses.firstWhere((exp) => exp['id'] == id);
    final walletId = expense['walletId'];
    final amount = expense['amount'];

    // Remove from database
    await _databaseHelper.deleteExpense(id);

    // Update memory
    _expenses = _expenses.where((expense) => expense['id'] != id).toList();
    _totalExpenses = _expenses.fold(
      0.0,
      (sum, expense) => sum + expense['amount'],
    );

    // Add back to wallet balance
    await _updateWalletBalance(walletId, amount);

    // Update budget in database
    await _databaseHelper.setBudget(_totalBudget, _totalExpenses);

    notifyListeners();
  }

  Future<void> addWallet(Wallet wallet) async {
    // Save to database
    await _databaseHelper.insertWallet(wallet.toJson());

    // Update memory
    _wallets = [..._wallets, wallet];
    notifyListeners();
  }

  Future<void> updateWalletBalance(String walletId, double amount) async {
    await _updateWalletBalance(walletId, amount);
    notifyListeners();
  }

  Future<void> _updateWalletBalance(String walletId, double amount) async {
    _wallets =
        _wallets.map((wallet) {
          if (wallet.id == walletId) {
            final updatedWallet = wallet.copyWith(
              balance: wallet.balance + amount,
            );
            // Update in database
            _databaseHelper.updateWallet(updatedWallet.toJson());
            return updatedWallet;
          }
          return wallet;
        }).toList();

    // Remove wallet if balance becomes 0 or negative
    try {
      final wallet = _wallets.firstWhere((w) => w.id == walletId);
      if (wallet.balance <= 0.0) {
        await _databaseHelper.deleteWallet(walletId);
        _wallets = _wallets.where((w) => w.id != walletId).toList();
      }
    } catch (e) {
      // Wallet not found, ignore
    }
  }

  Wallet? getWalletById(String walletId) {
    try {
      return _wallets.firstWhere((wallet) => wallet.id == walletId);
    } catch (e) {
      return null;
    }
  }

  // Goal management methods
  Future<void> loadGoals() async {
    _goals = await _databaseHelper.getAllGoals();
    notifyListeners();
  }

  Future<int> createGoal({
    required String title,
    required double targetAmount,
    required int durationDays,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: durationDays));
    final dailyGoal = targetAmount / durationDays;

    final goal = Goal(
      title: title,
      targetAmount: targetAmount,
      currentAmount: 0.0,
      durationDays: durationDays,
      startDate: now,
      endDate: endDate,
      dailyGoal: dailyGoal,
      status: 'ongoing',
    );

    final id = await _databaseHelper.insertGoal(goal);
    await loadGoals();
    return id;
  }

  Future<void> addContributionToGoal(int goalId, double amount) async {
    await _databaseHelper.addContribution(goalId, amount);
    await loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await _databaseHelper.updateGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(int goalId) async {
    await _databaseHelper.deleteGoal(goalId);
    await loadGoals();
  }

  Goal? getGoalById(int goalId) {
    try {
      return _goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }

  // Income management methods
  Future<void> loadIncome() async {
    _income = await _databaseHelper.getAllIncome();
    notifyListeners();
  }

  Future<int> addIncome({
    required String source,
    required double amount,
    required String category,
    required String walletId,
    required String description,
    required String type,
    DateTime? date,
  }) async {
    final income = Income(
      source: source,
      amount: amount,
      category: category,
      walletId: walletId,
      date: date ?? DateTime.now(),
      description: description,
      type: type,
    );

    final id = await _databaseHelper.insertIncome(income);
    await loadIncome();

    // Add to wallet balance
    _updateWalletBalance(walletId, amount);
    notifyListeners();

    return id;
  }

  Future<void> updateIncome(Income income) async {
    await _databaseHelper.updateIncome(income);
    await loadIncome();
  }

  Future<void> deleteIncome(int incomeId) async {
    final income = _income.firstWhere((inc) => inc.id == incomeId);

    // Remove from wallet balance
    _updateWalletBalance(income.walletId, -income.amount);

    await _databaseHelper.deleteIncome(incomeId);
    await loadIncome();
  }

  Income? getIncomeById(int incomeId) {
    try {
      return _income.firstWhere((income) => income.id == incomeId);
    } catch (e) {
      return null;
    }
  }

  List<Income> getIncomeByType(String type) {
    return _income.where((income) => income.type == type).toList();
  }

  List<Income> getIncomeByCategory(String category) {
    return _income.where((income) => income.category == category).toList();
  }

  double getTotalIncomeByType(String type) {
    return _income
        .where((income) => income.type == type)
        .fold(0.0, (sum, income) => sum + income.amount);
  }

  double getTotalIncomeByCategory(String category) {
    return _income
        .where((income) => income.category == category)
        .fold(0.0, (sum, income) => sum + income.amount);
  }

  // Load all data from database
  Future<void> loadAllData() async {
    try {
      // Load expenses
      final expensesData = await _databaseHelper.getAllExpenses();
      _expenses = expensesData;
      _totalExpenses = expensesData.fold(
        0.0,
        (sum, expense) => sum + expense['amount'],
      );

      // Load wallets
      final walletsData = await _databaseHelper.getAllWallets();
      _wallets = walletsData.map((data) => Wallet.fromJson(data)).toList();

      // Remove wallets with 0 balance
      await _removeZeroBalanceWallets();

      // Load budget
      final budgetData = await _databaseHelper.getBudget();
      if (budgetData != null) {
        _totalBudget = budgetData['totalBudget']?.toDouble() ?? 0.0;
        _totalExpenses = budgetData['totalExpenses']?.toDouble() ?? 0.0;
      }

      // Load goals and income (already implemented)
      await loadGoals();
      await loadIncome();

      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error loading all data', e, stackTrace);
    }
  }

  // Remove wallets with 0 balance
  Future<void> _removeZeroBalanceWallets() async {
    final zeroBalanceWallets =
        _wallets.where((wallet) => wallet.balance == 0.0).toList();

    for (final wallet in zeroBalanceWallets) {
      await _databaseHelper.deleteWallet(wallet.id);
    }

    // Update the wallets list to exclude zero balance wallets
    _wallets = _wallets.where((wallet) => wallet.balance > 0.0).toList();
  }
}
