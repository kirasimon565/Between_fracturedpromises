import 'dart:math';

class DelayModel {
  static const int minTypingMs = 800;
  static const int maxTypingMs = 6000;
  static const int perCharMs = 40;

  static const int baseGapMs = 1000;

  /// Returns (typingDuration, gapDuration) in milliseconds
  static ({int typing, int gap}) computeDelays({
    required String sender,
    required String content,
    required String type,
    int? overrideDelay,
  }) {
    // If script has a specific delay override, use it as the gap/delivery wait.
    // But we still need a "typing" time if it's a person.

    // Logic:
    // 1. Calculate typing time based on length
    // 2. Add some randomness based on content hash (deterministic)

    if (sender == 'system' || sender == 'nadia') {
      // System/Player messages happen instantly or with small gap
      return (typing: 0, gap: 500);
    }

    if (overrideDelay != null && overrideDelay > 0) {
      // Use override as the typing duration mostly, unless it's huge
      return (typing: overrideDelay, gap: 500);
    }

    final int len = content.length;
    int typing = minTypingMs + (len * perCharMs);

    // Image? Takes longer to "select" and upload
    if (type == 'image') {
      typing = 3000;
    }

    // Clamp
    if (typing > maxTypingMs) typing = maxTypingMs;

    // Add deterministic jitter
    final seed = content.hashCode;
    final random = Random(seed);
    final jitter = random.nextInt(600) - 300; // +/- 300ms
    typing += jitter;

    if (typing < minTypingMs) typing = minTypingMs;

    return (typing: typing, gap: baseGapMs);
  }
}
