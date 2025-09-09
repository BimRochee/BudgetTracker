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

  void setBudget(double amount) {
    _totalBudget = amount;
    notifyListeners();
  }

  void addExpense(
    String description,
    double amount,
    String category,
    String walletId,
  ) {
    try {
      ErrorHandler.logInfo(
        'BudgetProvider.addExpense called with: description=$description, amount=$amount, category=$category, walletId=$walletId',
      );

      _expenses = [
        ..._expenses,
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'description': description,
          'amount': amount,
          'category': category,
          'walletId': walletId,
          'date': DateTime.now(),
        },
      ];
      _totalExpenses += amount;

      // Deduct from wallet balance
      _updateWalletBalance(walletId, -amount);
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

  void removeExpense(String id) {
    final expense = _expenses.firstWhere((exp) => exp['id'] == id);
    final walletId = expense['walletId'];
    final amount = expense['amount'];

    _expenses = _expenses.where((expense) => expense['id'] != id).toList();
    _totalExpenses = _expenses.fold(
      0.0,
      (sum, expense) => sum + expense['amount'],
    );

    // Add back to wallet balance
    _updateWalletBalance(walletId, amount);
    notifyListeners();
  }

  void addWallet(Wallet wallet) {
    _wallets = [..._wallets, wallet];
    notifyListeners();
  }

  void updateWalletBalance(String walletId, double amount) {
    _updateWalletBalance(walletId, amount);
    notifyListeners();
  }

  void _updateWalletBalance(String walletId, double amount) {
    _wallets =
        _wallets.map((wallet) {
          if (wallet.id == walletId) {
            return wallet.copyWith(balance: wallet.balance + amount);
          }
          return wallet;
        }).toList();
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
}
