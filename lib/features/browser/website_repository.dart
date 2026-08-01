import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_config.dart';

/// One renderable chunk of a fake web page.
class WebBlock {
  const WebBlock(this.type, this.data);

  final String type;
  final Map<String, Object?> data;

  String get text => (data['value'] ?? data['title'] ?? '').toString();

  String? str(String key) => data[key]?.toString();

  num? number(String key) => data[key] as num?;

  List<Map<String, Object?>> get items {
    final Object? raw = data['items'];
    if (raw is! List) return const <Map<String, Object?>>[];
    return raw
        .whereType<Map<String, Object?>>()
        .toList(growable: false);
  }

  factory WebBlock.fromJson(Map<String, Object?> json) =>
      WebBlock((json['type'] ?? 'text').toString(), json);
}

/// A fake website.
class WebPage {
  const WebPage({
    required this.url,
    required this.title,
    required this.blocks,
    this.kind = 'page',
    this.accent,
  });

  final String url;
  final String title;
  final List<WebBlock> blocks;
  final String kind;
  final String? accent;

  factory WebPage.fromJson(Map<String, Object?> json) => WebPage(
        url: (json['url'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        kind: (json['kind'] ?? 'page').toString(),
        accent: json['accent']?.toString(),
        blocks: ((json['blocks'] as List<Object?>?) ?? const <Object?>[])
            .whereType<Map<String, Object?>>()
            .map(WebBlock.fromJson)
            .toList(growable: false),
      );
}

/// Loads `assets/data/websites.json`.
///
/// Pages are pure content: navigation, history and downloads are engine state,
/// so a page can be visited by the player *or* by a `@browser_visit` directive
/// and behave identically.
class WebsiteRepository {
  WebsiteRepository(this._pages, this._notFound);

  final Map<String, WebPage> _pages;
  final WebPage _notFound;

  static Future<WebsiteRepository> load() async {
    final String raw = await rootBundle.loadString(AppConfig.websiteCatalog);
    final Map<String, Object?> json =
        jsonDecode(raw) as Map<String, Object?>;

    final Map<String, WebPage> pages = <String, WebPage>{};
    for (final Object? entry in (json['sites'] as List<Object?>? ?? const <Object?>[])) {
      if (entry is! Map<String, Object?>) continue;
      final WebPage page = WebPage.fromJson(entry);
      pages[normalise(page.url)] = page;
    }

    final Map<String, Object?> missing =
        (json['notFound'] as Map<String, Object?>?) ??
            <String, Object?>{'title': 'Not found', 'blocks': <Object?>[]};

    return WebsiteRepository(
      pages,
      WebPage.fromJson(<String, Object?>{...missing, 'url': 'about:blank'}),
    );
  }

  Iterable<WebPage> get all => _pages.values;

  /// Strips scheme, `www.` and trailing slashes so `https://Makelove.app/`
  /// and `makelove.app` are the same page.
  static String normalise(String url) {
    String value = url.trim().toLowerCase();
    if (value.startsWith('between://')) return value;
    value = value.replaceFirst(RegExp(r'^[a-z]+://'), '');
    value = value.replaceFirst(RegExp(r'^www\.'), '');
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  WebPage resolve(String url) {
    final String key = normalise(url);
    final WebPage? exact = _pages[key];
    if (exact != null) return exact;

    // `q-search.com/?q=makelove` still resolves to the search page. The base
    // has to be re-trimmed because the `/` sits *before* the query string and
    // therefore survived [normalise].
    final int query = key.indexOf('?');
    if (query > 0) {
      String base = key.substring(0, query);
      while (base.endsWith('/')) {
        base = base.substring(0, base.length - 1);
      }
      final WebPage? page = _pages[base];
      if (page != null) return page;
    }

    // Unknown deep link on a known host: fall back to that host's front page
    // rather than a dead end (`nightowl-forum.net/threads/whatever`).
    final int slash = key.indexOf('/');
    if (slash > 0) {
      final WebPage? host = _pages[key.substring(0, slash)];
      if (host != null) return host;
    }
    return _notFound;
  }

  bool exists(String url) => _pages.containsKey(normalise(url));
}

final FutureProvider<WebsiteRepository> websiteRepositoryProvider =
    FutureProvider<WebsiteRepository>((ref) => WebsiteRepository.load());
