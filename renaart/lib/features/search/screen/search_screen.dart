// Search screen — header, search bar with autocomplete, filter panel, and
// masonry results grid.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _showFilters = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Delay hide so tap on suggestion registers first
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final faint = isDark ? AppColors.darkFaint : AppColors.inkLight;
    final columns =
        AppConstants.masonryColumnsForWidth(MediaQuery.sizeOf(context).width);

    final hasFilters = ref.watch(searchArtistFilterProvider) != null ||
        ref.watch(searchPeriodFilterProvider) != null ||
        ref.watch(searchMediumFilterProvider) != null ||
        ref.watch(searchSubjectFilterProvider) != null ||
        ref.watch(searchRegionFilterProvider) != null;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
          child: Column(children: [
        // ── Header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : AppColors.ink,
                BlendMode.srcIn,
              ),
              child: Image.asset('assets/images/logo_dark.png',
                  width: 28, height: 28),
            ),
            const SizedBox(width: 8),
            Text('RenaArt',
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                    letterSpacing: -0.5,
                    height: 1.0)),
          ]),
        ),
        // ── Search bar + autocomplete ──────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  maxLength: 100, // Limit search query length for performance
                  onChanged: (v) {
                    // Limit query length to prevent performance issues
                    final limited = v.length > 100 ? v.substring(0, 100) : v;
                    ref.read(searchQueryProvider.notifier).state = limited;
                    setState(
                        () => _showSuggestions = limited.trim().isNotEmpty);
                  },
                  onSubmitted: (_) => setState(() => _showSuggestions = false),
                  decoration: InputDecoration(
                    hintText: 'Search artworks, artists...',
                    counterText: '', // Hide character counter
                    prefixIcon: Icon(Icons.search, size: 17, color: faint),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, size: 15, color: faint),
                            onPressed: () {
                              _ctrl.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                              setState(() => _showSuggestions = false);
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter toggle
              GestureDetector(
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasFilters
                        ? (isDark ? AppColors.gold : AppColors.ink)
                        : (isDark ? AppColors.darkCard : AppColors.canvasCard),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: hasFilters
                          ? (isDark ? AppColors.gold : AppColors.ink)
                          : (isDark ? AppColors.darkBorder : AppColors.inkHair),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(Icons.tune,
                      size: 17,
                      color: hasFilters
                          ? (isDark ? AppColors.darkCanvas : Colors.white)
                          : (isDark ? AppColors.darkSub : AppColors.inkMid)),
                ),
              ),
            ]),
            // ── Autocomplete suggestions ───────────────────────────
            if (_showSuggestions)
              _SuggestionDropdown(
                query: _ctrl.text.trim(),
                isDark: isDark,
                onSelect: (text) {
                  _ctrl.text = text;
                  _ctrl.selection =
                      TextSelection.collapsed(offset: text.length);
                  ref.read(searchQueryProvider.notifier).state = text;
                  setState(() => _showSuggestions = false);
                  _focusNode.unfocus();
                },
              ),
          ]),
        ),
        // ── Filter panel ───────────────────────────────────────────
        AnimatedCrossFade(
          crossFadeState: _showFilters
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox.shrink(),
          secondChild: _FilterPanel(isDark: isDark),
        ),
        // ── Count + clear ──────────────────────────────────────────
        results.when(
          loading: () => const SizedBox(height: 6),
          error: (_, __) => const SizedBox.shrink(),
          data: (list) => Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
            child: Row(children: [
              Text('${list.length} results',
                  style: TextStyle(
                      fontFamily: 'Jost', fontSize: 11, color: faint)),
              const Spacer(),
              if (hasFilters)
                GestureDetector(
                  onTap: () {
                    ref.read(searchArtistFilterProvider.notifier).state = null;
                    ref.read(searchPeriodFilterProvider.notifier).state = null;
                    ref.read(searchMediumFilterProvider.notifier).state = null;
                    ref.read(searchSubjectFilterProvider.notifier).state = null;
                    ref.read(searchRegionFilterProvider.notifier).state = null;
                  },
                  child: Text('Clear all',
                      style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.gold : AppColors.ink,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              isDark ? AppColors.gold : AppColors.ink)),
                ),
            ]),
          ),
        ),
        // ── Results ────────────────────────────────────────────────
        Expanded(
            child: results.when(
          loading: () => Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isDark ? AppColors.gold : AppColors.ink))),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(fontFamily: 'Jost', fontSize: 13))),
          data: (list) {
            if (list.isEmpty) {
              return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search_off,
                    size: 38,
                    color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                const SizedBox(height: 12),
                Text('Nothing found',
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 20,
                        color: isDark ? AppColors.darkSub : AppColors.inkMid)),
              ]));
            }
            return MasonryGridView.count(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: list.length,
              itemBuilder: (_, i) => ArtworkCard(artwork: list[i]),
            );
          },
        )),
      ])),
    );
  }
}

// ─── Filter panel ─────────────────────────────────────────────────────────────
class _FilterPanel extends ConsumerWidget {
  final bool isDark;
  const _FilterPanel({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);
    final artistF = ref.watch(searchArtistFilterProvider);
    final periodF = ref.watch(searchPeriodFilterProvider);
    final mediumF = ref.watch(searchMediumFilterProvider);
    final subjectF = ref.watch(searchSubjectFilterProvider);
    final regionF = ref.watch(searchRegionFilterProvider);
    final faint = isDark ? AppColors.darkFaint : AppColors.inkLight;
    final availableHeight = media.size.height - media.viewInsets.bottom;
    const chipPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 5);
    const chipSpacing = 6.0;
    const chipRunSpacing = 6.0;
    const labelSpacing = 8.0;
    const panelPadding = 16.0;
    const panelMargin = 16.0;
    const labelMeasureStyle = TextStyle(
      fontFamily: 'Jost',
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
    );
    const chipMeasureStyle = TextStyle(
      fontFamily: 'Jost',
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    return LayoutBuilder(builder: (context, constraints) {
      final innerWidth =
          (constraints.maxWidth - (panelMargin * 2) - (panelPadding * 2))
              .clamp(0.0, constraints.maxWidth)
              .toDouble();
      final artistGroupHeight = _estimateFilterGroupHeight(
        label: 'ARTIST',
        labels: AppStrings.popularArtists,
        maxWidth: innerWidth,
        labelStyle: labelMeasureStyle,
        chipStyle: chipMeasureStyle,
        chipPadding: chipPadding,
        spacing: chipSpacing,
        runSpacing: chipRunSpacing,
        labelSpacing: labelSpacing,
      );
      final targetHeight = (artistGroupHeight + (panelPadding * 2))
          .clamp(0.0, availableHeight * 0.45)
          .toDouble();

      return SizedBox(
        height: targetHeight,
        child: Container(
          margin: const EdgeInsets.fromLTRB(panelMargin, 10, panelMargin, 0),
          padding: const EdgeInsets.all(panelPadding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.canvasCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.inkHair,
                width: isDark ? 0.5 : 0.8),
          ),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _FilterGroup(
                    'ARTIST',
                    faint,
                    AppStrings.popularArtists
                        .map((a) => _Chip(
                            a,
                            artistF == a,
                            isDark,
                            () => ref
                                .read(searchArtistFilterProvider.notifier)
                                .state = artistF == a ? null : a))
                        .toList()),
                const SizedBox(height: 12),
                _FilterGroup(
                    'PERIOD',
                    faint,
                    AppStrings.periods
                        .skip(1)
                        .map((p) => _Chip(
                            p,
                            periodF == p,
                            isDark,
                            () => ref
                                .read(searchPeriodFilterProvider.notifier)
                                .state = periodF == p ? null : p))
                        .toList()),
                const SizedBox(height: 12),
                _FilterGroup(
                    'ART FORM',
                    faint,
                    AppStrings.artForms
                        .map((m) => _Chip(
                            m,
                            mediumF == m,
                            isDark,
                            () => ref
                                .read(searchMediumFilterProvider.notifier)
                                .state = mediumF == m ? null : m))
                        .toList()),
                const SizedBox(height: 12),
                _FilterGroup(
                    'SUBJECT',
                    faint,
                    AppStrings.subjects
                        .map((s) => _Chip(
                            s,
                            subjectF == s,
                            isDark,
                            () => ref
                                .read(searchSubjectFilterProvider.notifier)
                                .state = subjectF == s ? null : s))
                        .toList()),
                const SizedBox(height: 12),
                _FilterGroup(
                    'REGION',
                    faint,
                    AppStrings.regions
                        .map((r) => _Chip(
                            r,
                            regionF == r,
                            isDark,
                            () => ref
                                .read(searchRegionFilterProvider.notifier)
                                .state = regionF == r ? null : r))
                        .toList()),
              ])),
        ),
      );
    });
  }
}

double _estimateFilterGroupHeight({
  required String label,
  required List<String> labels,
  required double maxWidth,
  required TextStyle labelStyle,
  required TextStyle chipStyle,
  required EdgeInsets chipPadding,
  required double spacing,
  required double runSpacing,
  required double labelSpacing,
}) {
  if (labels.isEmpty || maxWidth <= 0) return 0;
  final labelPainter = TextPainter(
    text: TextSpan(text: label, style: labelStyle),
    textDirection: TextDirection.ltr,
  )..layout();

  final chipPainter = TextPainter(textDirection: TextDirection.ltr);
  chipPainter.text = TextSpan(text: 'Ay', style: chipStyle);
  chipPainter.layout();
  final chipHeight = chipPainter.height + chipPadding.vertical;

  var rowWidth = 0.0;
  var rows = 1;
  for (final item in labels) {
    chipPainter.text = TextSpan(text: item, style: chipStyle);
    chipPainter.layout();
    final chipWidth = chipPainter.width + chipPadding.horizontal;
    if (rowWidth == 0) {
      rowWidth = chipWidth;
      continue;
    }
    if (rowWidth + spacing + chipWidth <= maxWidth) {
      rowWidth += spacing + chipWidth;
    } else {
      rows += 1;
      rowWidth = chipWidth;
    }
  }

  final wrapHeight = (rows * chipHeight) + ((rows - 1) * runSpacing);
  return labelPainter.height + labelSpacing + wrapHeight;
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final Color color;
  final List<Widget> chips;
  const _FilterGroup(this.label, this.color, this.chips);
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: color)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: chips),
        ],
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _Chip(this.label, this.selected, this.isDark, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppColors.gold : AppColors.ink)
                : (isDark ? AppColors.darkRaised : AppColors.canvas),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected
                  ? (isDark ? AppColors.gold : AppColors.ink)
                  : (isDark ? AppColors.darkBorder : AppColors.inkHair),
              width: 0.8,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? (isDark ? AppColors.darkCanvas : Colors.white)
                      : (isDark ? AppColors.darkSub : AppColors.inkMid))),
        ),
      );
}

// ─── Autocomplete Suggestion Dropdown ─────────────────────────────────────────
class _SuggestionDropdown extends ConsumerWidget {
  final String query;
  final bool isDark;
  final ValueChanged<String> onSelect;
  const _SuggestionDropdown({
    required this.query,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) return const SizedBox.shrink();

    final cached = ref.watch(storageProvider).getAllCachedArtworks();
    final q = query.toLowerCase().trim();
    
    // Collect suggestions with relevance scoring
    final scoredSuggestions = <_ScoredSuggestion>[];
    final seenTexts = <String>{};
    
    for (final a in cached) {
      final titleLower = a.title.toLowerCase();
      final artistLower = a.artist.toLowerCase();
      final periodLower = a.period.toLowerCase();
      final subjectLower = a.subject.toLowerCase();
      final mediumLower = a.medium.toLowerCase();
      
      // Title match (highest priority)
      if (titleLower.contains(q) && !seenTexts.contains(a.title)) {
        final score = titleLower.startsWith(q) ? 100 : 80;
        scoredSuggestions.add(_ScoredSuggestion(a.title, SuggestionType.title, score));
        seenTexts.add(a.title);
      }
      
      // Artist match (high priority)
      if (artistLower.contains(q) && 
          artistLower != 'unknown artist' &&
          !seenTexts.contains(a.artist)) {
        final score = artistLower.startsWith(q) ? 95 : 75;
        scoredSuggestions.add(_ScoredSuggestion(a.artist, SuggestionType.artist, score));
        seenTexts.add(a.artist);
      }
      
      // Period match (e.g. "Renaissance", "Baroque")
      if (periodLower.contains(q) && !seenTexts.contains(a.period)) {
        final score = periodLower.startsWith(q) ? 70 : 50;
        scoredSuggestions.add(_ScoredSuggestion(a.period, SuggestionType.period, score));
        seenTexts.add(a.period);
      }
      
      // Subject match (e.g. "Religious", "Portrait", "Landscape")
      if (subjectLower.contains(q) && !seenTexts.contains(a.subject)) {
        final score = subjectLower.startsWith(q) ? 65 : 45;
        scoredSuggestions.add(_ScoredSuggestion(a.subject, SuggestionType.subject, score));
        seenTexts.add(a.subject);
      }
      
      // Medium match (e.g. "Oil on canvas", "Fresco")
      if (mediumLower.contains(q) && a.medium.isNotEmpty && !seenTexts.contains(a.medium)) {
        final score = mediumLower.startsWith(q) ? 60 : 40;
        scoredSuggestions.add(_ScoredSuggestion(a.medium, SuggestionType.medium, score));
        seenTexts.add(a.medium);
      }
      
      // Key symbols match (e.g. "Madonna", "Christ", "Angel")
      for (final symbol in a.keySymbols) {
        final symbolLower = symbol.toLowerCase();
        if (symbolLower.contains(q) && !seenTexts.contains(symbol)) {
          final score = symbolLower.startsWith(q) ? 55 : 35;
          scoredSuggestions.add(_ScoredSuggestion(symbol, SuggestionType.keyword, score));
          seenTexts.add(symbol);
        }
      }
    }

    if (scoredSuggestions.isEmpty) return const SizedBox.shrink();
    
    // Sort by score (highest first) and take top 6
    scoredSuggestions.sort((a, b) => b.score.compareTo(a.score));
    final limited = scoredSuggestions.take(6).toList();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.canvasCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.inkHair,
            width: 0.8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: limited
            .map((s) => _SuggestionTile(
                  suggestion: s,
                  query: q,
                  isDark: isDark,
                  onTap: () => onSelect(s.text),
                ))
            .toList(),
      ),
    );
  }
}

enum SuggestionType { title, artist, period, subject, medium, keyword }

class _ScoredSuggestion {
  final String text;
  final SuggestionType type;
  final int score;
  const _ScoredSuggestion(this.text, this.type, this.score);
}

class _SuggestionTile extends StatelessWidget {
  final _ScoredSuggestion suggestion;
  final String query;
  final bool isDark;
  final VoidCallback onTap;
  const _SuggestionTile({
    required this.suggestion,
    required this.query,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = suggestion.type;
    final text = suggestion.text;
    final sub = isDark ? AppColors.darkSub : AppColors.inkMid;
    final accent = isDark ? AppColors.gold : AppColors.ink;
    
    // Icon and label based on suggestion type
    IconData icon;
    String typeLabel;
    switch (type) {
      case SuggestionType.artist:
        icon = Icons.person_outline;
        typeLabel = 'Artist';
        break;
      case SuggestionType.title:
        icon = Icons.image_outlined;
        typeLabel = 'Artwork';
        break;
      case SuggestionType.period:
        icon = Icons.history;
        typeLabel = 'Period';
        break;
      case SuggestionType.subject:
        icon = Icons.category_outlined;
        typeLabel = 'Subject';
        break;
      case SuggestionType.medium:
        icon = Icons.brush_outlined;
        typeLabel = 'Medium';
        break;
      case SuggestionType.keyword:
        icon = Icons.label_outline;
        typeLabel = 'Keyword';
        break;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.inkHair,
                  width: 0.4)),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: sub),
          const SizedBox(width: 10),
          Expanded(
              child: _HighlightText(
            text: text,
            query: query,
            baseStyle: TextStyle(
                fontFamily: 'Jost',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: sub),
            highlightStyle: TextStyle(
                fontFamily: 'Jost',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent),
          )),
          // Show type label badge for non-artwork types
          if (type != SuggestionType.title)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gold : AppColors.ink)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(typeLabel,
                  style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: accent)),
            ),
        ]),
      ),
    );
  }
}

/// Highlights the matching portion of text in bold.
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;
  const _HighlightText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final idx = lower.indexOf(query);
    if (idx < 0) {
      return Text(text,
          style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx), style: baseStyle),
        TextSpan(
            text: text.substring(idx, idx + query.length),
            style: highlightStyle),
        if (idx + query.length < text.length)
          TextSpan(text: text.substring(idx + query.length), style: baseStyle),
      ]),
    );
  }
}
