import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'map_screen_notice.dart';

class MapScreenNoticeOverlay extends StatefulWidget {
  const MapScreenNoticeOverlay({
    super.key,
    required this.notices,
    required this.onDismissNotice,
    required this.infoScopeKey,
    this.infoTitle,
    this.infoMessage,
  });

  final List<MapScreenNotice> notices;
  final ValueChanged<int> onDismissNotice;
  final String infoScopeKey;
  final String? infoTitle;
  final String? infoMessage;

  @override
  State<MapScreenNoticeOverlay> createState() => _MapScreenNoticeOverlayState();
}

class _MapScreenNoticeOverlayState extends State<MapScreenNoticeOverlay> {
  Timer? _infoTimer;
  String? _activeInfoKey;
  late String _scopeKey;
  bool _showInfo = false;
  final Set<String> _dismissedInfoKeys = {};

  @override
  void initState() {
    super.initState();
    _scopeKey = widget.infoScopeKey;
    _syncInfoNotice();
  }

  @override
  void didUpdateWidget(covariant MapScreenNoticeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_scopeKey != widget.infoScopeKey) {
      _scopeKey = widget.infoScopeKey;
      _dismissedInfoKeys.clear();
      _activeInfoKey = null;
      _showInfo = false;
      _infoTimer?.cancel();
    }
    _syncInfoNotice();
  }

  @override
  void dispose() {
    _infoTimer?.cancel();
    super.dispose();
  }

  void _syncInfoNotice() {
    final title = widget.infoTitle;
    if (title == null || title.trim().isEmpty) {
      _infoTimer?.cancel();
      _activeInfoKey = null;
      _showInfo = false;
      return;
    }

    final key = '$title|${widget.infoMessage ?? ''}';
    if (_activeInfoKey == key || _dismissedInfoKeys.contains(key)) {
      return;
    }

    _activeInfoKey = key;
    _showInfo = true;
    _infoTimer?.cancel();
    _infoTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _activeInfoKey != key) {
        return;
      }
      setState(() {
        _showInfo = false;
        _dismissedInfoKeys.add(key);
      });
    });

    if (mounted) {
      setState(() {});
    }
  }

  void _dismissInfo() {
    final key = _activeInfoKey;
    _infoTimer?.cancel();
    setState(() {
      _showInfo = false;
      if (key != null) {
        _dismissedInfoKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeInfo = _showInfo && widget.infoTitle != null
        ? MapScreenNotice(
            id: -1,
            title: widget.infoTitle!,
            message: widget.infoMessage,
          )
        : null;
    final visibleNotices = [
      if (activeInfo != null) activeInfo,
      ...widget.notices,
    ].take(3).toList();

    return IgnorePointer(
      ignoring: visibleNotices.isEmpty,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visibleNotices.isEmpty ? 0 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final notice in visibleNotices) ...[
              _GlassNoticeCard(
                key: ValueKey('map-notice-${notice.id}-${notice.title}'),
                notice: notice,
                onDismiss: notice.id == -1
                    ? _dismissInfo
                    : () => widget.onDismissNotice(notice.id),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassNoticeCard extends StatelessWidget {
  const _GlassNoticeCard({
    super.key,
    required this.notice,
    required this.onDismiss,
  });

  final MapScreenNotice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isWarning = notice.level == MapScreenNoticeLevel.warning;
    final accent =
        isWarning ? const Color(0xFFF59E0B) : const Color(0xFF6366F1);
    final icon =
        isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded;

    return Dismissible(
      key: ValueKey('dismiss-${notice.id}-${notice.title}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: accent, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.15,
                        ),
                      ),
                      if (notice.message?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          notice.message!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF64748B),
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
