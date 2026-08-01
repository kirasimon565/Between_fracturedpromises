# Between: Fractured Promises

An offline interactive psychological drama. The player holds Nadia's phone —
every message, browser tab, missed call and 2am decision happens inside a
simulated phone OS, and the whole story is written in a custom DSL that the
in-app interpreter executes at runtime.

```bash
flutter pub get
flutter run
```

That is the entire setup. There is **no `build_runner` step**, no code
generation, no service account, no `google-services.json`.

---

## What this build is

| | |
|---|---|
| **Runs offline** | 100%. The only socket the app ever opens is the store-billing channel used to verify a purchase. |
| **Persistence** | Drift / SQLite only. |
| **State** | Riverpod 3 (plain `Notifier` / `AsyncNotifier` / `Provider`); `AsyncValue.value` is used in place of the removed `valueOrNull`. |
| **Story** | A custom DSL (`assets/story/episodes/*.txt`) compiled and interpreted at runtime. |
| **Monetisation** | Crystals, behind a store-agnostic gateway (Huawei AppGallery, Amazon Appstore, Samsung Galaxy Store). |

### Explicitly not used

Firebase (Firestore / Storage / Auth / cloud sync), SharedPreferences, Hive,
Isar, `freezed`, `json_serializable`, `riverpod_generator`, `build_runner`.
Every model has a hand-written `toJson`/`fromJson`; every provider is declared
by hand. Nothing in `lib/` has a `part '*.g.dart'` directive.

---

## Architecture

```
lib/
  app/          MaterialApp + GoRouter (the intro is a straight line)
  core/         config, billing gateways, Riverpod providers
  database/     Drift schema, connection, repositories
  engine/       the story engine — no Flutter import anywhere in here
    lexer/      source -> tokens
    parser/     tokens -> AST -> Program, plus the directive registry
    runtime/    StoryRuntime: the interpreter, effects, pending choices
    commands/   one file per directive family
    state/      GameState and its slices (phone, browser, chat, wallet…)
  features/     phone shell, messenger, browser, makelove, store, studio intro
  shared/       theme + shared widgets
```

The engine is a standalone library. It does not import Flutter, a database, or
a store SDK — the host app injects a script resolver, a `CommandRegistry` and a
checkpoint callback:

```dart
final loader  = StoryLoader(resolver: (p) => rootBundle.loadString('assets/story/$p'));
final story   = await loader.load('episodes/ep1.txt', id: 'ep1');
final runtime = StoryRuntime(registry: createCommandRegistry());
await runtime.start(story.program);
```

### Extending it

Adding a directive is two edits and touches nothing else:

1. register a `DirectiveSpec` in `engine/parser/directive_registry.dart`
2. register a `CommandHandler` in `engine/commands/`

`createCommandRegistry(plugins: ...)` is the supported way to add or override
handlers without modifying the engine.

---

## The DSL

Labels are `:: name`; directives start with `@`.

```
:: scene_the_download
@browser_visit "makelove.app/download" title "Makelove - Download"
@message system "38.4 MB. One button. That is the entire distance."
@await browser_install_confirm timeout 180
@browser_download app "makelove" name "Makelove" size "38.4 MB" duration 2.6
@browser_close
@open_app makelove

@choice
"Say hello." -> @scene_hello
"Close it." -> @scene_close
💎 "Tell him the truth." -> @scene_truth
```

165 directives are registered, covering control flow (`@goto`, `@call`, `@if`,
`@switch`, `@while`, `@choice` incl. timed / locked / premium), messaging,
variables and flags, relationships (`@trust` / `@friendship` / `@love`),
evidence, journal, objectives, gallery, media and audio, the phone and browser,
calls, events and scheduling, achievements, and plugins.

**The install is real.** Makelove is not a flag flipped in Dart — the player
taps Install on a rendered web page, which emits `browser_install_confirm`, the
script's `@await` resolves, and `@browser_download` installs the app into the
phone OS. The icon then appears on the home screen because the OS state changed,
not because a screen was hard-coded.

---

## Verification

Two offline linters live in `tool/`:

```bash
python3 tool/dart_static_check.py   # imports, symbol visibility, member access
python3 tool/story_check.py         # registry vs handlers, scripts vs engine
```

`story_check.py` is the useful one: it fails if a directive is registered
without a handler, if a handler reads a named argument its spec does not
declare, if a script uses an unknown directive, jumps to a label that does not
exist, references a missing asset, or opens a URL that no page in
`assets/data/websites.json` resolves.

`tool/ci-analyze.yml.example` is a ready-to-use workflow that runs
`flutter analyze`, a format check, both linters and a debug APK build. Copy it
to `.github/workflows/analyze.yml` to enable it — it is not installed by
default because pushing workflow files needs a token with the `workflows`
scope.

---

## Content warning

Depicts emotional infidelity, manipulation, and the slow collapse of a
marriage. Intended for adults.
