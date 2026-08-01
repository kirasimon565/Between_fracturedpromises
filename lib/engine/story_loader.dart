import 'diagnostics/diagnostic.dart';
import 'lexer/source_span.dart';
import 'parser/ast.dart';
import 'parser/compiler.dart';
import 'parser/directive_registry.dart';
import 'parser/parser.dart';
import 'runtime/program.dart';

/// Reads a script source by logical path (`episodes/ep1.txt`).
///
/// The engine never touches `rootBundle` or `dart:io` directly — the host app
/// injects a resolver, which keeps the whole engine unit-testable from plain
/// Dart with an in-memory map.
typedef ScriptSourceResolver = Future<String> Function(String path);

/// Result of compiling one episode.
class CompiledStory {
  const CompiledStory({
    required this.program,
    required this.diagnostics,
    required this.sources,
  });

  final Program program;
  final List<Diagnostic> diagnostics;

  /// Every file that took part in the compilation (main + includes).
  final List<String> sources;

  bool get hasErrors => diagnostics.any((Diagnostic d) => d.isError);

  Iterable<Diagnostic> get errors => diagnostics.where((Diagnostic d) => d.isError);

  String get title => program.metaString('title', program.id);

  int get episodeNumber => program.metaInt('episode', 0);
}

/// Turns `.txt` story files into executable [Program]s.
///
/// Pipeline: resolve `@include`s → lex → parse → compile. Programs are cached
/// per path so re-entering an episode is instant.
class StoryLoader {
  StoryLoader({
    required this.resolver,
    DirectiveRegistry? registry,
    this.maxIncludeDepth = 8,
  }) : registry = registry ?? DirectiveRegistry.shared;

  final ScriptSourceResolver resolver;
  final DirectiveRegistry registry;
  final int maxIncludeDepth;

  final Map<String, CompiledStory> _cache = <String, CompiledStory>{};

  static final RegExp _includePattern =
      RegExp(r'^\s*@include\s+(.+?)\s*$', caseSensitive: false);

  /// Compiles [path], reusing the cached program unless [reload] is set.
  Future<CompiledStory> load(
    String path, {
    String? id,
    bool reload = false,
  }) async {
    final String key = '${id ?? path}::$path';
    final CompiledStory? cached = _cache[key];
    if (cached != null && !reload) return cached;

    final DiagnosticBag diagnostics = DiagnosticBag();
    final List<String> sources = <String>[];
    final String source =
        await _expand(path, diagnostics, sources, <String>{}, 0);

    final Parser parser = Parser.fromSource(
      source,
      sourceName: path,
      registry: registry,
    );
    final ScriptNode script = parser.parse();
    diagnostics.addAll(parser.diagnostics.all);

    final ScriptCompiler compiler = ScriptCompiler(diagnostics: diagnostics);
    final Program program = compiler.compile(script, id: id ?? _idFor(path));

    final CompiledStory story = CompiledStory(
      program: program,
      diagnostics: diagnostics.all,
      sources: sources,
    );
    _cache[key] = story;
    return story;
  }

  /// Compiles a script that is already in memory (tests, hot-reload tooling).
  CompiledStory compileSource(
    String source, {
    required String id,
    String sourceName = '<memory>',
  }) {
    final DiagnosticBag diagnostics = DiagnosticBag();
    final Parser parser = Parser.fromSource(
      source,
      sourceName: sourceName,
      registry: registry,
    );
    final ScriptNode script = parser.parse();
    diagnostics.addAll(parser.diagnostics.all);

    final ScriptCompiler compiler = ScriptCompiler(diagnostics: diagnostics);
    return CompiledStory(
      program: compiler.compile(script, id: id),
      diagnostics: diagnostics.all,
      sources: <String>[sourceName],
    );
  }

  void evict([String? path]) {
    if (path == null) {
      _cache.clear();
      return;
    }
    _cache.removeWhere((String key, _) => key.endsWith('::$path'));
  }

  /// Splices `@include "other.txt"` directives into a single source string.
  ///
  /// Doing this before lexing means labels from included files land in the same
  /// program, so `@goto` works across file boundaries.
  Future<String> _expand(
    String path,
    DiagnosticBag diagnostics,
    List<String> sources,
    Set<String> visiting,
    int depth,
  ) async {
    if (depth > maxIncludeDepth) {
      diagnostics.error(
        'Include depth exceeded at "$path" (circular @include?).',
        SourceSpan(source: path, line: 1, column: 1),
      );
      return '';
    }
    if (!visiting.add(path)) {
      diagnostics.warn(
        'Skipped repeated @include of "$path".',
        SourceSpan(source: path, line: 1, column: 1),
      );
      return '';
    }

    String raw;
    try {
      raw = await resolver(path);
    } catch (error) {
      diagnostics.error(
        'Could not read script "$path": $error',
        SourceSpan(source: path, line: 1, column: 1),
      );
      return '';
    }
    sources.add(path);

    final List<String> lines = raw.split('\n');
    final StringBuffer out = StringBuffer();

    for (int i = 0; i < lines.length; i++) {
      final Match? match = _includePattern.firstMatch(lines[i]);
      if (match == null) {
        out.writeln(lines[i]);
        continue;
      }
      final String target = _unquote(match.group(1)!);
      final String resolved = _resolveRelative(path, target);
      out.writeln('# --- begin include $resolved ---');
      out.write(
          await _expand(resolved, diagnostics, sources, visiting, depth + 1));
      out.writeln('# --- end include $resolved ---');
    }

    visiting.remove(path);
    return out.toString();
  }

  static String _unquote(String value) {
    final String trimmed = value.trim();
    if (trimmed.length >= 2 &&
        (trimmed.startsWith('"') && trimmed.endsWith('"') ||
            trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  static String _resolveRelative(String from, String target) {
    if (target.startsWith('/') || target.contains('://')) return target;
    final int slash = from.lastIndexOf('/');
    if (slash < 0) return target;
    return '${from.substring(0, slash + 1)}$target';
  }

  static String _idFor(String path) {
    final String file = path.split('/').last;
    final int dot = file.lastIndexOf('.');
    return dot <= 0 ? file : file.substring(0, dot);
  }
}
