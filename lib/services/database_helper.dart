import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/income.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'budget_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create goals table
    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        durationDays INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        dailyGoal REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // Create income table
    await db.execute('''
      CREATE TABLE income(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        walletId TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // Goals CRUD operations
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toJson());
  }

  Future<List<Goal>> getAllGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromJson(maps[i]));
  }

  Future<List<Goal>> getOngoingGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'status = ?',
      whereArgs: ['ongoing'],
    );
    return List.generate(maps.length, (i) => Goal.fromJson(maps[i]));
  }

  Future<List<Goal>> getCompletedGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'status = ?',
      whereArgs: ['completed'],
    );
    return List.generate(maps.length, (i) => Goal.fromJson(maps[i]));
  }

  Future<Goal?> getGoalById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Goal.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addContribution(int goalId, double amount) async {
    final goal = await getGoalById(goalId);
    if (goal == null) return 0;

    final newAmount = goal.currentAmount + amount;
    final updatedGoal = goal.copyWith(
      currentAmount: newAmount,
      status: newAmount >= goal.targetAmount ? 'completed' : 'ongoing',
    );

    return await updateGoal(updatedGoal);
  }

  // Income CRUD operations
  Future<int> insertIncome(Income income) async {
    final db = await database;
    return await db.insert('income', income.toJson());
  }

  Future<List<Income>> getAllIncome() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Income.fromJson(maps[i]));
  }

  Future<List<Income>> getIncomeByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Income.fromJson(maps[i]));
  }

  Future<List<Income>> getIncomeByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Income.fromJson(maps[i]));
  }

  Future<List<Income>> getIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Income.fromJson(maps[i]));
  }

  Future<Income?> getIncomeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Income.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateIncome(Income income) async {
    final db = await database;
    return await db.update(
      'income',
      income.toJson(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete('income', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM income',
    );
    return result.first['total']?.toDouble() ?? 0.0;
  }

  Future<double> getTotalIncomeByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM income WHERE type = ?',
      [type],
    );
    return result.first['total']?.toDouble() ?? 0.0;
  }

  Future<double> getTotalIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM income WHERE date BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return result.first['total']?.toDouble() ?? 0.0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
