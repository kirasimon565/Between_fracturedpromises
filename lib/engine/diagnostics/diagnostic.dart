import '../lexer/source_span.dart';

enum DiagnosticSeverity { info, warning, error }

/// A compile-time or runtime message tied to a script location.
class Diagnostic {
  const Diagnostic(this.severity, this.message, this.span);

  final DiagnosticSeverity severity;
  final String message;
  final SourceSpan span;

  bool get isError => severity == DiagnosticSeverity.error;

  @override
  String toString() => '[${severity.name.toUpperCase()}] $span: $message';
}

/// Collects diagnostics produced while lexing / parsing / compiling.
class DiagnosticBag {
  final List<Diagnostic> _items = <Diagnostic>[];

  List<Diagnostic> get all => List<Diagnostic>.unmodifiable(_items);

  Iterable<Diagnostic> get errors => _items.where((Diagnostic d) => d.isError);

  bool get hasErrors => _items.any((Diagnostic d) => d.isError);

  bool get isEmpty => _items.isEmpty;

  void info(String message, SourceSpan span) =>
      _items.add(Diagnostic(DiagnosticSeverity.info, message, span));

  void warn(String message, SourceSpan span) =>
      _items.add(Diagnostic(DiagnosticSeverity.warning, message, span));

  void error(String message, SourceSpan span) =>
      _items.add(Diagnostic(DiagnosticSeverity.error, message, span));

  void addAll(Iterable<Diagnostic> other) => _items.addAll(other);

  void clear() => _items.clear();

  String format({int limit = 40}) =>
      _items.take(limit).map((Diagnostic d) => d.toString()).join('\n');
}

/// Thrown when a script cannot be compiled at all.
class ScriptCompilationException implements Exception {
  ScriptCompilationException(this.diagnostics);

  final List<Diagnostic> diagnostics;

  @override
  String toString() =>
      'ScriptCompilationException:\n${diagnostics.map((Diagnostic d) => d.toString()).join('\n')}';
}

/// Thrown when the runtime hits an unrecoverable state.
class EngineRuntimeException implements Exception {
  EngineRuntimeException(this.message, [this.span]);

  final String message;
  final SourceSpan? span;

  @override
  String toString() =>
      'EngineRuntimeException: $message'
      '${span == null ? '' : ' at $span'}';
}
