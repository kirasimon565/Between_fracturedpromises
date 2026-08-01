import '../events/engine_event.dart';
import '../runtime/engine_effect.dart';
import '../state/progress.dart';
import 'command.dart';
import 'command_helpers.dart';

/// Inventory, evidence, journal, objectives, achievements and gallery.
List<CommandHandler> progressCommands() => <CommandHandler>[
      const FunctionCommand(<String>['item', 'give', 'add_item'], _addItem),
      const FunctionCommand(<String>['remove_item', 'take'], _removeItem),
      const FunctionCommand(<String>['inventory'], _inventory),
      const FunctionCommand(<String>['evidence'], _evidence),
      const FunctionCommand(<String>['evidence_link'], _evidenceLink),
      const FunctionCommand(<String>['journal'], _journal),
      const FunctionCommand(<String>['journal_update'], _journalUpdate),
      const FunctionCommand(<String>['objective'], _objective),
      const FunctionCommand(
          <String>['objective_complete', 'complete'], _objectiveComplete),
      const FunctionCommand(<String>['objective_fail'], _objectiveFail),
      const FunctionCommand(
          <String>['achievement', 'unlock_achievement'], _achievement),
      const FunctionCommand(
          <String>['achievement_progress'], _achievementProgress),
      const FunctionCommand(
          <String>['gallery_unlock', 'unlock_gallery'], _galleryUnlock),
    ];

CommandOutcome _addItem(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  ctx.engine.state.addItem(InventoryItem(
    id: id,
    name: ctx.str(1, ctx.namedStr('title', _pretty(id))),
    count: ctx.namedInt('count', 1),
    icon: ctx.namedStrOrNull('icon'),
    description: ctx.namedStrOrNull('description'),
    category: ctx.namedStr('category', 'general'),
  ));
  ctx.engine.emitEffect(ToastEffect('Added ${_pretty(id)}', icon: 'inventory'));
  return CommandOutcome.next;
}

CommandOutcome _removeItem(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  ctx.engine.state.removeItem(id, count: ctx.namedInt('count', 1));
  return CommandOutcome.next;
}

CommandOutcome _inventory(CommandContext ctx) {
  ctx.engine.emitEffect(const OpenAppEffect('files', screen: 'inventory'));
  return CommandOutcome.next;
}

CommandOutcome _evidence(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  ctx.engine.state.addEvidence(EvidenceEntry(
    id: id,
    title: ctx.namedStr('title', ctx.str(1, _pretty(id))),
    description: ctx.namedStr('description'),
    image: ctx.namedStrOrNull('image'),
    source: ctx.namedStrOrNull('source'),
    category: ctx.namedStr('category', 'general'),
    discoveredAt: ctx.engine.clock.now(),
  ));
  ctx.engine.emitEffect(const ToastEffect('New evidence', icon: 'evidence'));
  return CommandOutcome.next;
}

CommandOutcome _evidenceLink(CommandContext ctx) {
  final String a = ctx.id(0);
  final String b = ctx.namedStr('with', ctx.id(1));
  if (a.isEmpty || b.isEmpty) return CommandOutcome.next;
  ctx.engine.state.linkEvidence(a, b);
  ctx.engine.state.linkEvidence(b, a);
  final String? result = ctx.namedStrOrNull('result');
  if (result != null) ctx.engine.state.setFlag(result);
  return CommandOutcome.next;
}

CommandOutcome _journal(CommandContext ctx) {
  final String id = ctx.id(0, ctx.uid('journal'));
  ctx.engine.state.addJournalEntry(JournalEntry(
    id: id,
    title: ctx.namedStr('title', ctx.str(1, _pretty(id))),
    body: ctx.namedStr('body', ctx.str(2)),
    createdAt: ctx.engine.clock.now(),
    category: ctx.namedStr('category', 'story'),
    mood: ctx.namedStrOrNull('mood'),
    image: ctx.namedStrOrNull('image'),
  ));
  ctx.engine.emitEffect(const ToastEffect('Journal updated', icon: 'journal'));
  return CommandOutcome.next;
}

CommandOutcome _journalUpdate(CommandContext ctx) {
  ctx.engine.state
      .updateJournalEntry(ctx.id(0), ctx.namedStr('body', ctx.str(1)));
  return CommandOutcome.next;
}

CommandOutcome _objective(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  ctx.engine.state.addObjective(Objective(
    id: id,
    title: ctx.namedStr('title', ctx.str(1, _pretty(id))),
    description: ctx.namedStr('description'),
    optional: ctx.namedBool('optional'),
    group: ctx.namedStr('group', 'main'),
    updatedAt: ctx.engine.clock.now(),
  ));
  ctx.engine.emitEffect(const ToastEffect('New objective', icon: 'objective'));
  return CommandOutcome.next;
}

CommandOutcome _objectiveComplete(CommandContext ctx) {
  ctx.engine.state.setObjectiveStatus(ctx.id(0), ObjectiveStatus.completed);
  return CommandOutcome.next;
}

CommandOutcome _objectiveFail(CommandContext ctx) {
  ctx.engine.state.setObjectiveStatus(ctx.id(0), ObjectiveStatus.failed);
  return CommandOutcome.next;
}

CommandOutcome _achievement(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  if (ctx.engine.state.hasAchievement(id)) return CommandOutcome.next;

  final Achievement achievement = Achievement(
    id: id,
    title: ctx.namedStr('title', ctx.str(1, _pretty(id))),
    description: ctx.namedStr('description'),
    icon: ctx.namedStrOrNull('icon'),
    hidden: ctx.namedBool('hidden'),
    points: ctx.namedInt('points', 10),
    unlockedAt: ctx.engine.clock.now(),
    progress: 1,
  );
  ctx.engine.state.putAchievement(achievement);
  ctx.engine.emitEffect(AchievementEffect(achievement));
  ctx.engine.emitEvent(EngineEvents.achievementUnlocked,
      data: <String, Object?>{'id': id});
  return CommandOutcome.next;
}

CommandOutcome _achievementProgress(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  final Achievement current = ctx.engine.state.achievements[id] ??
      Achievement(id: id, title: _pretty(id));
  final num value = ctx.namedNum('value', ctx.number(1, current.progress + 1));
  final num goal = ctx.namedNum('goal', current.goal);
  final bool complete = value >= goal;
  final Achievement updated = current.copyWith(
    progress: value,
    goal: goal,
    unlockedAt: complete ? ctx.engine.clock.now() : null,
  );
  ctx.engine.state.putAchievement(updated);
  if (complete && current.unlockedAt == null) {
    ctx.engine.emitEffect(AchievementEffect(updated));
    ctx.engine.emitEvent(EngineEvents.achievementUnlocked,
        data: <String, Object?>{'id': id});
  }
  return CommandOutcome.next;
}

CommandOutcome _galleryUnlock(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  if (ctx.engine.state.hasGallery(id)) return CommandOutcome.next;

  final GalleryUnlock item = GalleryUnlock(
    id: id,
    title: ctx.namedStr('title', ctx.str(1, _pretty(id))),
    image: ctx.namedStr('image', ctx.str(1)),
    category: ctx.namedStr('category', 'story'),
    nsfw: ctx.namedBool('nsfw'),
    unlockedAt: ctx.engine.clock.now(),
    episode: ctx.engine.episodeId,
  );
  ctx.engine.state.unlockGallery(item);
  ctx.engine.emitEffect(GalleryEffect(item));
  ctx.engine.emitEvent(EngineEvents.galleryUnlocked,
      data: <String, Object?>{'id': id});
  return CommandOutcome.next;
}

String _pretty(String id) => id
    .split(RegExp(r'[_\s]+'))
    .where((String part) => part.isNotEmpty)
    .map((String part) => part[0].toUpperCase() + part.substring(1))
    .join(' ');
