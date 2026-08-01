import '../parser/expression.dart';
import '../variables/engine_value.dart';
import 'instruction.dart';

/// A compiled, executable script.
///
/// Programs are immutable and cheap to keep in memory (Episode 1 compiles to a
/// few thousand instructions), so the loader caches one per episode.
class Program {
  Program({
    required this.id,
    required this.sourceName,
    required this.instructions,
    required this.labels,
    required this.labelOrder,
    Map<String, Expression>? metadata,
  }) : metadata = metadata ?? <String, Expression>{};

  /// Stable id, usually the episode id (`ep1`).
  final String id;
  final String sourceName;
  final List<Instruction> instructions;

  /// label name → instruction address.
  final Map<String, int> labels;

  /// Declaration order, used for "next scene" fall-through and debug tooling.
  final List<String> labelOrder;

  final Map<String, Expression> metadata;

  int get length => instructions.length;

  int get entryPoint => labelOrder.isEmpty ? 0 : labels[labelOrder.first] ?? 0;

  bool isValidAddress(int address) =>
      address >= 0 && address < instructions.length;

  Instruction operator [](int address) => instructions[address];

  int? addressOf(String label) => labels[label];

  bool hasLabel(String label) => labels.containsKey(label);

  /// Nearest preceding label for an address — used for save files and the HUD.
  String labelAt(int address) {
    String best = labelOrder.isEmpty ? '' : labelOrder.first;
    int bestAddress = -1;
    labels.forEach((String name, int at) {
      if (at <= address && at > bestAddress) {
        bestAddress = at;
        best = name;
      }
    });
    return best;
  }

  int lineAt(int address) =>
      isValidAddress(address) ? instructions[address].span.line : 0;

  /// Static metadata resolved against an empty scope (literals only).
  String metaString(String key, [String fallback = '']) {
    final Expression? expression = metadata[key];
    if (expression is LiteralExpression) return expression.value.asString;
    return fallback;
  }

  int metaInt(String key, [int fallback = 0]) {
    final Expression? expression = metadata[key];
    if (expression is LiteralExpression) {
      return expression.value.asNum.round();
    }
    return fallback;
  }

  EngineValue metaValue(String key) {
    final Expression? expression = metadata[key];
    if (expression is LiteralExpression) return expression.value;
    return EngineValue.nullValue;
  }

  @override
  String toString() =>
      'Program($id, ${instructions.length} instructions, ${labels.length} labels)';
}
