class Income {
  final int? id;
  final String source;
  final double amount;
  final String category;
  final String walletId;
  final DateTime date;
  final String description;
  final String type; // 'salary', 'freelance', 'investment', 'gift', 'other'

  Income({
    this.id,
    required this.source,
    required this.amount,
    required this.category,
    required this.walletId,
    required this.date,
    required this.description,
    required this.type,
  });

  Income copyWith({
    int? id,
    String? source,
    double? amount,
    String? category,
    String? walletId,
    DateTime? date,
    String? description,
    String? type,
  }) {
    return Income(
      id: id ?? this.id,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'category': category,
      'walletId': walletId,
      'date': date.toIso8601String(),
      'description': description,
      'type': type,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      source: json['source'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      walletId: json['walletId'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      type: json['type'],
    );
  }

  // Get formatted amount string
  String get formattedAmount => '₱${amount.toStringAsFixed(2)}';

  // Get formatted date string
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Get income type icon
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'salary':
        return 'work';
      case 'freelance':
        return 'business_center';
      case 'investment':
        return 'trending_up';
      case 'gift':
        return 'card_giftcard';
      case 'other':
        return 'more_horiz';
      default:
        return 'attach_money';
    }
  }

  // Get income type color
  String get typeColor {
    switch (type.toLowerCase()) {
      case 'salary':
        return '#4CAF50'; // Green
      case 'freelance':
        return '#2196F3'; // Blue
      case 'investment':
        return '#FF9800'; // Orange
      case 'gift':
        return '#E91E63'; // Pink
      case 'other':
        return '#9E9E9E'; // Grey
      default:
        return '#607D8B'; // Blue Grey
    }
  }

  // Static method to get income categories
  static List<String> getIncomeCategories() {
    return [
      'Salary',
      'Freelance',
      'Investment',
      'Gift',
      'Business',
      'Rental',
      'Other',
    ];
  }

  // Static method to get income types
  static List<String> getIncomeTypes() {
    return [
      'salary',
      'freelance',
      'investment',
      'gift',
      'business',
      'rental',
      'other',
    ];
  }
}
