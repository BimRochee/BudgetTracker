class Goal {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final double dailyGoal;
  final String status; // 'ongoing' or 'completed'

  Goal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.dailyGoal,
    required this.status,
  });

  Goal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    double? dailyGoal,
    String? status,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'dailyGoal': dailyGoal,
      'status': status,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      targetAmount: json['targetAmount'].toDouble(),
      currentAmount: json['currentAmount'].toDouble(),
      durationDays: json['durationDays'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      dailyGoal: json['dailyGoal'].toDouble(),
      status: json['status'],
    );
  }

  // Calculate progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // Check if goal is completed
  bool get isCompleted => currentAmount >= targetAmount;

  // Get remaining amount
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, targetAmount);

  // Get days remaining
  int get daysRemaining {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference.clamp(0, durationDays);
  }

  // Get days elapsed
  int get daysElapsed {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;
    return difference.clamp(0, durationDays);
  }

  // Calculate if user is on track
  bool get isOnTrack {
    final expectedAmount = dailyGoal * daysElapsed;
    return currentAmount >= expectedAmount;
  }

  // Get status color based on progress
  String get statusColor {
    if (isCompleted) return 'completed';
    if (isOnTrack) return 'onTrack';
    return 'behind';
  }
}
