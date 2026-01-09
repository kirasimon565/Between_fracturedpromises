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
}
