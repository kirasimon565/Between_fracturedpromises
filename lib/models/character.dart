// lib/models/character.dart

class Character {
  final String id;
  final String name;
  final String avatarPath;
  final String bio;
  final int age;
  final bool isVerified;

  // ✅ NEW (optional, but perfect for your cast writeups)
  final String? role;        // e.g. "Husband", "Friend", "Colleague"
  final String? occupation;  // e.g. "Marketing Coordinator"
  final String? tagline;     // short vibe line for list screens / profiles

  Character({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.bio,
    this.age = 25,
    this.isVerified = false,
    this.role,
    this.occupation,
    this.tagline,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown').toString(),

      // Updated directory as requested: assets/avatars/
      avatarPath: (json['avatarPath'] ?? 'assets/avatars/placeholder.png').toString(),

      bio: (json['bio'] ?? '').toString(),

      // ✅ safe int parsing (works even if stored as string)
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? '') ?? 25,

      isVerified: json['isVerified'] as bool? ?? false,

      // ✅ NEW optional fields
      role: json['role']?.toString(),
      occupation: json['occupation']?.toString(),
      tagline: json['tagline']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarPath': avatarPath,
        'bio': bio,
        'age': age,
        'isVerified': isVerified,
        if (role != null) 'role': role,
        if (occupation != null) 'occupation': occupation,
        if (tagline != null) 'tagline': tagline,
      };
}
