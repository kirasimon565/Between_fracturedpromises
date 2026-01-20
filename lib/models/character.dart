class Character {
  final String id;
  final String name;
  final String avatarPath;
  final String bio;
  final int age;
  final bool isVerified;

  Character({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.bio,
    this.age = 25,
    this.isVerified = false,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      // Updated directory as requested: assets/avatars/
      avatarPath: json['avatarPath']?.toString() ?? 'assets/avatars/placeholder.png',
      bio: json['bio']?.toString() ?? '',
      age: json['age'] as int? ?? 25,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
