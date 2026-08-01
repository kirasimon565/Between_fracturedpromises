import '../engine_defaults.dart';
import '../events/engine_event.dart';
import '../runtime/engine_effect.dart';
import '../state/browser.dart';
import '../state/phone.dart';
import 'command.dart';
import 'command_helpers.dart';
import 'phone_commands.dart';

/// The offline browser: `@browser_open`, `@browser_visit`, `@browser_popup`,
/// `@browser_download`, tabs, history, bookmarks and redirects.
///
/// Episode 1 installs Makelove through these commands instead of hard-coding
/// the install in Dart.
List<CommandHandler> browserCommands() => <CommandHandler>[
  const FunctionCommand(<String>['browser_open'], _open),
  const FunctionCommand(<String>['browser_visit'], _visit),
  const FunctionCommand(<String>['browser_popup'], _popup),
  const FunctionCommand(<String>['browser_download'], _download),
  const FunctionCommand(<String>['browser_close'], _close),
  const FunctionCommand(<String>['browser_bookmark'], _bookmark),
  const FunctionCommand(<String>['browser_history_clear'], _clearHistory),
  const FunctionCommand(<String>['browser_redirect'], _redirect),
  const FunctionCommand(<String>['browser_tab'], _tab),
];

CommandOutcome _open(CommandContext ctx) {
  final String url = ctx.str(0, EngineDefaults.browserHomePage);
  final bool incognito = ctx.namedBool('incognito');
  final String tabId = ctx.namedStr('tab', ctx.uid('tab'));

  ctx.engine.state.updateBrowser((BrowserState b) {
    final List<BrowserTab> tabs = List<BrowserTab>.of(b.tabs);
    final int existing = tabs.indexWhere((BrowserTab t) => t.id == tabId);
    final BrowserTab tab = BrowserTab(
      id: tabId,
      url: url,
      title: ctx.namedStr('title', _titleFor(url)),
      incognito: incognito,
    );
    if (existing >= 0) {
      tabs[existing] = tab;
    } else {
      tabs.add(tab);
    }
    return b.copyWith(tabs: tabs, activeTabId: tabId, open: true);
  });

  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(currentApp: 'browser', locked: false),
  );
  ctx.engine.emitEffect(const OpenAppEffect('browser'));
  return _recordVisit(ctx, url);
}

CommandOutcome _visit(CommandContext ctx) {
  final String url = ctx.str(0);
  if (url.isEmpty) return CommandOutcome.next;

  ctx.engine.state.updateBrowser((BrowserState b) {
    final List<BrowserTab> tabs = List<BrowserTab>.of(b.tabs);
    final String tabId = ctx.namedStr('tab', b.activeTabId ?? ctx.uid('tab'));
    final int index = tabs.indexWhere((BrowserTab t) => t.id == tabId);
    final BrowserTab tab = BrowserTab(
      id: tabId,
      url: url,
      title: ctx.namedStr('title', _titleFor(url)),
    );
    if (index >= 0) {
      tabs[index] = tab;
    } else {
      tabs.add(tab);
    }
    return b.copyWith(tabs: tabs, activeTabId: tabId, open: true);
  });

  final Duration load = ctx.namedDuration(
    'delay',
    const Duration(milliseconds: 700),
  );
  final CommandOutcome outcome = _recordVisit(ctx, url);
  if (outcome.type == CommandOutcomeType.next && load > Duration.zero) {
    return CommandOutcome.wait(ctx.engine.pace(load));
  }
  return outcome;
}

CommandOutcome _recordVisit(CommandContext ctx, String url) {
  final BrowserHistoryEntry entry = BrowserHistoryEntry(
    url: url,
    title: ctx.namedStr('title', _titleFor(url)),
    visitedAt: ctx.engine.clock.now(),
  );
  ctx.engine.state.recordVisit(url);
  ctx.engine.state.updateBrowser(
    (BrowserState b) => b.copyWith(
      history: <BrowserHistoryEntry>[entry, ...b.history].take(120).toList(),
    ),
  );
  ctx.engine.emitEvent(
    EngineEvents.browserVisited,
    data: <String, Object?>{'url': url},
  );
  return CommandOutcome.next;
}

CommandOutcome _popup(CommandContext ctx) {
  final BrowserPopup popup = BrowserPopup(
    id: ctx.uid('popup'),
    title: ctx.namedStr('title', ctx.str(0, 'Advertisement')),
    body: ctx.str(1, ctx.namedStr('body')),
    image: ctx.namedStrOrNull('image'),
    cta: ctx.namedStr('cta', 'Open'),
    target: ctx.namedStrOrNull('target'),
    closable: ctx.namedBool('closable', true),
  );
  ctx.engine.state.updateBrowser((BrowserState b) => b.copyWith(popup: popup));
  ctx.engine.emitEffect(const PlaySoundEffect('msg_ping', volume: 0.5));
  return CommandOutcome.next;
}

/// Downloads an app package and installs it — the browser route into the OS.
CommandOutcome _download(CommandContext ctx) {
  final String appId = ctx.namedStr('app', ctx.id(0));
  if (appId.isEmpty) return CommandOutcome.next;

  final String name = ctx.namedStr('name', _pretty(appId));
  final Duration duration = ctx.namedDuration(
    'duration',
    const Duration(milliseconds: 2600),
  );

  final BrowserDownload download = BrowserDownload(
    id: ctx.uid('dl'),
    appId: appId,
    name: name,
    icon: ctx.namedStrOrNull('icon'),
    sizeLabel: ctx.namedStr('size', '38.4 MB'),
  );
  ctx.engine.state.updateBrowser(
    (BrowserState b) => b.copyWith(
      downloads: <BrowserDownload>[download, ...b.downloads],
      popup: null,
    ),
  );

  ctx.engine.emitEffect(
    GenericEffect('download_started', <String, Object?>{
      'app': appId,
      'name': name,
      'durationMs': duration.inMilliseconds,
    }),
  );

  // Finish the download, then hand over to the installer.
  ctx.engine.state.updateBrowser(
    (BrowserState b) => b.copyWith(
      downloads: b.downloads
          .map(
            (BrowserDownload d) => d.id == download.id
                ? d.copyWith(progress: 1, completed: true)
                : d,
          )
          .toList(),
    ),
  );
  ctx.engine.emitEvent(
    EngineEvents.downloadFinished,
    data: <String, Object?>{'app': appId},
  );

  return installAppCommand(ctx);
}

CommandOutcome _close(CommandContext ctx) {
  ctx.engine.state.updateBrowser(
    (BrowserState b) => b.copyWith(open: false, popup: null),
  );
  ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(currentApp: null));
  ctx.engine.emitEffect(const NavigateEffect('/phone'));
  return CommandOutcome.next;
}

CommandOutcome _bookmark(CommandContext ctx) {
  final String url = ctx.str(0, ctx.engine.state.browser.currentUrl);
  ctx.engine.state.updateBrowser(
    (BrowserState b) => b.copyWith(
      bookmarks: <BrowserHistoryEntry>[
        BrowserHistoryEntry(
          url: url,
          title: ctx.namedStr('title', _titleFor(url)),
          visitedAt: ctx.engine.clock.now(),
        ),
        ...b.bookmarks.where((BrowserHistoryEntry e) => e.url != url),
      ],
    ),
  );
  return CommandOutcome.next;
}

CommandOutcome _clearHistory(CommandContext ctx) {
  ctx.engine.state.updateBrowser(
    (BrowserState b) => b.copyWith(history: const <BrowserHistoryEntry>[]),
  );
  ctx.engine.emitEffect(const ToastEffect('Browsing history cleared'));
  return CommandOutcome.next;
}

CommandOutcome _redirect(CommandContext ctx) {
  final Duration delay = ctx.namedDuration(
    'delay',
    const Duration(milliseconds: 900),
  );
  final String url = ctx.str(0);
  if (url.isEmpty) return CommandOutcome.next;
  ctx.engine.scheduler.after(delay, () {
    ctx.engine.state.updateBrowser((BrowserState b) {
      final List<BrowserTab> tabs = List<BrowserTab>.of(b.tabs);
      final int index = tabs.indexWhere(
        (BrowserTab t) => t.id == b.activeTabId,
      );
      if (index >= 0) {
        tabs[index] = tabs[index].copyWith(url: url, title: _titleFor(url));
      }
      return b.copyWith(tabs: tabs);
    });
    ctx.engine.state.recordVisit(url);
  }, tag: 'browser');
  return CommandOutcome.wait(ctx.engine.pace(delay));
}

CommandOutcome _tab(CommandContext ctx) {
  final String tabId = ctx.id(0);
  if (ctx.namedBool('close')) {
    ctx.engine.state.updateBrowser((BrowserState b) {
      final List<BrowserTab> tabs = b.tabs
          .where((BrowserTab t) => t.id != tabId)
          .toList();
      return b.copyWith(
        tabs: tabs,
        activeTabId: tabs.isEmpty ? null : tabs.last.id,
      );
    });
    return CommandOutcome.next;
  }
  ctx.engine.state.updateBrowser(
    (BrowserState b) => b.copyWith(activeTabId: tabId),
  );
  return CommandOutcome.next;
}

String _titleFor(String url) {
  final String cleaned = url
      .replaceFirst(RegExp(r'^[a-z]+://'), '')
      .replaceFirst(RegExp(r'^www\.'), '');
  final int slash = cleaned.indexOf('/');
  return slash <= 0 ? cleaned : cleaned.substring(0, slash);
}

String _pretty(String id) => id
    .split(RegExp(r'[_\s]+'))
    .where((String part) => part.isNotEmpty)
    .map((String part) => part[0].toUpperCase() + part.substring(1))
    .join(' ');
