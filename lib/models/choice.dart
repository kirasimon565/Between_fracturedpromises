class Choice {
  final String id;
  final String text;
  final String nextSceneId;
  final Map<String, dynamic>? impact; // e.g. {'romance': 1, 'suspicion': 5}

  Choice({
    required this.id,
    required this.text,
    required this.nextSceneId,
    this.impact,
  });
}
