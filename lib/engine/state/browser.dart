/// Offline browser model: tabs, history, bookmarks, pop-ups and downloads.
library;

class BrowserTab {
  const BrowserTab({
    required this.id,
    required this.url,
    this.title = '',
    this.loading = false,
    this.incognito = false,
    this.scroll = 0,
  });

  final String id;
  final String url;
  final String title;
  final bool loading;
  final bool incognito;
  final double scroll;

  BrowserTab copyWith({
    String? url,
    String? title,
    bool? loading,
    double? scroll,
  }) => BrowserTab(
    id: id,
    url: url ?? this.url,
    title: title ?? this.title,
    loading: loading ?? this.loading,
    incognito: incognito,
    scroll: scroll ?? this.scroll,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'url': url,
    'title': title,
    'loading': loading,
    'incognito': incognito,
    'scroll': scroll,
  };

  factory BrowserTab.fromJson(Map<String, dynamic> json) => BrowserTab(
    id: json['id'] as String,
    url: json['url'] as String? ?? 'about:blank',
    title: json['title'] as String? ?? '',
    loading: json['loading'] as bool? ?? false,
    incognito: json['incognito'] as bool? ?? false,
    scroll: (json['scroll'] as num?)?.toDouble() ?? 0,
  );
}

class BrowserHistoryEntry {
  const BrowserHistoryEntry({
    required this.url,
    required this.title,
    required this.visitedAt,
  });

  final String url;
  final String title;
  final DateTime visitedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'url': url,
    'title': title,
    'at': visitedAt.millisecondsSinceEpoch,
  };

  factory BrowserHistoryEntry.fromJson(Map<String, dynamic> json) =>
      BrowserHistoryEntry(
        url: json['url'] as String? ?? '',
        title: json['title'] as String? ?? '',
        visitedAt: DateTime.fromMillisecondsSinceEpoch(
          (json['at'] as num?)?.toInt() ?? 0,
        ),
      );
}

class BrowserPopup {
  const BrowserPopup({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    this.cta = 'Open',
    this.target,
    this.closable = true,
  });

  final String id;
  final String title;
  final String body;
  final String? image;
  final String cta;

  /// url opened when the player taps the call-to-action.
  final String? target;
  final bool closable;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    if (image != null) 'image': image,
    'cta': cta,
    if (target != null) 'target': target,
    'closable': closable,
  };

  factory BrowserPopup.fromJson(Map<String, dynamic> json) => BrowserPopup(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    image: json['image'] as String?,
    cta: json['cta'] as String? ?? 'Open',
    target: json['target'] as String?,
    closable: json['closable'] as bool? ?? true,
  );
}

class BrowserDownload {
  const BrowserDownload({
    required this.id,
    required this.appId,
    required this.name,
    this.icon,
    this.progress = 0,
    this.completed = false,
    this.sizeLabel = '38.4 MB',
  });

  final String id;
  final String appId;
  final String name;
  final String? icon;
  final double progress;
  final bool completed;
  final String sizeLabel;

  BrowserDownload copyWith({double? progress, bool? completed}) =>
      BrowserDownload(
        id: id,
        appId: appId,
        name: name,
        icon: icon,
        progress: progress ?? this.progress,
        completed: completed ?? this.completed,
        sizeLabel: sizeLabel,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'app': appId,
    'name': name,
    if (icon != null) 'icon': icon,
    'progress': progress,
    'completed': completed,
    'size': sizeLabel,
  };

  factory BrowserDownload.fromJson(Map<String, dynamic> json) =>
      BrowserDownload(
        id: json['id'] as String,
        appId: json['app'] as String? ?? '',
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String?,
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        completed: json['completed'] as bool? ?? false,
        sizeLabel: json['size'] as String? ?? '38.4 MB',
      );
}

class BrowserState {
  const BrowserState({
    this.tabs = const <BrowserTab>[],
    this.activeTabId,
    this.history = const <BrowserHistoryEntry>[],
    this.bookmarks = const <BrowserHistoryEntry>[],
    this.popup,
    this.downloads = const <BrowserDownload>[],
    this.open = false,
  });

  final List<BrowserTab> tabs;
  final String? activeTabId;
  final List<BrowserHistoryEntry> history;
  final List<BrowserHistoryEntry> bookmarks;
  final BrowserPopup? popup;
  final List<BrowserDownload> downloads;
  final bool open;

  BrowserTab? get activeTab {
    if (tabs.isEmpty) return null;
    for (final BrowserTab tab in tabs) {
      if (tab.id == activeTabId) return tab;
    }
    return tabs.first;
  }

  String get currentUrl => activeTab?.url ?? 'about:blank';

  BrowserState copyWith({
    List<BrowserTab>? tabs,
    Object? activeTabId = _sentinel,
    List<BrowserHistoryEntry>? history,
    List<BrowserHistoryEntry>? bookmarks,
    Object? popup = _sentinel,
    List<BrowserDownload>? downloads,
    bool? open,
  }) {
    return BrowserState(
      tabs: tabs ?? this.tabs,
      activeTabId: identical(activeTabId, _sentinel)
          ? this.activeTabId
          : activeTabId as String?,
      history: history ?? this.history,
      bookmarks: bookmarks ?? this.bookmarks,
      popup: identical(popup, _sentinel) ? this.popup : popup as BrowserPopup?,
      downloads: downloads ?? this.downloads,
      open: open ?? this.open,
    );
  }

  static const Object _sentinel = Object();

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tabs': tabs.map((BrowserTab t) => t.toJson()).toList(),
    if (activeTabId != null) 'active': activeTabId,
    'history': history.map((BrowserHistoryEntry h) => h.toJson()).toList(),
    'bookmarks': bookmarks.map((BrowserHistoryEntry h) => h.toJson()).toList(),
    if (popup != null) 'popup': popup!.toJson(),
    'downloads': downloads.map((BrowserDownload d) => d.toJson()).toList(),
    'open': open,
  };

  factory BrowserState.fromJson(Map<String, dynamic> json) => BrowserState(
    tabs:
        (json['tabs'] as List<dynamic>?)
            ?.map(
              (dynamic e) =>
                  BrowserTab.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        const <BrowserTab>[],
    activeTabId: json['active'] as String?,
    history:
        (json['history'] as List<dynamic>?)
            ?.map(
              (dynamic e) => BrowserHistoryEntry.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList() ??
        const <BrowserHistoryEntry>[],
    bookmarks:
        (json['bookmarks'] as List<dynamic>?)
            ?.map(
              (dynamic e) => BrowserHistoryEntry.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList() ??
        const <BrowserHistoryEntry>[],
    popup: json['popup'] == null
        ? null
        : BrowserPopup.fromJson(
            Map<String, dynamic>.from(json['popup'] as Map),
          ),
    downloads:
        (json['downloads'] as List<dynamic>?)
            ?.map(
              (dynamic e) =>
                  BrowserDownload.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        const <BrowserDownload>[],
    open: json['open'] as bool? ?? false,
  );
}
