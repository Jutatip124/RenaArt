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
  void dispose() { _ctrl.dispose(); _focusNode.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final results  = ref.watch(searchResultsProvider);
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final faint    = isDark ? AppColors.darkFaint  : AppColors.inkLight;

    final hasFilters = ref.watch(searchArtistFilterProvider) != null
        || ref.watch(searchPeriodFilterProvider) != null
        || ref.watch(searchMediumFilterProvider) != null
        || ref.watch(searchSubjectFilterProvider) != null
        || ref.watch(searchRegionFilterProvider) != null;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: Column(children: [
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
            Text('RenaArt', style: TextStyle(fontFamily: 'Cormorant', fontSize: 26,
                fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkText : AppColors.ink,
                letterSpacing: -0.5, height: 1.0)),
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
                  onChanged: (v) {
                    ref.read(searchQueryProvider.notifier).state = v;
                    setState(() => _showSuggestions = v.trim().isNotEmpty);
                  },
                  onSubmitted: (_) => setState(() => _showSuggestions = false),
                  decoration: InputDecoration(
                    hintText: 'Search artworks, artists...',
                    prefixIcon: Icon(Icons.search, size: 17, color: faint),
                    suffixIcon: _ctrl.text.isNotEmpty ? IconButton(
                      icon: Icon(Icons.close, size: 15, color: faint),
                      onPressed: () {
                        _ctrl.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                        setState(() => _showSuggestions = false);
                      },
                    ) : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter toggle
              GestureDetector(
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 42, height: 42,
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
                  child: Icon(Icons.tune, size: 17,
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
                  _ctrl.selection = TextSelection.collapsed(offset: text.length);
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
              ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox.shrink(),
          secondChild: _FilterPanel(isDark: isDark),
        ),
        // ── Count + clear ──────────────────────────────────────────
        results.when(
          loading: () => const SizedBox(height: 6),
          error:   (_, __) => const SizedBox.shrink(),
          data:    (list) => Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
            child: Row(children: [
              Text('${list.length} results', style: TextStyle(fontFamily: 'Jost',
                  fontSize: 11, color: faint)),
              const Spacer(),
              if (hasFilters) GestureDetector(
                onTap: () {
                  ref.read(searchArtistFilterProvider.notifier).state = null;
                  ref.read(searchPeriodFilterProvider.notifier).state = null;
                  ref.read(searchMediumFilterProvider.notifier).state = null;
                  ref.read(searchSubjectFilterProvider.notifier).state = null;
                  ref.read(searchRegionFilterProvider.notifier).state = null;
                },
                child: Text('Clear all', style: TextStyle(fontFamily: 'Jost',
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.gold : AppColors.ink,
                    decoration: TextDecoration.underline,
                    decorationColor: isDark ? AppColors.gold : AppColors.ink)),
              ),
            ]),
          ),
        ),
        // ── Results ────────────────────────────────────────────────
        Expanded(child: results.when(
          loading: () => Center(child: SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 1.5,
                color: isDark ? AppColors.gold : AppColors.ink))),
          error:   (e, _) => Center(child: Text('Error: $e',
              style: const TextStyle(fontFamily: 'Jost', fontSize: 13))),
          data:    (list) {
            if (list.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search_off, size: 38,
                    color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                const SizedBox(height: 12),
                Text('Nothing found', style: TextStyle(fontFamily: 'Cormorant',
                    fontSize: 20, color: isDark ? AppColors.darkSub : AppColors.inkMid)),
              ]));
            }
            return MasonryGridView.count(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
              crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
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
    final artistF  = ref.watch(searchArtistFilterProvider);
    final periodF  = ref.watch(searchPeriodFilterProvider);
    final mediumF  = ref.watch(searchMediumFilterProvider);
    final subjectF = ref.watch(searchSubjectFilterProvider);
    final regionF  = ref.watch(searchRegionFilterProvider);
    final faint    = isDark ? AppColors.darkFaint : AppColors.inkLight;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.canvasCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.inkHair,
              width: isDark ? 0.5 : 0.8),
        ),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FilterGroup('ARTIST', faint, AppStrings.popularArtists.map((a) =>
          _Chip(a, artistF == a, isDark, () => ref.read(searchArtistFilterProvider.notifier)
              .state = artistF == a ? null : a)).toList()),
        const SizedBox(height: 12),
        _FilterGroup('PERIOD', faint, AppStrings.periods.skip(1).map((p) =>
          _Chip(p, periodF == p, isDark, () => ref.read(searchPeriodFilterProvider.notifier)
              .state = periodF == p ? null : p)).toList()),
        const SizedBox(height: 12),
        _FilterGroup('ART FORM', faint, AppStrings.artForms.map((m) =>
          _Chip(m, mediumF == m, isDark, () => ref.read(searchMediumFilterProvider.notifier)
              .state = mediumF == m ? null : m)).toList()),
        const SizedBox(height: 12),
        _FilterGroup('SUBJECT', faint, AppStrings.subjects.map((s) =>
          _Chip(s, subjectF == s, isDark, () => ref.read(searchSubjectFilterProvider.notifier)
              .state = subjectF == s ? null : s)).toList()),
        const SizedBox(height: 12),
        _FilterGroup('REGION', faint, AppStrings.regions.map((r) =>
          _Chip(r, regionF == r, isDark, () => ref.read(searchRegionFilterProvider.notifier)
              .state = regionF == r ? null : r)).toList()),
      ])),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label; final Color color; final List<Widget> chips;
  const _FilterGroup(this.label, this.color, this.chips);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontFamily: 'Jost', fontSize: 9,
          fontWeight: FontWeight.w600, letterSpacing: 1.4, color: color)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: chips),
    ],
  );
}

class _Chip extends StatelessWidget {
  final String label; final bool selected; final bool isDark; final VoidCallback onTap;
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
      child: Text(label, style: TextStyle(fontFamily: 'Jost', fontSize: 12,
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
    required this.query, required this.isDark, required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) return const SizedBox.shrink();

    final cached = ref.watch(storageProvider).getAllCachedArtworks();
    final q = query.toLowerCase();

    // Collect unique matching titles and artists
    final titleMatches = <String>[];
    final artistMatches = <String>{};

    for (final a in cached) {
      if (a.title.toLowerCase().contains(q)) {
        titleMatches.add(a.title);
      }
      if (a.artist.toLowerCase().contains(q) &&
          a.artist.toLowerCase() != 'unknown artist') {
        artistMatches.add(a.artist);
      }
    }

    // Build suggestion list: artists first, then titles (max 6 total)
    final suggestions = <_Suggestion>[
      for (final artist in artistMatches.take(2))
        _Suggestion(artist, SuggestionType.artist),
      for (final title in titleMatches.take(4))
        _Suggestion(title, SuggestionType.title),
    ];

    if (suggestions.isEmpty) return const SizedBox.shrink();

    // Limit to 6 suggestions
    final limited = suggestions.take(6).toList();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.canvasCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.inkHair, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: limited.map((s) => _SuggestionTile(
          suggestion: s, query: q, isDark: isDark,
          onTap: () => onSelect(s.type == SuggestionType.artist ? s.text : s.text),
        )).toList(),
      ),
    );
  }
}

enum SuggestionType { title, artist }

class _Suggestion {
  final String text;
  final SuggestionType type;
  const _Suggestion(this.text, this.type);
}

class _SuggestionTile extends StatelessWidget {
  final _Suggestion suggestion;
  final String query;
  final bool isDark;
  final VoidCallback onTap;
  const _SuggestionTile({
    required this.suggestion, required this.query,
    required this.isDark, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArtist = suggestion.type == SuggestionType.artist;
    final text = suggestion.text;
    final sub = isDark ? AppColors.darkSub : AppColors.inkMid;
    final accent = isDark ? AppColors.gold : AppColors.ink;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.inkHair, width: 0.4)),
        ),
        child: Row(children: [
          Icon(
            isArtist ? Icons.person_outline : Icons.image_outlined,
            size: 16, color: sub,
          ),
          const SizedBox(width: 10),
          Expanded(child: _HighlightText(
            text: text, query: query,
            baseStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                fontWeight: FontWeight.w400, color: sub),
            highlightStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                fontWeight: FontWeight.w600, color: accent),
          )),
          if (isArtist)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gold : AppColors.ink).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('Artist', style: TextStyle(fontFamily: 'Jost', fontSize: 9,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5, color: accent)),
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
    required this.text, required this.query,
    required this.baseStyle, required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);

    final lower = text.toLowerCase();
    final idx = lower.indexOf(query);
    if (idx < 0) return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);

    return RichText(
      maxLines: 1, overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx), style: baseStyle),
        TextSpan(text: text.substring(idx, idx + query.length), style: highlightStyle),
        if (idx + query.length < text.length)
          TextSpan(text: text.substring(idx + query.length), style: baseStyle),
      ]),
    );
  }
}
