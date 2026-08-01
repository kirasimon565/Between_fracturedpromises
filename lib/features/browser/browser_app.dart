import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import 'website_repository.dart';

/// Orbit — the in-game browser.
///
/// Tabs, history, bookmarks, pop-ups and downloads all live in the engine's
/// [BrowserState], so a script can drive the browser (`@browser_visit`) and the
/// player can drive it by tapping, with identical results.
class BrowserApp extends ConsumerStatefulWidget {
  const BrowserApp({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  ConsumerState<BrowserApp> createState() => _BrowserAppState();
}

class _BrowserAppState extends ConsumerState<BrowserApp> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _editing = false;
  bool _showTabs = false;

  @override
  void dispose() {
    _urlController.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _go(String url) {
    if (url.trim().isEmpty) return;
    setState(() => _editing = false);
    _focus.unfocus();
    ref.read(gameSessionProvider.notifier).browse(url.trim());
  }

  @override
  Widget build(BuildContext context) {
    final BrowserState browser = ref.watch(browserStateProvider);
    final AsyncValue<WebsiteRepository> sites =
        ref.watch(websiteRepositoryProvider);
    final String url = browser.currentUrl;

    if (!_editing && _urlController.text != url) {
      _urlController.text = url;
    }

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _OmniBar(
              controller: _urlController,
              focusNode: _focus,
              editing: _editing,
              tabCount: browser.tabs.length,
              incognito: browser.activeTab?.incognito ?? false,
              onEdit: () => setState(() => _editing = true),
              onSubmit: _go,
              onTabs: () => setState(() => _showTabs = !_showTabs),
              onClose: widget.onExit,
            ),
            Expanded(
              child: sites.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
                error: (Object error, _) => EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'No connection',
                  message: '$error',
                ),
                data: (WebsiteRepository repository) => _PageView(
                  page: repository.resolve(url),
                  onNavigate: _go,
                ),
              ),
            ),
            if (browser.downloads.isNotEmpty)
              _DownloadBar(download: browser.downloads.first),
          ],
        ),
        if (_showTabs)
          _TabSwitcher(
            browser: browser,
            onSelect: (String id) {
              setState(() => _showTabs = false);
              ref.read(gameSessionProvider.notifier).selectTab(id);
            },
            onClose: () => setState(() => _showTabs = false),
          ),
        if (browser.popup != null)
          _PopupLayer(
            popup: browser.popup!,
            onAccept: () {
              final String? target = browser.popup!.target;
              ref.read(gameSessionProvider.notifier).dismissPopup();
              if (target != null) _go(target);
            },
            onDismiss: () =>
                ref.read(gameSessionProvider.notifier).dismissPopup(),
          ),
      ],
    );
  }
}

class _OmniBar extends StatelessWidget {
  const _OmniBar({
    required this.controller,
    required this.focusNode,
    required this.editing,
    required this.tabCount,
    required this.incognito,
    required this.onEdit,
    required this.onSubmit,
    required this.onTabs,
    this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool editing;
  final int tabCount;
  final bool incognito;
  final VoidCallback onEdit;
  final ValueChanged<String> onSubmit;
  final VoidCallback onTabs;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: <Widget>[
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
              color: AppColors.textDim,
            ),
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: AppRadii.pill,
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      incognito ? Icons.visibility_off_rounded : Icons.lock_outline,
                      size: 13,
                      color: incognito ? AppColors.warning : AppColors.textFaint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: editing
                          ? TextField(
                              controller: controller,
                              focusNode: focusNode,
                              autofocus: true,
                              onSubmitted: onSubmit,
                              textInputAction: TextInputAction.go,
                              style: const TextStyle(
                                  color: AppColors.text, fontSize: 13),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Search or type a URL',
                              ),
                            )
                          : Text(
                              controller.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textDim, fontSize: 13),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onTabs,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textDim, width: 1.6),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '$tabCount',
                style: const TextStyle(
                  color: AppColors.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Turns the JSON block list into widgets.
class _PageView extends ConsumerWidget {
  const _PageView({required this.page, required this.onNavigate});

  final WebPage page;
  final ValueChanged<String> onNavigate;

  Color get _accent => switch (page.accent) {
        'makelove' => AppColors.makelove,
        'browser' => AppColors.browser,
        _ => AppColors.browser,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
      children: <Widget>[
        for (final WebBlock block in page.blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _block(context, ref, block),
          ),
      ],
    );
  }

  Widget _block(BuildContext context, WidgetRef ref, WebBlock block) {
    switch (block.type) {
      case 'hero':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 18),
            Text(
              block.str('title') ?? '',
              style: TextStyle(
                color: _accent,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              block.str('subtitle') ?? '',
              style: const TextStyle(color: AppColors.textFaint, fontSize: 13),
            ),
            const SizedBox(height: 10),
          ],
        );

      case 'heading':
        return Text(
          block.text,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        );

      case 'text':
        return Text(
          block.text,
          style: const TextStyle(
              color: AppColors.textDim, fontSize: 14, height: 1.6),
        );

      case 'quote':
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.card,
            border: Border(
                left: BorderSide(color: _accent.withValues(alpha: 0.6), width: 2)),
          ),
          child: Text(
            block.text,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 13.5,
              height: 1.55,
              fontStyle: FontStyle.italic,
            ),
          ),
        );

      case 'list':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final Object? item
                in (block.data['items'] as List<Object?>? ?? const <Object?>[]))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 10),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                            color: _accent, shape: BoxShape.circle),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 13.5,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );

      case 'results':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final Map<String, Object?> item in block.items)
              InkWell(
                onTap: () => onNavigate(item['url'].toString()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item['title'].toString(),
                        style: TextStyle(
                          color: _accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['url'].toString(),
                        style: const TextStyle(
                            color: AppColors.success, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (item['snippet'] ?? '').toString(),
                        style: const TextStyle(
                            color: AppColors.textFaint,
                            fontSize: 12.5,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );

      case 'shortcuts':
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final Map<String, Object?> item in block.items)
              ActionChip(
                onPressed: () => onNavigate(item['url'].toString()),
                backgroundColor: AppColors.surfaceHigh,
                side: const BorderSide(color: AppColors.outline),
                label: Text(
                  item['label'].toString(),
                  style: const TextStyle(color: AppColors.text, fontSize: 12.5),
                ),
              ),
          ],
        );

      case 'link':
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () => onNavigate(block.str('url') ?? ''),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              side: BorderSide(color: _accent.withValues(alpha: 0.6)),
              foregroundColor: _accent,
            ),
            child: Text(block.str('label') ?? 'Open'),
          ),
        );

      case 'rating':
        return Row(
          children: <Widget>[
            for (int i = 0; i < 5; i++)
              Icon(
                i < (block.number('value') ?? 0).round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 16,
                color: AppColors.warning,
              ),
            const SizedBox(width: 8),
            Text(
              '${block.number('value') ?? 0} · ${block.str('count') ?? ''}',
              style:
                  const TextStyle(color: AppColors.textFaint, fontSize: 11.5),
            ),
            const Spacer(),
            Text(
              block.str('size') ?? '',
              style:
                  const TextStyle(color: AppColors.textFaint, fontSize: 11.5),
            ),
          ],
        );

      case 'reviews':
        return Column(
          children: <Widget>[
            for (final Map<String, Object?> item in block.items)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          item['author'].toString(),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        for (int i = 0; i < ((item['stars'] as num?) ?? 0); i++)
                          const Icon(Icons.star_rounded,
                              size: 11, color: AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item['body'].toString(),
                      style: const TextStyle(
                          color: AppColors.textFaint,
                          fontSize: 12.5,
                          height: 1.45),
                    ),
                  ],
                ),
              ),
          ],
        );

      case 'warning':
        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: AppRadii.card,
            border:
                Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.warning_amber_rounded,
                  size: 17, color: AppColors.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(
                      color: AppColors.warning, fontSize: 12.5, height: 1.45),
                ),
              ),
            ],
          ),
        );

      case 'ad':
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.card,
            gradient: LinearGradient(colors: <Color>[
              AppColors.makelove.withValues(alpha: 0.24),
              AppColors.ember.withValues(alpha: 0.16),
            ]),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(
                      color: AppColors.text, fontSize: 13, height: 1.4),
                ),
              ),
              const Text('Ad',
                  style:
                      TextStyle(color: AppColors.textFaint, fontSize: 10)),
            ],
          ),
        );

      case 'install':
        return _InstallBlock(block: block, accent: _accent);

      default:
        return Text(
          block.text,
          style: const TextStyle(color: AppColors.textDim, fontSize: 13.5),
        );
    }
  }
}

/// The button that hands control back to the script.
///
/// It does not install anything by itself: it emits `browser_install_confirm`,
/// which the episode is `@await`-ing. The DSL then runs `@browser_download`.
class _InstallBlock extends ConsumerStatefulWidget {
  const _InstallBlock({required this.block, required this.accent});

  final WebBlock block;
  final Color accent;

  @override
  ConsumerState<_InstallBlock> createState() => _InstallBlockState();
}

class _InstallBlockState extends ConsumerState<_InstallBlock> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final String appId = widget.block.str('app') ?? '';
    final bool installed = ref.watch(phoneStateProvider).hasApp(appId);

    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: installed || _pressed
            ? null
            : () {
                setState(() => _pressed = true);
                ref.read(gameSessionProvider.notifier).emitUiEvent(
                  'browser_install_confirm',
                  data: <String, Object?>{
                    'app': appId,
                    'name': widget.block.str('name') ?? appId,
                  },
                );
              },
        style: FilledButton.styleFrom(
          backgroundColor: widget.accent,
          disabledBackgroundColor: AppColors.surfaceHigh,
        ),
        icon: Icon(
          installed ? Icons.check_rounded : Icons.download_rounded,
          size: 18,
        ),
        label: Text(
          installed
              ? 'Installed'
              : (_pressed ? 'Starting…' : (widget.block.str('label') ?? 'Install')),
        ),
      ),
    );
  }
}

class _DownloadBar extends StatelessWidget {
  const _DownloadBar({required this.download});

  final BrowserDownload download;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            download.completed
                ? Icons.check_circle_outline_rounded
                : Icons.downloading_rounded,
            size: 17,
            color: download.completed ? AppColors.success : AppColors.browser,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${download.name} · ${download.sizeLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textDim, fontSize: 12),
            ),
          ),
          Text(
            download.completed ? 'Done' : 'Downloading',
            style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.6, end: 0, duration: 240.ms);
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({
    required this.browser,
    required this.onSelect,
    required this.onClose,
  });

  final BrowserState browser;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: AppColors.voidBlack.withValues(alpha: 0.92),
        padding: const EdgeInsets.fromLTRB(16, 70, 16, 20),
        child: browser.tabs.isEmpty
            ? const EmptyState(
                icon: Icons.tab_outlined,
                title: 'No open tabs',
              )
            : ListView(
                children: <Widget>[
                  for (final BrowserTab tab in browser.tabs)
                    GestureDetector(
                      onTap: () => onSelect(tab.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadii.card,
                          border: Border.all(
                            color: tab.id == browser.activeTabId
                                ? AppColors.browser
                                : AppColors.outline,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              tab.title.isEmpty ? tab.url : tab.title,
                              style: const TextStyle(
                                  color: AppColors.text, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.url,
                              style: const TextStyle(
                                  color: AppColors.textFaint, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _PopupLayer extends StatelessWidget {
  const _PopupLayer({
    required this.popup,
    required this.onAccept,
    required this.onDismiss,
  });

  final BrowserPopup popup;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    popup.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (popup.closable)
                  InkWell(
                    onTap: onDismiss,
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textFaint),
                  ),
              ],
            ),
            if (popup.body.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                popup.body,
                style: const TextStyle(
                    color: AppColors.textDim, fontSize: 13, height: 1.5),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(onPressed: onAccept, child: Text(popup.cta)),
            if (popup.closable)
              TextButton(onPressed: onDismiss, child: const Text('Not now')),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scaleXY(begin: 0.94, end: 1);
  }
}
