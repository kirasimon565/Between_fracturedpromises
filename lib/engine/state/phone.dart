/// Model of the simulated smartphone: apps, notifications, calls, status bar.
library;

class InstalledApp {
  const InstalledApp({
    required this.id,
    required this.name,
    this.icon,
    this.installedAt,
    this.badge = 0,
    this.system = false,
    this.hidden = false,
    this.source = 'system',
    this.accent,
  });

  final String id;
  final String name;
  final String? icon;
  final DateTime? installedAt;
  final int badge;

  /// System apps cannot be uninstalled by the story.
  final bool system;
  final bool hidden;

  /// `system`, `browser`, `store`, `sideload` — used by the install animation.
  final String source;
  final int? accent;

  InstalledApp copyWith({
    String? name,
    String? icon,
    int? badge,
    bool? hidden,
    String? source,
  }) =>
      InstalledApp(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        installedAt: installedAt,
        badge: badge ?? this.badge,
        system: system,
        hidden: hidden ?? this.hidden,
        source: source ?? this.source,
        accent: accent,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        if (icon != null) 'icon': icon,
        if (installedAt != null) 'at': installedAt!.millisecondsSinceEpoch,
        'badge': badge,
        'system': system,
        'hidden': hidden,
        'source': source,
        if (accent != null) 'accent': accent,
      };

  factory InstalledApp.fromJson(Map<String, dynamic> json) => InstalledApp(
        id: json['id'] as String,
        name: json['name'] as String? ?? json['id'] as String,
        icon: json['icon'] as String?,
        installedAt: json['at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch((json['at'] as num).toInt()),
        badge: (json['badge'] as num?)?.toInt() ?? 0,
        system: json['system'] as bool? ?? false,
        hidden: json['hidden'] as bool? ?? false,
        source: json['source'] as String? ?? 'system',
        accent: (json['accent'] as num?)?.toInt(),
      );
}

class GameNotification {
  const GameNotification({
    required this.id,
    required this.appId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.icon,
    this.threadId,
    this.sticky = false,
    this.read = false,
    this.sound,
  });

  final String id;
  final String appId;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? icon;
  final String? threadId;
  final bool sticky;
  final bool read;
  final String? sound;

  GameNotification copyWith({bool? read}) => GameNotification(
        id: id,
        appId: appId,
        title: title,
        body: body,
        timestamp: timestamp,
        icon: icon,
        threadId: threadId,
        sticky: sticky,
        read: read ?? this.read,
        sound: sound,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'app': appId,
        'title': title,
        'body': body,
        'ts': timestamp.millisecondsSinceEpoch,
        if (icon != null) 'icon': icon,
        if (threadId != null) 'thread': threadId,
        'sticky': sticky,
        'read': read,
        if (sound != null) 'sound': sound,
      };

  factory GameNotification.fromJson(Map<String, dynamic> json) =>
      GameNotification(
        id: json['id'] as String,
        appId: json['app'] as String? ?? 'system',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            (json['ts'] as num?)?.toInt() ?? 0),
        icon: json['icon'] as String?,
        threadId: json['thread'] as String?,
        sticky: json['sticky'] as bool? ?? false,
        read: json['read'] as bool? ?? false,
        sound: json['sound'] as String?,
      );
}

enum CallState { idle, incoming, active, ended, missed, voicemail }

class PhoneCall {
  const PhoneCall({
    required this.id,
    required this.characterId,
    required this.state,
    required this.startedAt,
    this.video = false,
    this.durationSeconds = 0,
    this.transcript = const <String>[],
  });

  final String id;
  final String characterId;
  final CallState state;
  final DateTime startedAt;
  final bool video;
  final int durationSeconds;
  final List<String> transcript;

  PhoneCall copyWith({
    CallState? state,
    int? durationSeconds,
    List<String>? transcript,
  }) =>
      PhoneCall(
        id: id,
        characterId: characterId,
        state: state ?? this.state,
        startedAt: startedAt,
        video: video,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        transcript: transcript ?? this.transcript,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'char': characterId,
        'state': state.name,
        'at': startedAt.millisecondsSinceEpoch,
        'video': video,
        'dur': durationSeconds,
        'transcript': transcript,
      };

  factory PhoneCall.fromJson(Map<String, dynamic> json) => PhoneCall(
        id: json['id'] as String,
        characterId: json['char'] as String? ?? '',
        state: CallState.values.firstWhere(
          (CallState s) => s.name == json['state'],
          orElse: () => CallState.idle,
        ),
        startedAt: DateTime.fromMillisecondsSinceEpoch(
            (json['at'] as num?)?.toInt() ?? 0),
        video: json['video'] as bool? ?? false,
        durationSeconds: (json['dur'] as num?)?.toInt() ?? 0,
        transcript: (json['transcript'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList() ??
            const <String>[],
      );
}

/// Everything the status bar, home screen and app switcher need.
class PhoneState {
  const PhoneState({
    this.battery = 78,
    this.charging = false,
    this.signal = 4,
    this.wifi = true,
    this.airplaneMode = false,
    this.networkState = 'online',
    this.clock = '21:00',
    this.date = '',
    this.location = '',
    this.weather = '',
    this.locked = false,
    this.silent = false,
    this.wallpaper,
    this.currentApp,
    this.currentScreen,
    this.theme = 'dark',
    this.apps = const <InstalledApp>[],
    this.notifications = const <GameNotification>[],
    this.calls = const <PhoneCall>[],
    this.activeCall,
  });

  final int battery;
  final bool charging;
  final int signal;
  final bool wifi;
  final bool airplaneMode;

  /// `online`, `offline`, `slow`, `unstable`.
  final String networkState;
  final String clock;
  final String date;
  final String location;
  final String weather;
  final bool locked;
  final bool silent;
  final String? wallpaper;
  final String? currentApp;
  final String? currentScreen;
  final String theme;
  final List<InstalledApp> apps;
  final List<GameNotification> notifications;
  final List<PhoneCall> calls;
  final PhoneCall? activeCall;

  bool hasApp(String id) =>
      apps.any((InstalledApp app) => app.id == id.toLowerCase());

  InstalledApp? app(String id) {
    for (final InstalledApp app in apps) {
      if (app.id == id.toLowerCase()) return app;
    }
    return null;
  }

  int get unreadNotifications =>
      notifications.where((GameNotification n) => !n.read).length;

  PhoneState copyWith({
    int? battery,
    bool? charging,
    int? signal,
    bool? wifi,
    bool? airplaneMode,
    String? networkState,
    String? clock,
    String? date,
    String? location,
    String? weather,
    bool? locked,
    bool? silent,
    String? wallpaper,
    Object? currentApp = _sentinel,
    Object? currentScreen = _sentinel,
    String? theme,
    List<InstalledApp>? apps,
    List<GameNotification>? notifications,
    List<PhoneCall>? calls,
    Object? activeCall = _sentinel,
  }) {
    return PhoneState(
      battery: battery ?? this.battery,
      charging: charging ?? this.charging,
      signal: signal ?? this.signal,
      wifi: wifi ?? this.wifi,
      airplaneMode: airplaneMode ?? this.airplaneMode,
      networkState: networkState ?? this.networkState,
      clock: clock ?? this.clock,
      date: date ?? this.date,
      location: location ?? this.location,
      weather: weather ?? this.weather,
      locked: locked ?? this.locked,
      silent: silent ?? this.silent,
      wallpaper: wallpaper ?? this.wallpaper,
      currentApp: identical(currentApp, _sentinel)
          ? this.currentApp
          : currentApp as String?,
      currentScreen: identical(currentScreen, _sentinel)
          ? this.currentScreen
          : currentScreen as String?,
      theme: theme ?? this.theme,
      apps: apps ?? this.apps,
      notifications: notifications ?? this.notifications,
      calls: calls ?? this.calls,
      activeCall: identical(activeCall, _sentinel)
          ? this.activeCall
          : activeCall as PhoneCall?,
    );
  }

  static const Object _sentinel = Object();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'battery': battery,
        'charging': charging,
        'signal': signal,
        'wifi': wifi,
        'airplane': airplaneMode,
        'network': networkState,
        'clock': clock,
        'date': date,
        'location': location,
        'weather': weather,
        'locked': locked,
        'silent': silent,
        if (wallpaper != null) 'wallpaper': wallpaper,
        if (currentApp != null) 'app': currentApp,
        if (currentScreen != null) 'screen': currentScreen,
        'theme': theme,
        'apps': apps.map((InstalledApp a) => a.toJson()).toList(),
        'notifications':
            notifications.map((GameNotification n) => n.toJson()).toList(),
        'calls': calls.map((PhoneCall c) => c.toJson()).toList(),
        if (activeCall != null) 'activeCall': activeCall!.toJson(),
      };

  factory PhoneState.fromJson(Map<String, dynamic> json) => PhoneState(
        battery: (json['battery'] as num?)?.toInt() ?? 78,
        charging: json['charging'] as bool? ?? false,
        signal: (json['signal'] as num?)?.toInt() ?? 4,
        wifi: json['wifi'] as bool? ?? true,
        airplaneMode: json['airplane'] as bool? ?? false,
        networkState: json['network'] as String? ?? 'online',
        clock: json['clock'] as String? ?? '21:00',
        date: json['date'] as String? ?? '',
        location: json['location'] as String? ?? '',
        weather: json['weather'] as String? ?? '',
        locked: json['locked'] as bool? ?? false,
        silent: json['silent'] as bool? ?? false,
        wallpaper: json['wallpaper'] as String?,
        currentApp: json['app'] as String?,
        currentScreen: json['screen'] as String?,
        theme: json['theme'] as String? ?? 'dark',
        apps: (json['apps'] as List<dynamic>?)
                ?.map((dynamic e) =>
                    InstalledApp.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const <InstalledApp>[],
        notifications: (json['notifications'] as List<dynamic>?)
                ?.map((dynamic e) => GameNotification.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const <GameNotification>[],
        calls: (json['calls'] as List<dynamic>?)
                ?.map((dynamic e) =>
                    PhoneCall.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const <PhoneCall>[],
        activeCall: json['activeCall'] == null
            ? null
            : PhoneCall.fromJson(
                Map<String, dynamic>.from(json['activeCall'] as Map)),
      );
}
