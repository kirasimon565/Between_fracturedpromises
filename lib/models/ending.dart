enum EndingType { fractured, loyal, broken, alone }

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
}
