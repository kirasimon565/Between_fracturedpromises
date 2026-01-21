class Choice {
  final String text;
  final String targetNode;
  final Map<String, dynamic>? impact;

  // Optional but useful later (analytics, debugging, replays)
  final String? id;

  Choice({
    required this.text,
    required this.targetNode,
    this.impact,
    this.id,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id']?.toString(),

      text: json['text']?.toString() ?? '',

      // ✅ supports both snake_case and camelCase
      targetNode: json['target_node']?.toString() ??
          json['targetNode']?.toString() ??
          '',

      // ✅ defensive cast
      impact: json['impact'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['impact'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'text': text,
        'target_node': targetNode,
        if (impact != null) 'impact': impact,
      };
}
