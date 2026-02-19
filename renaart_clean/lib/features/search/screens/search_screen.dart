import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/services/providers.dart';
import 'package:renaart/shared/widgets/artwork_masonry_grid.dart';

// Local state for search UI
final _searchQueryProvider = StateProvider<String>((_) => '');
final _selectedMediumProvider = StateProvider<String?>((_) => null);
final _selectedPeriodProvider = StateProvider<String?>((_) => null);
final _searchParamsProvider = StateProvider<SearchParams>(
    (_) => const SearchParams(query: 'renaissance painting'));

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _ctrl;

  static const _mediums = ['Paintings', 'Drawings', 'Prints', 'Sculpture'];
  static const _periods = [
    ('1400–1450', 1400, 1450),
    ('1450–1500', 1450, 1500),
    ('1500–1550', 1500, 1550),
    ('1550–1600', 1550, 1600),
  ];
  static const _artists = [
    'Raphael',
    'Leonardo da Vinci',
    'Michelangelo',
    'Botticelli',
    'Titian',
    'Dürer',
  ];

  String? _selectedArtist;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _applySearch() {
    final q = _ctrl.text.trim();
    final medium = ref.read(_selectedMediumProvider);
    final periodIndex = ref.read(_selectedPeriodProvider);

    int? dateBegin, dateEnd;
    if (periodIndex != null) {
      final match = _periods.where((p) => p.$1 == periodIndex).firstOrNull;
      if (match != null) {
        dateBegin = match.$2;
        dateEnd = match.$3;
      }
    }

    final query = _selectedArtist != null
        ? _selectedArtist!
        : q.isEmpty
            ? 'renaissance'
            : q;

    ref.read(_searchParamsProvider.notifier).state = SearchParams(
      query: query,
      medium: medium,
      dateBegin: dateBegin,
      dateEnd: dateEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(_searchParamsProvider);
    final resultsAsync = ref.watch(searchResultsProvider(params));
    final selectedMedium = ref.watch(_selectedMediumProvider);
    final selectedPeriod = ref.watch(_selectedPeriodProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Title ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Art Discovery',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),

            // ── Search Bar ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _applySearch(),
                  decoration: InputDecoration(
                    hintText: 'Search artworks, artists, periods…',
                    hintStyle: TextStyle(color: AppColors.stone, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.stone),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _ctrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.parchment,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.gold, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            // ── Filter: Artist ───────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterSection(
                label: 'Creator',
                children: _artists.map((a) {
                  return FilterChip(
                    label: Text(a),
                    selected: _selectedArtist == a,
                    onSelected: (v) {
                      setState(() => _selectedArtist = v ? a : null);
                      _applySearch();
                    },
                  );
                }).toList(),
              ),
            ),

            // ── Filter: Medium ───────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterSection(
                label: 'Medium',
                children: _mediums.map((m) {
                  return FilterChip(
                    label: Text(m),
                    selected: selectedMedium == m,
                    onSelected: (v) {
                      ref.read(_selectedMediumProvider.notifier).state =
                          v ? m : null;
                      _applySearch();
                    },
                  );
                }).toList(),
              ),
            ),

            // ── Filter: Period ───────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterSection(
                label: 'Year Range',
                children: _periods.map((p) {
                  return FilterChip(
                    label: Text(p.$1),
                    selected: selectedPeriod == p.$1,
                    onSelected: (v) {
                      ref.read(_selectedPeriodProvider.notifier).state =
                          v ? p.$1 : null;
                      _applySearch();
                    },
                  );
                }).toList(),
              ),
            ),

            // ── Divider + count ──────────────────────────────────
            SliverToBoxAdapter(
              child: resultsAsync.whenOrNull(
                data: (list) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${list.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink),
                            ),
                            TextSpan(
                              text: ' artworks found',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedArtist = null);
                          ref
                              .read(_selectedMediumProvider.notifier)
                              .state = null;
                          ref
                              .read(_selectedPeriodProvider.notifier)
                              .state = null;
                          _ctrl.clear();
                          _applySearch();
                        },
                        child: Text(
                          'Clear filters',
                          style: TextStyle(
                              color: AppColors.sienna,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ) ??
                  const SizedBox.shrink(),
            ),

            // ── Results ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: resultsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: AppColors.sienna),
                  ),
                ),
                error: (_, __) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Failed to search. Check your connection.'),
                  ),
                ),
                data: (artworks) => artworks.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No artworks found. Try different filters.'),
                        ),
                      )
                    : ArtworkMasonryGrid(artworks: artworks),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FilterSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: children),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFEDE5D8), height: 1),
        ],
      ),
    );
  }
}
