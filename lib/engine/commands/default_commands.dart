import 'browser_commands.dart';
import 'call_commands.dart';
import 'command.dart';
import 'environment_commands.dart';
import 'event_commands.dart';
import 'media_commands.dart';
import 'messaging_commands.dart';
import 'meta_commands.dart';
import 'phone_commands.dart';
import 'premium_commands.dart';
import 'progress_commands.dart';
import 'ui_commands.dart';
import 'variable_commands.dart';

/// Every command family shipped with the engine.
///
/// A plugin adds behaviour by registering extra handlers *after* this call —
/// nothing in the interpreter has to change.
List<CommandHandler> builtinCommands() => <CommandHandler>[
      ...messagingCommands(),
      ...variableCommands(),
      ...relationshipCommands(),
      ...progressCommands(),
      ...mediaCommands(),
      ...phoneCommands(),
      ...browserCommands(),
      ...environmentCommands(),
      ...uiCommands(),
      ...animationCommands(),
      ...eventCommands(),
      ...premiumCommands(),
      ...callCommands(),
      ...metaCommands(),
    ];

/// Builds the registry used by a fresh runtime.
///
/// [plugins] is the officially supported extension point: pass extra handlers
/// (or override built-ins by re-using their names) without touching the engine.
CommandRegistry createCommandRegistry({
  Iterable<CommandHandler> plugins = const <CommandHandler>[],
}) {
  final CommandRegistry registry = CommandRegistry();
  registry.registerAll(builtinCommands());
  registry.registerAll(plugins);
  return registry;
}
