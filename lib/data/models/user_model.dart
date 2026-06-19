class UserModel {
  final String name;
  final String currency;
  final String currencySymbol;
  final String? profession;
  final String? profileImagePath;

  const UserModel({
    required this.name,
    this.currency = 'INR',
    this.currencySymbol = '₹',
    this.profession,
    this.profileImagePath,
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
    String? profession,
    String? profileImagePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      profession: profession ?? this.profession,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'currency': currency,
        'currencySymbol': currencySymbol,
        'profession': profession,
        'profileImagePath': profileImagePath,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        name: map['name'] as String? ?? 'User',
        currency: map['currency'] as String? ?? 'INR',
        currencySymbol: map['currencySymbol'] as String? ?? '₹',
        profession: map['profession'] as String?,
        profileImagePath: map['profileImagePath'] as String?,
      );
}
