class UserModel {
  final String name;
  final String currency;
  final String currencySymbol;

  const UserModel({
    required this.name,
    this.currency = 'NGN',
    this.currencySymbol = '₦',
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? 'U' : name[0].toUpperCase();
  }

  UserModel copyWith({
    String? name,
    String? currency,
    String? currencySymbol,
  }) {
    return UserModel(
      name: name ?? this.name,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'currency': currency,
        'currencySymbol': currencySymbol,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        name: map['name'] as String? ?? 'User',
        currency: map['currency'] as String? ?? 'NGN',
        currencySymbol: map['currencySymbol'] as String? ?? '₦',
      );
}
