import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:renaart/models/artwork.dart';
import 'package:renaart/shared/widgets/artwork_card.dart';

class ArtworkMasonryGrid extends StatelessWidget {
  final List<Artwork> artworks;
  final EdgeInsets? padding;

  const ArtworkMasonryGrid({
    super.key,
    required this.artworks,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: padding ?? const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: artworks.length,
      itemBuilder: (_, i) => ArtworkCard(artwork: artworks[i]),
    );
  }
}
