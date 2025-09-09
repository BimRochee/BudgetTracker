import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker_app/models/wallet.dart';
import 'package:budget_tracker_app/models/goal.dart';

void main() {
  group('Wallet Model Tests', () {
    test('Wallet creation and properties', () {
      final wallet = Wallet(
        id: 'test-wallet',
        name: 'Test Wallet',
        type: 'test',
        balance: 100.0,
        icon: 'test_icon',
        color: '#FF0000',
      );

      expect(wallet.id, 'test-wallet');
      expect(wallet.name, 'Test Wallet');
      expect(wallet.type, 'test');
      expect(wallet.balance, 100.0);
      expect(wallet.icon, 'test_icon');
      expect(wallet.color, '#FF0000');
    });

    test('Wallet copyWith method', () {
      final originalWallet = Wallet(
        id: 'original',
        name: 'Original',
        type: 'test',
        balance: 100.0,
        icon: 'icon',
        color: '#FF0000',
      );

      final updatedWallet = originalWallet.copyWith(
        name: 'Updated',
        balance: 200.0,
      );

      expect(updatedWallet.id, 'original');
      expect(updatedWallet.name, 'Updated');
      expect(updatedWallet.balance, 200.0);
      expect(updatedWallet.type, 'test');
      expect(updatedWallet.icon, 'icon');
      expect(updatedWallet.color, '#FF0000');
    });

    test('Wallet JSON serialization', () {
      final wallet = Wallet(
        id: 'json-test',
        name: 'JSON Test',
        type: 'test',
        balance: 150.0,
        icon: 'json_icon',
        color: '#00FF00',
      );

      final json = wallet.toJson();
      expect(json['id'], 'json-test');
      expect(json['name'], 'JSON Test');
      expect(json['balance'], 150.0);

      final fromJsonWallet = Wallet.fromJson(json);
      expect(fromJsonWallet.id, wallet.id);
      expect(fromJsonWallet.name, wallet.name);
      expect(fromJsonWallet.balance, wallet.balance);
    });

    test('Default wallets creation', () {
      final defaultWallets = Wallet.getDefaultWallets();

      expect(defaultWallets.length, 5);
      expect(defaultWallets.any((w) => w.id == 'gcash'), isTrue);
      expect(defaultWallets.any((w) => w.id == 'seabank'), isTrue);
      expect(defaultWallets.any((w) => w.id == 'cash'), isTrue);
      expect(defaultWallets.any((w) => w.id == 'bpi'), isTrue);
      expect(defaultWallets.any((w) => w.id == 'bdo'), isTrue);

      // All default wallets should have 0 balance
      for (final wallet in defaultWallets) {
        expect(wallet.balance, 0.0);
      }
    });
  });

  group('Goal Model Tests', () {
    test('Goal creation and properties', () {
      final now = DateTime.now();
      final goal = Goal(
        id: 1,
        title: 'Test Goal',
        targetAmount: 1000.0,
        currentAmount: 100.0,
        durationDays: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        dailyGoal: 33.33,
        status: 'ongoing',
      );

      expect(goal.id, 1);
      expect(goal.title, 'Test Goal');
      expect(goal.targetAmount, 1000.0);
      expect(goal.currentAmount, 100.0);
      expect(goal.durationDays, 30);
      expect(goal.status, 'ongoing');
    });

    test('Goal copyWith method', () {
      final now = DateTime.now();
      final originalGoal = Goal(
        id: 1,
        title: 'Original Goal',
        targetAmount: 1000.0,
        currentAmount: 100.0,
        durationDays: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        dailyGoal: 33.33,
        status: 'ongoing',
      );

      final updatedGoal = originalGoal.copyWith(
        title: 'Updated Goal',
        currentAmount: 200.0,
        status: 'completed',
      );

      expect(updatedGoal.id, 1);
      expect(updatedGoal.title, 'Updated Goal');
      expect(updatedGoal.currentAmount, 200.0);
      expect(updatedGoal.status, 'completed');
      expect(updatedGoal.targetAmount, 1000.0);
    });

    test('Goal JSON serialization', () {
      final now = DateTime.now();
      final goal = Goal(
        id: 2,
        title: 'JSON Goal',
        targetAmount: 500.0,
        currentAmount: 50.0,
        durationDays: 15,
        startDate: now,
        endDate: now.add(const Duration(days: 15)),
        dailyGoal: 33.33,
        status: 'ongoing',
      );

      final json = goal.toJson();
      expect(json['id'], 2);
      expect(json['title'], 'JSON Goal');
      expect(json['targetAmount'], 500.0);
      expect(json['status'], 'ongoing');

      final fromJsonGoal = Goal.fromJson(json);
      expect(fromJsonGoal.id, goal.id);
      expect(fromJsonGoal.title, goal.title);
      expect(fromJsonGoal.targetAmount, goal.targetAmount);
    });

    test('Goal progress calculation', () {
      final now = DateTime.now();
      final goal = Goal(
        id: 3,
        title: 'Progress Goal',
        targetAmount: 1000.0,
        currentAmount: 300.0,
        durationDays: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        dailyGoal: 33.33,
        status: 'ongoing',
      );

      expect(goal.progressPercentage, 0.3); // 300/1000 = 0.3
      expect(goal.remainingAmount, 700.0); // 1000 - 300 = 700
      expect(goal.isCompleted, false);
    });

    test('Goal completion status', () {
      final now = DateTime.now();
      final completedGoal = Goal(
        id: 4,
        title: 'Completed Goal',
        targetAmount: 1000.0,
        currentAmount: 1000.0,
        durationDays: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        dailyGoal: 33.33,
        status: 'completed',
      );

      expect(completedGoal.isCompleted, true);
      expect(completedGoal.progressPercentage, 1.0);
      expect(completedGoal.remainingAmount, 0.0);
    });
  });
}
