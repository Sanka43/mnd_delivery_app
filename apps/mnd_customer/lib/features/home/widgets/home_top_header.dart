import 'dart:ui' show ImageFilter;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../models/home_catalog_models.dart';

String _toTitleCase(String value) {
  return value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) {
        if (part.length == 1) {
          return part.toUpperCase();
        }
        return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
      })
      .join(' ');
}

/// Profile row; search opens as an overlay above the rest of the page.
class HomeTopHeader extends StatefulWidget {
  const HomeTopHeader({
    super.key,
    required this.user,
    required this.onOpenProfile,
    this.onSearchOverlayChanged,
  });

  final User user;
  final VoidCallback onOpenProfile;

  /// Called when the search overlay opens or closes (e.g. to lock page scroll).
  final ValueChanged<bool>? onSearchOverlayChanged;

  @override
  State<HomeTopHeader> createState() => _HomeTopHeaderState();
}

class _HomeTopHeaderState extends State<HomeTopHeader> {
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _searchLayerLink = LayerLink();
  OverlayEntry? _searchOverlayEntry;

  static List<String> get _suggestionPool {
    final names = HomeMockCatalog.bestSellers.map((e) => e.name);
    final categories = HomeMockCatalog.categories.map(
      (e) => '${e.emoji} ${e.label}',
    );
    return [...names, ...categories, 'Rice & curry', 'Kottu', 'Fried rice'];
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {});
      _searchOverlayEntry?.markNeedsBuild();
    });
  }

  @override
  void dispose() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
    if (_searchOpen) {
      widget.onSearchOverlayChanged?.call(false);
    }
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _setSearchOpen(bool open) {
    if (open == _searchOpen) return;

    if (!open) {
      setState(() => _searchOpen = false);
      _searchFocus.unfocus();
      _searchCtrl.clear();
      _searchOverlayEntry?.remove();
      _searchOverlayEntry = null;
      widget.onSearchOverlayChanged?.call(false);
      return;
    }

    setState(() => _searchOpen = true);
    widget.onSearchOverlayChanged?.call(true);

    _searchOverlayEntry?.remove();
    _searchOverlayEntry = OverlayEntry(
      builder: (overlayContext) => _buildSearchOverlay(overlayContext),
    );
    Overlay.of(context).insert(_searchOverlayEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _searchOpen) _searchFocus.requestFocus();
    });
  }

  List<String> _filteredSuggestions() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final pool = _suggestionPool;
    if (q.isEmpty) {
      return pool.take(6).toList();
    }
    return pool.where((s) => s.toLowerCase().contains(q)).take(10).toList();
  }

  Widget _buildSearchOverlay(BuildContext overlayContext) {
    final theme = Theme.of(overlayContext);
    final cs = theme.colorScheme;
    final suggestions = _filteredSuggestions();
    final panelWidth = MediaQuery.sizeOf(overlayContext).width - 40;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setSearchOpen(false),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.32)
                        : Colors.white.withValues(alpha: 0.42),
                  ),
                ),
              ),
            ),
          ),
        ),
        CompositedTransformFollower(
          link: _searchLayerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: panelWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: theme.brightness == Brightness.dark
                                  ? [
                                      cs.surface.withValues(alpha: 0.56),
                                      cs.surface.withValues(alpha: 0.38),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.94),
                                      Colors.white.withValues(alpha: 0.78),
                                    ],
                            ),
                            border: Border.all(
                              color: _searchFocus.hasFocus
                                  ? cs.primary.withValues(alpha: 0.85)
                                  : cs.outline.withValues(alpha: 0.28),
                              width: _searchFocus.hasFocus ? 1.4 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            focusNode: _searchFocus,
                            textInputAction: TextInputAction.search,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search foods, categories...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.42),
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 22,
                                color: _searchFocus.hasFocus
                                    ? cs.primary
                                    : cs.onSurface.withValues(alpha: 0.55),
                              ),
                              suffixIcon: _searchCtrl.text.trim().isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear',
                                      splashRadius: 18,
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _searchOverlayEntry?.markNeedsBuild();
                                        if (!_searchFocus.hasFocus) {
                                          _searchFocus.requestFocus();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        size: 20,
                                        color: cs.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                            ),
                            onSubmitted: (_) => _searchFocus.unfocus(),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        style: IconButton.styleFrom(
                          foregroundColor: cs.onSurface.withValues(alpha: 0.7),
                        ),
                        onPressed: () => _setSearchOpen(false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: suggestions.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No matches yet — try another word.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const ClampingScrollPhysics(),
                            itemCount: suggestions.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: cs.onSurface.withValues(alpha: 0.08),
                            ),
                            itemBuilder: (context, i) {
                              final label = suggestions[i];
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                                title: Text(
                                  label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _searchCtrl.text = label;
                                    _searchCtrl.selection =
                                        TextSelection.collapsed(
                                          offset: label.length,
                                        );
                                  });
                                  _searchOverlayEntry?.markNeedsBuild();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final photo = widget.user.photoURL;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: CompositedTransformTarget(
        link: _searchLayerLink,
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onOpenProfile,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: photo != null && photo.isNotEmpty
                      ? Image.network(
                          photo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _AvatarFallback(),
                        )
                      : const _AvatarFallback(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? cs.onSurface.withValues(alpha: 0.7)
                          : MndBrandColors.blueMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('customers')
                        .doc(widget.user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final firestoreName = data?['fullName']?.toString();
                      final fallbackName = widget.user.displayName?.trim();
                      final rawName =
                          (firestoreName?.trim().isNotEmpty ?? false)
                          ? firestoreName!.trim()
                          : (fallbackName?.isNotEmpty ?? false)
                          ? fallbackName!
                          : 'Customer';
                      final name = _toTitleCase(rawName);

                      return Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          textStyle: theme.textTheme.titleMedium,
                          color: isDark ? cs.onSurface : MndBrandColors.navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              icon: Icons.search_rounded,
              onPressed: () => _setSearchOpen(!_searchOpen),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? cs.surfaceContainerHigh : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? cs.outlineVariant.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.92),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : MndBrandColors.navy).withValues(
                  alpha: isDark ? 0.22 : 0.08,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isDark ? cs.onSurface : MndBrandColors.navy,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MndBrandColors.tealBlue, MndBrandColors.royal],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
