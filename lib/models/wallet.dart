class Wallet {
  final String id;
  final String name;
  final String type; // 'gcash', 'seabank', 'cash', 'bpi', 'bdo', etc.
  final double balance;
  final String icon; // Icon identifier
  final String color; // Hex color code

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
  });

  Wallet copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? icon,
    String? color,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'icon': icon,
      'color': color,
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      balance: json['balance'].toDouble(),
      icon: json['icon'],
      color: json['color'],
    );
  }

  static List<Wallet> getDefaultWallets() {
    return [
      Wallet(
        id: 'gcash',
        name: 'GCash',
        type: 'gcash',
        balance: 0.0,
        icon: 'account_balance_wallet',
        color: '#00A651',
      ),
      Wallet(
        id: 'seabank',
        name: 'SeaBank',
        type: 'seabank',
        balance: 0.0,
        icon: 'savings',
        color: '#0066CC',
      ),
      Wallet(
        id: 'cash',
        name: 'Cash',
        type: 'cash',
        balance: 0.0,
        icon: 'money',
        color: '#FFD700',
      ),
      Wallet(
        id: 'bpi',
        name: 'BPI',
        type: 'bank',
        balance: 0.0,
        icon: 'account_balance',
        color: '#E31E24',
      ),
      Wallet(
        id: 'bdo',
        name: 'BDO',
        type: 'bank',
        balance: 0.0,
        icon: 'account_balance',
        color: '#0066B2',
      ),
    ];
  }
}
