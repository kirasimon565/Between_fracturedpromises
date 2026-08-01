import '../parser/ast.dart';

/// One option as the UI should draw it, after conditions have been evaluated.
class ChoiceOptionView {
  const ChoiceOptionView({
    required this.index,
    required this.id,
    required this.label,
    required this.kind,
    required this.target,
    this.cost = 0,
    this.enabled = true,
    this.hint,
    this.alreadyOwned = false,
    this.picked = false,
  });

  final int index;
  final String id;
  final String label;
  final ChoiceOptionKind kind;
  final int target;
  final int cost;

  /// False when a `requires` clause failed or crystals are missing.
  final bool enabled;
  final String? hint;

  /// Premium option the player already paid for (free to re-pick).
  final bool alreadyOwned;

  /// Whether this option was chosen in a previous playthrough of the scene.
  final bool picked;

  bool get isPremium => kind == ChoiceOptionKind.premium;
  bool get isLocked => kind == ChoiceOptionKind.locked || !enabled;
}

/// A choice currently waiting for input.
class PendingChoice {
  const PendingChoice({
    required this.options,
    required this.address,
    this.prompt,
    this.timeout,
    this.startedAt,
    this.style,
  });

  final List<ChoiceOptionView> options;

  /// Address of the `ChoiceInstruction`, so a save can resume right here.
  final int address;
  final String? prompt;
  final Duration? timeout;
  final DateTime? startedAt;
  final String? style;

  bool get isTimed => timeout != null;

  Duration remaining(DateTime now) {
    if (timeout == null || startedAt == null) return Duration.zero;
    final Duration elapsed = now.difference(startedAt!);
    final Duration left = timeout! - elapsed;
    return left.isNegative ? Duration.zero : left;
  }
}
