import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});
  @override
  ConsumerState<CollectionScreen> createState() => _CollState();
}

class _CollState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final favs    = ref.watch(favoriteArtworksProvider);
    final offline = ref.watch(offlineArtworksProvider);
    final oCount  = ref.watch(offlineIdsProvider).length;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final text    = isDark ? AppColors.darkText   : AppColors.ink;
    final faint   = isDark ? AppColors.darkFaint  : AppColors.inkLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: Column(children: [
        // ── Header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Center(child: Text('My Collection', style: TextStyle(fontFamily: 'Cormorant',
              fontSize: 26, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
              color: text, letterSpacing: -0.5, height: 1.0))),
        ),
        const SizedBox(height: 8),
        
        // ── Tabs ───────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.canvasTone,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.inkHair, width: 0.8),
          ),
          child: TabBar(
            controller: _tab,
            indicator: BoxDecoration(
                color: isDark ? AppColors.darkText : AppColors.ink,
                borderRadius: BorderRadius.circular(7)),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: isDark ? AppColors.darkCanvas : Colors.white,
            unselectedLabelColor: isDark ? AppColors.darkSub : AppColors.inkMid,
            labelStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
                fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
                fontWeight: FontWeight.w400),
            tabs: [Tab(text: 'Liked (${favs.length})'), Tab(text: 'Offline ($oCount/${AppConstants.maxOfflineArtworks})')],
          ),
        ),
        const SizedBox(height: 10),
        // ── Content ────────────────────────────────────────────────
        Expanded(child: TabBarView(controller: _tab, children: [
          // Liked
          favs.isEmpty
              ? _Empty(icon: Icons.favorite_border,
                  title: 'No liked artworks yet',
                  body: 'Tap the heart on any artwork.', isDark: isDark)
              : MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
                  itemCount: favs.length,
                  itemBuilder: (_, i) => ArtworkCard(artwork: favs[i])),
          // Offline
          offline.isEmpty
              ? _Empty(icon: Icons.download_outlined,
                  title: 'No offline artworks',
                  body: 'Save artworks to view without internet.', isDark: isDark)
              : Column(children: [
                  Expanded(child: MasonryGridView.count(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
                    itemCount: offline.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onLongPress: () => _removeDialog(context, ref,
                          offline[i].id, isDark),
                      child: ArtworkCard(artwork: offline[i])),
                  )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Text('Long press to remove from offline',
                      style: TextStyle(fontFamily: 'Jost', fontSize: 11,
                          color: faint), textAlign: TextAlign.center),
                  ),
                ]),
        ])),
      ])),
    );
  }

  void _removeDialog(BuildContext ctx, WidgetRef ref, String id, bool isDark) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.canvasCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text('Remove offline?', style: TextStyle(fontFamily: 'Cormorant',
          fontSize: 20, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.ink)),
      content: Text('This artwork will require internet to view.',
        style: TextStyle(fontFamily: 'Jost', fontSize: 13,
            color: isDark ? AppColors.darkSub : AppColors.inkMid)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: TextStyle(fontFamily: 'Jost',
              color: isDark ? AppColors.darkFaint : AppColors.inkLight))),
        TextButton(
          onPressed: () { ref.read(offlineIdsProvider.notifier).remove(id); Navigator.pop(ctx); },
          child: const Text('Remove', style: TextStyle(fontFamily: 'Jost',
              color: AppColors.heartRed, fontWeight: FontWeight.w600))),
      ],
    ));
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────
class _Empty extends StatelessWidget {
  final IconData icon; final String title, body; final bool isDark;
  const _Empty({required this.icon, required this.title, required this.body, required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 38, color: isDark ? AppColors.darkFaint : AppColors.inkLight),
    const SizedBox(height: 14),
    Text(title, style: TextStyle(fontFamily: 'Cormorant', fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkSub : AppColors.inkMid)),
    const SizedBox(height: 6),
    Text(body, style: TextStyle(fontFamily: 'Jost', fontSize: 13,
        color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
  ]));
}
