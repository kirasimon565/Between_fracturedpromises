class Choice {
  final String text;
  final String targetNodeId; // Renamed to match usage in ChatScreen (targetNodeId)
  final Map<String, dynamic>? impact;
  final String? id;

  Choice({
    required this.text,
    required this.targetNodeId,
    this.impact,
    this.id,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id']?.toString(),

      text: json['text']?.toString() ?? '',

      // ✅ supports both snake_case and camelCase
      targetNodeId: json['target_node']?.toString() ??
          json['targetNode']?.toString() ??
          json['targetNodeId']?.toString() ?? // Added support for targetNodeId key just in case
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
        'targetNodeId': targetNodeId,
        if (impact != null) 'impact': impact,
      };
}
