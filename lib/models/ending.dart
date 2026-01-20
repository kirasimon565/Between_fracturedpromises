enum EndingType { fractured, loyal, broken, alone, perfect, neutral }

class Ending {
  final String id;
  final EndingType type;
  final String title;
  final String description;
  final String imagePath;

  Ending({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  factory Ending.fromJson(Map<String, dynamic> json) {
    return Ending(
      // The '??' provides a fallback if Firestore returns null
      id: json['id']?.toString() ?? '',
      
      // Safe Enum Parsing: prevents crash if the string doesn't match
      type: EndingType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => EndingType.neutral,
      ),
      
      title: json['title']?.toString() ?? 'Ending Reached',
      description: json['description']?.toString() ?? '',
      
      // Using your avatar folder logic if no specific ending image is found
      imagePath: json['imagePath']?.toString() ?? json['image_path']?.toString() ?? 'assets/avatars/placeholder.png',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'title': title,
    'description': description,
    'imagePath': imagePath,
  };
}
