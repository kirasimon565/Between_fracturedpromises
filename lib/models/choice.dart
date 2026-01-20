class Choice {
  final String text;
  final String targetNode;
  final Map<String, dynamic>? impact;

  Choice({
    required this.text,
    required this.targetNode,
    this.impact,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      text: json['text']?.toString() ?? '',
      targetNode: json['target_node']?.toString() ?? json['targetNode']?.toString() ?? '',
      impact: json['impact'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'target_node': targetNode,
    'impact': impact,
  };
}
