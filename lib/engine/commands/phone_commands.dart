import '../engine_defaults.dart';
import '../events/engine_event.dart';
import '../runtime/engine_effect.dart';
import '../state/chat.dart';
import '../state/phone.dart';
import 'command.dart';
import 'command_helpers.dart';

/// Phone OS surface: apps, notifications, status bar, contacts.
List<CommandHandler> phoneCommands() => <CommandHandler>[
  const FunctionCommand(<String>['phone'], _phone),
  const FunctionCommand(<String>['phone_battery', 'battery'], _battery),
  const FunctionCommand(<String>['phone_signal'], _signal),
  const FunctionCommand(<String>['phone_lock'], _lock),
  const FunctionCommand(<String>['phone_unlock'], _unlock),
  const FunctionCommand(<String>['open_app', 'app_open'], _openApp),
  const FunctionCommand(<String>['close_app', 'app_close'], _closeApp),
  const FunctionCommand(<String>[
    'install_app',
    'app_install',
  ], installAppCommand),
  const FunctionCommand(<String>[
    'uninstall_app',
    'app_uninstall',
  ], _uninstallApp),
  const FunctionCommand(<String>['notification', 'notify'], _notification),
  const FunctionCommand(<String>['clear_notifications'], _clearNotifications),
  const FunctionCommand(<String>['contact'], _contact),
  const FunctionCommand(<String>['wallpaper'], _wallpaper),
  const FunctionCommand(<String>['badge'], _badge),
];

CommandOutcome _phone(CommandContext ctx) {
  final String mode = ctx.str(0, ctx.namedStr('mode')).toLowerCase();
  switch (mode) {
    case 'lock':
      return _lock(ctx);
    case 'unlock':
      return _unlock(ctx);
    case 'home':
      ctx.engine.state.updatePhone(
        (PhoneState p) => p.copyWith(currentApp: null, currentScreen: null),
      );
      ctx.engine.emitEffect(const NavigateEffect('/phone'));
      return CommandOutcome.next;
    case 'silent':
      ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(silent: true));
      return CommandOutcome.next;
  }
  final String? theme = ctx.namedStrOrNull('theme');
  if (theme != null) {
    ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(theme: theme));
  }
  return CommandOutcome.next;
}

CommandOutcome _battery(CommandContext ctx) {
  final int level = ctx.integer(0, ctx.engine.state.phone.battery);
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(battery: level.clamp(0, 100)),
  );
  return CommandOutcome.next;
}

CommandOutcome _signal(CommandContext ctx) {
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(signal: ctx.integer(0, 4).clamp(0, 4)),
  );
  return CommandOutcome.next;
}

CommandOutcome _lock(CommandContext ctx) {
  ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(locked: true));
  ctx.engine.emitEffect(const NavigateEffect('/phone/lock'));
  return CommandOutcome.next;
}

CommandOutcome _unlock(CommandContext ctx) {
  ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(locked: false));
  ctx.engine.emitEffect(const NavigateEffect('/phone'));
  return CommandOutcome.next;
}

CommandOutcome _openApp(CommandContext ctx) {
  final String appId = ctx.id(0);
  if (appId.isEmpty) return CommandOutcome.next;
  final String? screen = ctx.namedStrOrNull('screen');
  final String? thread = ctx.namedStrOrNull('thread');
  if (thread != null) ctx.engine.state.activeThreadId = thread.toLowerCase();

  ctx.engine.state.updatePhone(
    (PhoneState p) =>
        p.copyWith(currentApp: appId, currentScreen: screen, locked: false),
  );
  ctx.engine.emitEffect(
    OpenAppEffect(
      appId,
      screen: screen,
      arguments: thread == null
          ? const <String, Object?>{}
          : <String, Object?>{'thread': thread},
    ),
  );
  ctx.engine.emitEvent(
    EngineEvents.appOpened,
    data: <String, Object?>{'app': appId},
  );
  return CommandOutcome.next;
}

CommandOutcome _closeApp(CommandContext ctx) {
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(currentApp: null, currentScreen: null),
  );
  ctx.engine.emitEffect(const NavigateEffect('/phone'));
  return CommandOutcome.next;
}

/// Shared by `@install_app` and `@browser_download`.
CommandOutcome installAppCommand(CommandContext ctx) {
  final String appId = ctx.id(0, ctx.namedStr('app'));
  if (appId.isEmpty) return CommandOutcome.next;

  final String name = ctx.namedStr('name', ctx.str(1, _pretty(appId)));
  final String? icon = ctx.namedStrOrNull('icon');
  final Duration duration = ctx.namedDuration(
    'duration',
    const Duration(milliseconds: 2200),
  );

  if (ctx.engine.state.phone.hasApp(appId)) return CommandOutcome.next;

  ctx.engine.state.installApp(
    InstalledApp(
      id: appId,
      name: name,
      icon: icon,
      installedAt: ctx.engine.clock.now(),
      source: ctx.namedStr('source', 'browser'),
    ),
  );
  ctx.engine.state.setFlag('installed_$appId');
  ctx.engine.emitEffect(
    AppInstallEffect(
      appId: appId,
      name: name,
      icon: icon,
      duration: duration,
      source: ctx.namedStr('source', 'browser'),
    ),
  );
  ctx.engine.emitEvent(
    EngineEvents.appInstalled,
    data: <String, Object?>{'app': appId},
  );
  return CommandOutcome.wait(ctx.engine.pace(duration));
}

CommandOutcome _uninstallApp(CommandContext ctx) {
  final String appId = ctx.id(0);
  if (appId.isEmpty) return CommandOutcome.next;
  ctx.engine.state.uninstallApp(appId);
  ctx.engine.state.setFlag('installed_$appId', value: false);
  return CommandOutcome.next;
}

CommandOutcome _notification(CommandContext ctx) {
  final String body = ctx.str(0);
  if (body.isEmpty) return CommandOutcome.next;

  final String appId = ctx.namedStr('app', ctx.currentApp);
  final GameNotification notification = GameNotification(
    id: ctx.uid('n'),
    appId: appId,
    title: ctx.namedStr('title', _appTitle(appId)),
    body: body,
    timestamp: ctx.engine.clock.now(),
    icon: ctx.namedStrOrNull('icon'),
    threadId: ctx.namedStrOrNull('thread'),
    sticky: ctx.namedBool('sticky'),
    sound: ctx.namedStrOrNull('sound'),
  );
  ctx.engine.state.pushNotification(notification);
  ctx.engine.emitEffect(
    PlaySoundEffect(notification.sound ?? 'msg_ping', volume: 0.8),
  );
  if (!ctx.engine.state.phone.silent) {
    ctx.engine.emitEffect(const VibrateEffect(milliseconds: 90));
  }
  ctx.engine.emitEvent(
    EngineEvents.notificationPosted,
    data: <String, Object?>{'app': appId, 'body': body},
  );
  return CommandOutcome.wait(
    ctx.engine.pace(EngineDefaults.defaultNotificationDwell),
  );
}

CommandOutcome _clearNotifications(CommandContext ctx) {
  ctx.engine.state.clearNotifications(appId: ctx.count > 0 ? ctx.id(0) : null);
  return CommandOutcome.next;
}

CommandOutcome _contact(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  ctx.engine.state.ensureCharacter(id, name: ctx.str(1, _pretty(id)));
  ctx.engine.state.updateCharacter(
    id,
    (CharacterState c) => c.copyWith(
      name: ctx.count > 1 ? ctx.str(1) : null,
      phone: ctx.namedStrOrNull('number'),
      avatar: ctx.namedStrOrNull('avatar'),
      about: ctx.namedStrOrNull('note'),
      blocked: ctx.namedBool('blocked', c.blocked),
      favorite: ctx.namedBool('favorite', c.favorite),
    ),
  );
  return CommandOutcome.next;
}

CommandOutcome _wallpaper(CommandContext ctx) {
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(wallpaper: ctx.str(0)),
  );
  return CommandOutcome.next;
}

CommandOutcome _badge(CommandContext ctx) {
  final String appId = ctx.namedStr('app', ctx.id(0));
  final int count = ctx.namedInt('count', ctx.integer(1, 0));
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(
      apps: p.apps
          .map((InstalledApp a) => a.id == appId ? a.copyWith(badge: count) : a)
          .toList(),
    ),
  );
  return CommandOutcome.next;
}

String _appTitle(String appId) {
  switch (appId) {
    case 'messenger':
      return 'Messenger';
    case 'makelove':
      return 'Makelove';
    case 'browser':
      return 'Browser';
    case 'calls':
      return 'Phone';
    default:
      return _pretty(appId);
  }
}

String _pretty(String id) => id
    .split(RegExp(r'[_\s]+'))
    .where((String part) => part.isNotEmpty)
    .map((String part) => part[0].toUpperCase() + part.substring(1))
    .join(' ');
