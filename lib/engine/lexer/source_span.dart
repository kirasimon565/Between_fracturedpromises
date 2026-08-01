/// Location bookkeeping for the DSL sources.
///
/// Every token, AST node and compiled instruction carries a [SourceSpan] so the
/// runtime can report "script.txt:142" style diagnostics and so the debugger
/// overlay can show the exact line that is currently executing.
class SourceSpan {
  const SourceSpan({
    required this.source,
    required this.line,
    required this.column,
    this.length = 0,
  });

  /// Logical name of the script, e.g. `episodes/ep1.txt`.
  final String source;

  /// 1-based line number.
  final int line;

  /// 1-based column number.
  final int column;

  /// Number of characters covered by the span.
  final int length;

  static const SourceSpan unknown =
      SourceSpan(source: '<unknown>', line: 0, column: 0);

  SourceSpan copyWith({String? source, int? line, int? column, int? length}) {
    return SourceSpan(
      source: source ?? this.source,
      line: line ?? this.line,
      column: column ?? this.column,
      length: length ?? this.length,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        's': source,
        'l': line,
        'c': column,
        'n': length,
      };

  factory SourceSpan.fromJson(Map<String, dynamic> json) => SourceSpan(
        source: (json['s'] as String?) ?? '<unknown>',
        line: (json['l'] as num?)?.toInt() ?? 0,
        column: (json['c'] as num?)?.toInt() ?? 0,
        length: (json['n'] as num?)?.toInt() ?? 0,
      );

  @override
  String toString() => '$source:$line:$column';
}
