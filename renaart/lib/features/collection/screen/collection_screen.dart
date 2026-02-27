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
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Collection', style: TextStyle(fontFamily: 'Cormorant',
                fontSize: 28, fontWeight: FontWeight.w700, color: text,
                letterSpacing: -0.6)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(Icons.favorite, size: 11, color: AppColors.heartRed),
              const SizedBox(width: 4),
              Text('${favs.length} liked', style: TextStyle(fontFamily: 'Jost',
                  fontSize: 11, color: faint)),
              const SizedBox(width: 12),
              Icon(Icons.download_done, size: 11, color: AppColors.saveBlue),
              const SizedBox(width: 4),
              Text('$oCount/${AppConstants.maxOfflineArtworks} saved',
                style: TextStyle(fontFamily: 'Jost', fontSize: 11, color: faint)),
            ]),
          ]),
        ),
        if (_tab.index == 1)
          _StorageBar(count: oCount, max: AppConstants.maxOfflineArtworks, isDark: isDark),
        const SizedBox(height: 14),
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
            tabs: const [Tab(text: 'Liked'), Tab(text: 'Offline')],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(child: TabBarView(controller: _tab, children: [
          favs.isEmpty
              ? _Empty(icon: Icons.favorite_border, title: 'No liked artworks yet',
                  body: 'Tap the heart on any artwork.', isDark: isDark)
              : MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
                  itemCount: favs.length,
                  itemBuilder: (_, i) => ArtworkCard(artwork: favs[i])),
          offline.isEmpty
              ? _Empty(icon: Icons.download_outlined, title: 'No offline artworks',
                  body: 'Save artworks to view without internet.', isDark: isDark)
              : Column(children: [
                  Expanded(child: MasonryGridView.count(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
                    itemCount: offline.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onLongPress: () => _removeDialog(context, ref, offline[i].id, isDark),
                      child: ArtworkCard(artwork: offline[i])),
                  )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Text('Long press to remove from offline',
                      style: TextStyle(fontFamily: 'Jost', fontSize: 11, color: faint),
                      textAlign: TextAlign.center),
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
          onPressed: () {
            ref.read(offlineIdsProvider.notifier).remove(id);
            Navigator.pop(ctx);
          },
          child: const Text('Remove', style: TextStyle(fontFamily: 'Jost',
              color: AppColors.heartRed, fontWeight: FontWeight.w600))),
      ],
    ));
  }
}

class _StorageBar extends StatelessWidget {
  final int count, max; final bool isDark;
  const _StorageBar({required this.count, required this.max, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.canvasCard,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.inkHair, width: 0.8),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Offline Library', style: TextStyle(fontFamily: 'Jost', fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkText : AppColors.ink)),
        Text('$count/$max artworks', style: TextStyle(fontFamily: 'Jost',
            fontSize: 13, fontWeight: FontWeight.w600,
            color: count >= max ? AppColors.heartRed : AppColors.saveBlue)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(value: count / max, minHeight: 4,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.inkHair,
            color: count >= max ? AppColors.heartRed : AppColors.saveBlue)),
    ]),
  );
}

class _Empty extends StatelessWidget {
  final IconData icon; final String title, body; final bool isDark;
  const _Empty({required this.icon, required this.title,
      required this.body, required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min,
    children: [
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