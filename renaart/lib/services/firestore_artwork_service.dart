import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/artwork_model.dart';

/// Loads artworks from Cloud Firestore collection `artworks`.
///
/// Each document maps 1:1 to the bundled JSON schema, parsed via
/// [Artwork.fromLocalJson] (same field names).
class FirestoreArtworkService {
  FirestoreArtworkService._();
  static final FirestoreArtworkService instance = FirestoreArtworkService._();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('artworks');

  // In-memory cache so Firestore is only queried once per session
  List<Artwork>? _cache;

  Future<List<Artwork>> _load() async {
    if (_cache != null) return _cache!;
    try {
      final snapshot = await _collection.orderBy('artist').get();
      final artworks = <Artwork>[];
      for (final doc in snapshot.docs) {
        try {
          final a = Artwork.fromLocalJson(doc.data());
          if (a.imageUrl.isNotEmpty) artworks.add(a);
        } catch (_) {
          // Skip malformed documents
        }
      }
      _cache = artworks;
    } catch (_) {
      _cache = [];
    }
    return _cache!;
  }

  // ── Home Feed ─────────────────────────────────────────────────────────────
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 30}) async {
    final all = await _load();
    final shuffled = List<Artwork>.from(all)..shuffle();
    return shuffled.take(count).toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<Artwork>> searchArtworks(String query,
      {int maxCount = 20}) async {
    final all = await _load();
    if (query.isEmpty) return all.take(maxCount).toList();
    final q = query.toLowerCase();
    return all
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.artist.toLowerCase().contains(q) ||
            a.period.toLowerCase().contains(q) ||
            a.medium.toLowerCase().contains(q) ||
            a.description.toLowerCase().contains(q))
        .take(maxCount)
        .toList();
  }

  // ── Detail ────────────────────────────────────────────────────────────────
  Future<Artwork?> getArtwork(String id) async {
    final all = await _load();
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearCache() => _cache = null;
}
