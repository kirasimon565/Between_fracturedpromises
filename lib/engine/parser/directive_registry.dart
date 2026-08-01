/// Declarative description of every directive the language understands.
///
/// The registry is the single extension point of the parser: adding a new
/// command means registering a [DirectiveSpec] here (or at runtime, from a
/// plugin) plus a handler in `engine/commands/`. Nothing else changes.
library;

/// Broad grouping used for documentation, debug tooling and the script linter.
enum DirectiveCategory {
  control,
  metadata,
  messaging,
  choice,
  variables,
  flags,
  relationships,
  inventory,
  evidence,
  journal,
  objectives,
  media,
  audio,
  phone,
  calls,
  browser,
  animation,
  environment,
  random,
  events,
  achievements,
  gallery,
  ui,
  premium,
  network,
  debug,
  plugins,
}

/// How the parser should treat the directive.
enum DirectiveShape {
  /// A normal one-line command handled by a [CommandHandler].
  simple,

  /// Parsed by dedicated parser code (`@if`, `@choice`, `@while`, …).
  structural,

  /// Closes a structural block (`@endif`, `@endchoice`, …).
  terminator,
}

class DirectiveSpec {
  const DirectiveSpec(
    this.name, {
    required this.category,
    this.shape = DirectiveShape.simple,
    this.aliases = const <String>[],
    this.named = const <String>{},
    this.minPositional = 0,
    this.summary = '',
  });

  final String name;
  final DirectiveCategory category;
  final DirectiveShape shape;
  final List<String> aliases;

  /// Keywords that introduce a named argument for this directive.
  final Set<String> named;

  final int minPositional;
  final String summary;
}

/// Mutable lookup table. A single instance is shared by the parser, the
/// executor and the debug overlay.
class DirectiveRegistry {
  DirectiveRegistry({bool withBuiltins = true}) {
    if (withBuiltins) {
      for (final DirectiveSpec spec in builtinDirectives) {
        register(spec);
      }
    }
  }

  final Map<String, DirectiveSpec> _byName = <String, DirectiveSpec>{};

  static final DirectiveRegistry shared = DirectiveRegistry();

  Iterable<DirectiveSpec> get all =>
      _byName.values.toSet().toList()
        ..sort((DirectiveSpec a, DirectiveSpec b) => a.name.compareTo(b.name));

  void register(DirectiveSpec spec) {
    _byName[spec.name.toLowerCase()] = spec;
    for (final String alias in spec.aliases) {
      _byName[alias.toLowerCase()] = spec;
    }
  }

  DirectiveSpec? lookup(String name) => _byName[name.toLowerCase()];

  bool isKnown(String name) => _byName.containsKey(name.toLowerCase());

  /// Canonical name for an alias (`@msg` → `message`).
  String canonical(String name) =>
      _byName[name.toLowerCase()]?.name ?? name.toLowerCase();

  bool isNamedParameter(String directive, String key) {
    final DirectiveSpec? spec = lookup(directive);
    final String k = key.toLowerCase();
    if (spec != null) return spec.named.contains(k);
    return genericModifiers.contains(k);
  }

  /// Modifier keywords accepted by *unknown* directives so third-party
  /// commands still get named-argument parsing for free.
  static const Set<String> genericModifiers = <String>{
    'volume',
    'loop',
    'fade',
    'duration',
    'delay',
    'speed',
    'status',
    'at',
    'to',
    'from',
    'with',
    'as',
    'style',
    'color',
    'icon',
    'sound',
    'priority',
    'timeout',
    'default',
    'count',
    'id',
    'title',
    'group',
    'cost',
    'requires',
    'mode',
    'position',
    'target',
    'tag',
    'url',
    'page',
    'app',
    'text',
    'body',
    'image',
    'kind',
    'type',
    'value',
    'min',
    'max',
    'seconds',
    'ms',
    'curve',
    'align',
    'size',
    'weight',
    'when',
    'unless',
    'label',
    'note',
    'category',
    'avatar',
    'subtitle',
  };
}

/// Every directive shipped with the engine.
const List<DirectiveSpec> builtinDirectives = <DirectiveSpec>[
  // ── Control flow ────────────────────────────────────────────────────────
  DirectiveSpec(
    'label',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
    summary: 'Declares a label (same as `:: name`).',
  ),
  DirectiveSpec(
    'goto',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
    aliases: <String>['jump', 'next'],
    summary: 'Unconditional jump to a label.',
  ),
  DirectiveSpec(
    'call',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
    aliases: <String>['gosub'],
    summary: 'Jumps to a label and pushes a return address.',
  ),
  DirectiveSpec(
    'return',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
    summary: 'Returns from the innermost @call.',
  ),
  DirectiveSpec(
    'include',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
    summary: 'Inlines another script file at compile time.',
  ),
  DirectiveSpec(
    'end',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
    aliases: <String>['halt', 'stop'],
    summary: 'Ends the episode (or closes the current block).',
  ),
  DirectiveSpec(
    'if',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'elseif',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
    aliases: <String>['elif'],
  ),
  DirectiveSpec(
    'else',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'endif',
    category: DirectiveCategory.control,
    shape: DirectiveShape.terminator,
    aliases: <String>['fi'],
  ),
  DirectiveSpec(
    'switch',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'case',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'default',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'endswitch',
    category: DirectiveCategory.control,
    shape: DirectiveShape.terminator,
  ),
  DirectiveSpec(
    'while',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'endwhile',
    category: DirectiveCategory.control,
    shape: DirectiveShape.terminator,
  ),
  DirectiveSpec(
    'repeat',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'endrepeat',
    category: DirectiveCategory.control,
    shape: DirectiveShape.terminator,
  ),
  DirectiveSpec(
    'for',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'endfor',
    category: DirectiveCategory.control,
    shape: DirectiveShape.terminator,
  ),
  DirectiveSpec(
    'break',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'continue',
    category: DirectiveCategory.control,
    shape: DirectiveShape.structural,
  ),

  // ── Metadata ────────────────────────────────────────────────────────────
  DirectiveSpec('title', category: DirectiveCategory.metadata),
  DirectiveSpec('episode', category: DirectiveCategory.metadata),
  DirectiveSpec('chapter', category: DirectiveCategory.metadata),
  DirectiveSpec('author', category: DirectiveCategory.metadata),
  DirectiveSpec('difficulty', category: DirectiveCategory.metadata),
  DirectiveSpec('version', category: DirectiveCategory.metadata),
  DirectiveSpec('tags', category: DirectiveCategory.metadata),
  DirectiveSpec('synopsis', category: DirectiveCategory.metadata),
  DirectiveSpec('cover', category: DirectiveCategory.metadata),
  DirectiveSpec('requires_episode', category: DirectiveCategory.metadata),
  DirectiveSpec(
    'checkpoint',
    category: DirectiveCategory.metadata,
    named: <String>{'name', 'auto'},
    summary: 'Writes an autosave checkpoint.',
  ),
  DirectiveSpec('save', category: DirectiveCategory.metadata),

  // ── Messaging ───────────────────────────────────────────────────────────
  DirectiveSpec(
    'message',
    category: DirectiveCategory.messaging,
    aliases: <String>['msg', 'say'],
    named: <String>{
      'delay',
      'app',
      'thread',
      'avatar',
      'attachment',
      'image',
      'audio',
      'sound',
      'reply',
      'status',
      'style',
      'sender',
      'time',
      'reaction',
    },
    minPositional: 1,
    summary: 'Sends a chat message from a character.',
  ),
  DirectiveSpec(
    'typing',
    category: DirectiveCategory.messaging,
    named: <String>{'app', 'thread', 'seconds'},
    minPositional: 1,
    summary: 'Shows the typing indicator for N seconds.',
  ),
  DirectiveSpec(
    'narration',
    category: DirectiveCategory.messaging,
    aliases: <String>['narrate', 'narrator'],
    named: <String>{'style', 'delay', 'align'},
  ),
  DirectiveSpec(
    'thought',
    category: DirectiveCategory.messaging,
    aliases: <String>['think'],
    named: <String>{'delay', 'style'},
  ),
  DirectiveSpec(
    'system',
    category: DirectiveCategory.messaging,
    named: <String>{'style'},
  ),
  DirectiveSpec(
    'seen',
    category: DirectiveCategory.messaging,
    named: <String>{'thread', 'at'},
  ),
  DirectiveSpec(
    'unsend',
    category: DirectiveCategory.messaging,
    named: <String>{'thread'},
  ),
  DirectiveSpec(
    'reaction',
    category: DirectiveCategory.messaging,
    named: <String>{'thread', 'emoji'},
  ),
  DirectiveSpec(
    'clear_chat',
    category: DirectiveCategory.messaging,
    named: <String>{'thread', 'app'},
  ),
  DirectiveSpec(
    'thread',
    category: DirectiveCategory.messaging,
    named: <String>{'app', 'title', 'avatar', 'pinned', 'muted'},
    summary: 'Opens/creates a conversation thread.',
  ),
  DirectiveSpec(
    'character',
    category: DirectiveCategory.messaging,
    named: <String>{'status', 'avatar', 'name', 'app', 'about', 'phone'},
    summary: 'Declares or updates a character.',
  ),
  DirectiveSpec(
    'delay',
    category: DirectiveCategory.messaging,
    aliases: <String>['wait', 'pause_for'],
    named: <String>{'seconds', 'ms'},
    summary: 'Suspends execution for N seconds of story time.',
  ),

  // ── Choices ─────────────────────────────────────────────────────────────
  DirectiveSpec(
    'choice',
    category: DirectiveCategory.choice,
    shape: DirectiveShape.structural,
    named: <String>{'timeout', 'default', 'prompt', 'style', 'shuffle'},
  ),
  DirectiveSpec(
    'endchoice',
    category: DirectiveCategory.choice,
    shape: DirectiveShape.terminator,
  ),

  // ── Variables & flags ───────────────────────────────────────────────────
  DirectiveSpec(
    'set',
    category: DirectiveCategory.variables,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'add',
    category: DirectiveCategory.variables,
    shape: DirectiveShape.structural,
  ),
  DirectiveSpec(
    'subtract',
    category: DirectiveCategory.variables,
    shape: DirectiveShape.structural,
    aliases: <String>['sub'],
  ),
  DirectiveSpec(
    'unset_var',
    category: DirectiveCategory.variables,
    aliases: <String>['delete_var'],
  ),
  DirectiveSpec(
    'flag',
    category: DirectiveCategory.flags,
    minPositional: 1,
    summary: 'Sets a boolean story flag.',
  ),
  DirectiveSpec(
    'unset',
    category: DirectiveCategory.flags,
    aliases: <String>['unflag', 'clear_flag'],
    minPositional: 1,
  ),
  DirectiveSpec('toggle', category: DirectiveCategory.flags),

  // ── Relationships ───────────────────────────────────────────────────────
  DirectiveSpec(
    'trust',
    category: DirectiveCategory.relationships,
    named: <String>{'min', 'max', 'silent'},
    minPositional: 1,
  ),
  DirectiveSpec(
    'friendship',
    category: DirectiveCategory.relationships,
    named: <String>{'min', 'max', 'silent'},
    minPositional: 1,
  ),
  DirectiveSpec(
    'love',
    category: DirectiveCategory.relationships,
    named: <String>{'min', 'max', 'silent'},
    minPositional: 1,
  ),
  DirectiveSpec(
    'tension',
    category: DirectiveCategory.relationships,
    minPositional: 1,
  ),
  DirectiveSpec(
    'suspicion',
    category: DirectiveCategory.relationships,
    minPositional: 1,
  ),
  DirectiveSpec(
    'relationship',
    category: DirectiveCategory.relationships,
    named: <String>{'trust', 'friendship', 'love', 'tension', 'suspicion'},
  ),

  // ── Inventory / evidence / journal / objectives ────────────────────────
  DirectiveSpec(
    'item',
    category: DirectiveCategory.inventory,
    aliases: <String>['give', 'add_item'],
    named: <String>{'title', 'count', 'icon', 'description', 'category'},
  ),
  DirectiveSpec(
    'remove_item',
    category: DirectiveCategory.inventory,
    aliases: <String>['take'],
    named: <String>{'count'},
  ),
  DirectiveSpec(
    'inventory',
    category: DirectiveCategory.inventory,
    named: <String>{'mode'},
  ),
  DirectiveSpec(
    'evidence',
    category: DirectiveCategory.evidence,
    named: <String>{'title', 'description', 'image', 'source', 'category'},
    summary: 'Unlocks a piece of evidence.',
  ),
  DirectiveSpec(
    'evidence_link',
    category: DirectiveCategory.evidence,
    named: <String>{'with', 'result'},
  ),
  DirectiveSpec(
    'journal',
    category: DirectiveCategory.journal,
    named: <String>{'title', 'body', 'category', 'mood', 'image'},
  ),
  DirectiveSpec(
    'journal_update',
    category: DirectiveCategory.journal,
    named: <String>{'body'},
  ),
  DirectiveSpec(
    'objective',
    category: DirectiveCategory.objectives,
    named: <String>{'title', 'description', 'optional', 'group'},
  ),
  DirectiveSpec(
    'objective_complete',
    category: DirectiveCategory.objectives,
    aliases: <String>['complete'],
  ),
  DirectiveSpec('objective_fail', category: DirectiveCategory.objectives),

  // ── Media / images ──────────────────────────────────────────────────────
  DirectiveSpec(
    'image',
    category: DirectiveCategory.media,
    aliases: <String>['show_image', 'photo'],
    named: <String>{'fade', 'duration', 'align', 'caption', 'blur', 'style'},
  ),
  DirectiveSpec('hide_image', category: DirectiveCategory.media),
  DirectiveSpec(
    'background',
    category: DirectiveCategory.media,
    aliases: <String>['bg'],
    named: <String>{'fade', 'blur', 'tint'},
  ),
  DirectiveSpec(
    'video',
    category: DirectiveCategory.media,
    named: <String>{'loop', 'mute'},
  ),
  DirectiveSpec(
    'gallery_unlock',
    category: DirectiveCategory.gallery,
    aliases: <String>['unlock_gallery'],
    named: <String>{'title', 'category', 'image', 'nsfw'},
  ),

  // ── Audio ───────────────────────────────────────────────────────────────
  DirectiveSpec(
    'music',
    category: DirectiveCategory.audio,
    named: <String>{'volume', 'loop', 'fade', 'from'},
  ),
  DirectiveSpec(
    'stop_music',
    category: DirectiveCategory.audio,
    named: <String>{'fade'},
  ),
  DirectiveSpec(
    'sound',
    category: DirectiveCategory.audio,
    aliases: <String>['sfx', 'play'],
    named: <String>{'volume', 'delay'},
  ),
  DirectiveSpec(
    'ambience',
    category: DirectiveCategory.audio,
    named: <String>{'volume', 'fade'},
  ),
  DirectiveSpec(
    'vibrate',
    category: DirectiveCategory.audio,
    named: <String>{'duration', 'pattern'},
  ),
  DirectiveSpec('mute', category: DirectiveCategory.audio),
  DirectiveSpec('unmute', category: DirectiveCategory.audio),

  // ── Phone OS ────────────────────────────────────────────────────────────
  DirectiveSpec(
    'phone',
    category: DirectiveCategory.phone,
    named: <String>{'mode', 'theme'},
  ),
  DirectiveSpec(
    'phone_battery',
    category: DirectiveCategory.phone,
    aliases: <String>['battery'],
  ),
  DirectiveSpec('phone_signal', category: DirectiveCategory.phone),
  DirectiveSpec('phone_lock', category: DirectiveCategory.phone),
  DirectiveSpec('phone_unlock', category: DirectiveCategory.phone),
  DirectiveSpec(
    'open_app',
    category: DirectiveCategory.phone,
    aliases: <String>['app_open'],
    named: <String>{'screen', 'thread', 'args'},
  ),
  DirectiveSpec(
    'close_app',
    category: DirectiveCategory.phone,
    aliases: <String>['app_close'],
  ),
  DirectiveSpec(
    'install_app',
    category: DirectiveCategory.phone,
    aliases: <String>['app_install'],
    named: <String>{'app', 'name', 'icon', 'progress', 'source', 'duration'},
  ),
  DirectiveSpec(
    'uninstall_app',
    category: DirectiveCategory.phone,
    aliases: <String>['app_uninstall'],
  ),
  DirectiveSpec(
    'notification',
    category: DirectiveCategory.phone,
    aliases: <String>['notify'],
    named: <String>{'app', 'title', 'icon', 'sound', 'sticky', 'thread'},
  ),
  DirectiveSpec('clear_notifications', category: DirectiveCategory.phone),
  DirectiveSpec(
    'contact',
    category: DirectiveCategory.phone,
    named: <String>{'number', 'avatar', 'note', 'blocked', 'favorite'},
  ),
  DirectiveSpec('wallpaper', category: DirectiveCategory.phone),
  DirectiveSpec(
    'badge',
    category: DirectiveCategory.phone,
    named: <String>{'app', 'count'},
  ),

  // ── Calls ───────────────────────────────────────────────────────────────
  DirectiveSpec(
    'call_incoming',
    category: DirectiveCategory.calls,
    named: <String>{'ringtone', 'timeout', 'video', 'accept', 'decline'},
  ),
  DirectiveSpec(
    'call_start',
    category: DirectiveCategory.calls,
    named: <String>{'video'},
  ),
  DirectiveSpec(
    'call_line',
    category: DirectiveCategory.calls,
    named: <String>{'delay'},
  ),
  DirectiveSpec('call_end', category: DirectiveCategory.calls),
  DirectiveSpec(
    'voicemail',
    category: DirectiveCategory.calls,
    named: <String>{'duration'},
  ),
  DirectiveSpec('missed_call', category: DirectiveCategory.calls),

  // ── Browser ─────────────────────────────────────────────────────────────
  DirectiveSpec(
    'browser_open',
    category: DirectiveCategory.browser,
    named: <String>{'tab', 'incognito', 'title'},
  ),
  DirectiveSpec(
    'browser_visit',
    category: DirectiveCategory.browser,
    named: <String>{'title', 'delay', 'tab'},
  ),
  DirectiveSpec(
    'browser_popup',
    category: DirectiveCategory.browser,
    named: <String>{'title', 'body', 'image', 'cta', 'target', 'closable'},
  ),
  DirectiveSpec(
    'browser_download',
    category: DirectiveCategory.browser,
    named: <String>{'app', 'name', 'icon', 'duration', 'size'},
  ),
  DirectiveSpec('browser_close', category: DirectiveCategory.browser),
  DirectiveSpec(
    'browser_bookmark',
    category: DirectiveCategory.browser,
    named: <String>{'title'},
  ),
  DirectiveSpec('browser_history_clear', category: DirectiveCategory.browser),
  DirectiveSpec(
    'browser_redirect',
    category: DirectiveCategory.browser,
    named: <String>{'delay'},
  ),
  DirectiveSpec(
    'browser_tab',
    category: DirectiveCategory.browser,
    named: <String>{'close', 'focus'},
  ),

  // ── Animation ───────────────────────────────────────────────────────────
  DirectiveSpec(
    'animate',
    category: DirectiveCategory.animation,
    named: <String>{'target', 'duration', 'curve', 'delay', 'value'},
  ),
  DirectiveSpec(
    'shake',
    category: DirectiveCategory.animation,
    named: <String>{'duration', 'intensity'},
  ),
  DirectiveSpec(
    'flash',
    category: DirectiveCategory.animation,
    named: <String>{'color', 'duration'},
  ),
  DirectiveSpec(
    'glitch',
    category: DirectiveCategory.animation,
    named: <String>{'duration', 'intensity'},
  ),
  DirectiveSpec(
    'fade',
    category: DirectiveCategory.animation,
    named: <String>{'duration', 'color', 'to'},
  ),
  DirectiveSpec(
    'shatter',
    category: DirectiveCategory.animation,
    named: <String>{'duration'},
  ),

  // ── Environment ─────────────────────────────────────────────────────────
  DirectiveSpec(
    'scene',
    category: DirectiveCategory.environment,
    named: <String>{'app', 'background', 'music', 'theme'},
  ),
  DirectiveSpec(
    'time',
    category: DirectiveCategory.environment,
    aliases: <String>['clock'],
  ),
  DirectiveSpec('date', category: DirectiveCategory.environment),
  DirectiveSpec('location', category: DirectiveCategory.environment),
  DirectiveSpec('weather', category: DirectiveCategory.environment),
  DirectiveSpec(
    'theme',
    category: DirectiveCategory.environment,
    named: <String>{'mode'},
  ),
  DirectiveSpec(
    'advance_time',
    category: DirectiveCategory.environment,
    named: <String>{'minutes', 'hours'},
  ),

  // ── Random ──────────────────────────────────────────────────────────────
  DirectiveSpec(
    'random',
    category: DirectiveCategory.random,
    named: <String>{'min', 'max', 'into'},
    summary: 'Stores a random number in a variable.',
  ),
  DirectiveSpec(
    'random_pick',
    category: DirectiveCategory.random,
    named: <String>{'into'},
  ),
  DirectiveSpec(
    'chance',
    category: DirectiveCategory.random,
    shape: DirectiveShape.structural,
    summary: 'Branches with a probability (0-100).',
  ),
  DirectiveSpec('seed', category: DirectiveCategory.random),

  // ── Events / scheduler ──────────────────────────────────────────────────
  DirectiveSpec(
    'emit',
    category: DirectiveCategory.events,
    named: <String>{'data', 'delay'},
  ),
  DirectiveSpec(
    'on',
    category: DirectiveCategory.events,
    shape: DirectiveShape.structural,
    named: <String>{'once'},
  ),
  DirectiveSpec(
    'endon',
    category: DirectiveCategory.events,
    shape: DirectiveShape.terminator,
  ),
  DirectiveSpec(
    'schedule',
    category: DirectiveCategory.events,
    named: <String>{'in', 'at', 'repeat', 'id'},
    summary: 'Runs a label later, in the background.',
  ),
  DirectiveSpec('cancel_schedule', category: DirectiveCategory.events),
  DirectiveSpec(
    'timer',
    category: DirectiveCategory.events,
    named: <String>{'seconds', 'id', 'label', 'visible'},
  ),
  DirectiveSpec(
    'await',
    category: DirectiveCategory.events,
    named: <String>{'timeout'},
    summary: 'Suspends until an event fires.',
  ),
  DirectiveSpec(
    'async',
    category: DirectiveCategory.events,
    summary: 'Runs a label on a parallel fiber.',
  ),
  DirectiveSpec('pause_engine', category: DirectiveCategory.events),
  DirectiveSpec('resume_engine', category: DirectiveCategory.events),

  // ── Achievements ────────────────────────────────────────────────────────
  DirectiveSpec(
    'achievement',
    category: DirectiveCategory.achievements,
    aliases: <String>['unlock_achievement'],
    named: <String>{'title', 'description', 'icon', 'hidden', 'points'},
  ),
  DirectiveSpec(
    'achievement_progress',
    category: DirectiveCategory.achievements,
    named: <String>{'value', 'goal'},
  ),

  // ── UI ──────────────────────────────────────────────────────────────────
  DirectiveSpec(
    'ui',
    category: DirectiveCategory.ui,
    named: <String>{'mode', 'value'},
  ),
  DirectiveSpec(
    'toast',
    category: DirectiveCategory.ui,
    named: <String>{'duration', 'icon'},
  ),
  DirectiveSpec(
    'banner',
    category: DirectiveCategory.ui,
    named: <String>{'duration', 'style'},
  ),
  DirectiveSpec(
    'overlay',
    category: DirectiveCategory.ui,
    named: <String>{'opacity', 'color'},
  ),
  DirectiveSpec(
    'screen',
    category: DirectiveCategory.ui,
    named: <String>{'args'},
  ),
  DirectiveSpec(
    'dialog',
    category: DirectiveCategory.ui,
    named: <String>{'title', 'body', 'confirm', 'cancel'},
  ),
  DirectiveSpec(
    'hud',
    category: DirectiveCategory.ui,
    named: <String>{'show', 'hide'},
  ),
  DirectiveSpec(
    'title_card',
    category: DirectiveCategory.ui,
    named: <String>{'subtitle', 'duration', 'style'},
  ),
  DirectiveSpec('credits', category: DirectiveCategory.ui),

  // ── Premium (crystals) ──────────────────────────────────────────────────
  DirectiveSpec(
    'crystals',
    category: DirectiveCategory.premium,
    named: <String>{'reason', 'silent'},
    summary: 'Grants or spends crystals.',
  ),
  DirectiveSpec(
    'require_crystals',
    category: DirectiveCategory.premium,
    named: <String>{'else'},
  ),
  DirectiveSpec(
    'open_store',
    category: DirectiveCategory.premium,
    named: <String>{'sku', 'reason'},
  ),
  DirectiveSpec(
    'premium_unlock',
    category: DirectiveCategory.premium,
    named: <String>{'cost', 'title', 'else'},
  ),

  // ── Network (simulated, offline) ────────────────────────────────────────
  DirectiveSpec(
    'network',
    category: DirectiveCategory.network,
    named: <String>{'state', 'latency', 'strength'},
  ),
  DirectiveSpec('airplane_mode', category: DirectiveCategory.network),
  DirectiveSpec(
    'wifi',
    category: DirectiveCategory.network,
    named: <String>{'ssid', 'strength'},
  ),
  DirectiveSpec('sync_fail', category: DirectiveCategory.network),

  // ── Debug ───────────────────────────────────────────────────────────────
  DirectiveSpec(
    'debug',
    category: DirectiveCategory.debug,
    named: <String>{'level'},
  ),
  DirectiveSpec('log', category: DirectiveCategory.debug),
  DirectiveSpec(
    'assert',
    category: DirectiveCategory.debug,
    named: <String>{'message'},
  ),
  DirectiveSpec('breakpoint', category: DirectiveCategory.debug),
  DirectiveSpec('trace', category: DirectiveCategory.debug),

  // ── Plugins ─────────────────────────────────────────────────────────────
  DirectiveSpec(
    'plugin',
    category: DirectiveCategory.plugins,
    named: <String>{'action', 'args'},
    summary: 'Forwards a command to a registered plugin.',
  ),
  DirectiveSpec(
    'use',
    category: DirectiveCategory.plugins,
    summary: 'Declares a plugin dependency for the script.',
  ),
];
