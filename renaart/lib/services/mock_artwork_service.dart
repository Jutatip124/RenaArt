import '../models/artwork_model.dart';

class MockArtworkService {
  MockArtworkService._();
  static final MockArtworkService instance = MockArtworkService._();

  late final List<Artwork> _artworks = _buildMockArtworks();

  List<Artwork> getAllArtworks() => List<Artwork>.unmodifiable(_artworks);

  Future<List<Artwork>> fetchRenaissanceFeed({int count = 20}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final safeCount = count > _artworks.length ? _artworks.length : count;
    return _artworks.take(safeCount).toList();
  }

  Future<List<Artwork>> searchArtworks(String query, {int maxCount = 60}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final normalizedQuery = query.trim().toLowerCase();

    final filtered = _artworks.where((artwork) {
      if (normalizedQuery.isEmpty) return true;
      return artwork.title.toLowerCase().contains(normalizedQuery) ||
          artwork.artist.toLowerCase().contains(normalizedQuery) ||
          artwork.medium.toLowerCase().contains(normalizedQuery) ||
          artwork.period.toLowerCase().contains(normalizedQuery);
    }).toList();

    final safeCount = maxCount > filtered.length ? filtered.length : maxCount;
    return filtered.take(safeCount).toList();
  }

  Future<Artwork?> getArtwork(String id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    for (final artwork in _artworks) {
      if (artwork.id == id) return artwork;
    }
    return null;
  }

  List<Artwork> _buildMockArtworks() {
    final seeds = <_ArtistSeed>[
      _ArtistSeed(
        artist: 'Leonardo da Vinci',
        period: 'High Renaissance',
        works: const [
          _WorkSeed('Mona Lisa', 'Painting (Oil)'),
          _WorkSeed('The Last Supper', 'Fresco'),
          _WorkSeed('Vitruvian Man', 'Drawing (Sketch)'),
          _WorkSeed('Lady with an Ermine', 'Painting (Oil)'),
          _WorkSeed('Salvator Mundi', 'Painting (Oil)'),
          _WorkSeed('Virgin of the Rocks (Louvre version)', 'Painting (Oil)'),
          _WorkSeed('Virgin of the Rocks (London version)', 'Painting (Oil)'),
          _WorkSeed('The Baptism of Christ (with Verrocchio)', 'Painting (Tempera/Oil)'),
          _WorkSeed('Annunciation', 'Painting (Oil/Tempera)'),
          _WorkSeed("Ginevra de' Benci", 'Painting (Oil)'),
          _WorkSeed('St. John the Baptist', 'Painting (Oil)'),
          _WorkSeed('The Virgin and Child with Saint Anne', 'Painting (Oil)'),
          _WorkSeed('Adoration of the Magi', 'Painting (Oil)'),
          _WorkSeed('Portrait of a Musician', 'Painting (Oil)'),
          _WorkSeed('Head of a Woman (La Scapigliata)', 'Drawing (Earth/Amber)'),
          _WorkSeed('Flying Machine Design', 'Scientific Drawing'),
          _WorkSeed('Aerial Screw (Helicopter ancestor)', 'Scientific Drawing'),
          _WorkSeed('Armoured Car (Tank design)', 'Scientific Drawing'),
          _WorkSeed('Anatomical Studies of the Shoulder', 'Scientific Drawing'),
          _WorkSeed('The Battle of Anghiari (Lost/Copy)', 'Mural / Drawing'),
        ],
      ),
      _ArtistSeed(
        artist: 'Michelangelo Buonarroti',
        period: 'High Renaissance',
        works: const [
          _WorkSeed('David', 'Sculpture (Marble)'),
          _WorkSeed('Pieta', 'Sculpture (Marble)'),
          _WorkSeed('The Creation of Adam (Sistine Chapel)', 'Fresco'),
          _WorkSeed('The Last Judgment (Sistine Chapel)', 'Fresco'),
          _WorkSeed('Moses', 'Sculpture (Marble)'),
          _WorkSeed('Bacchus', 'Sculpture (Marble)'),
          _WorkSeed('Dying Slave', 'Sculpture (Marble)'),
          _WorkSeed('Rebellious Slave', 'Sculpture (Marble)'),
          _WorkSeed('Ceiling of the Sistine Chapel (Full)', 'Fresco'),
          _WorkSeed('The Conversion of Saul', 'Fresco'),
          _WorkSeed('Doni Tondo', 'Painting (Tempera)'),
          _WorkSeed("Tomb of Giuliano de' Medici", 'Sculpture / Architecture'),
          _WorkSeed('Night (Medici Chapel)', 'Sculpture (Marble)'),
          _WorkSeed('Day (Medici Chapel)', 'Sculpture (Marble)'),
          _WorkSeed('Dawn (Medici Chapel)', 'Sculpture (Marble)'),
          _WorkSeed('Dusk (Medici Chapel)', 'Sculpture (Marble)'),
          _WorkSeed("St. Peter's Basilica Dome", 'Architecture'),
          _WorkSeed('Laurentian Library', 'Architecture'),
          _WorkSeed('The Torment of Saint Anthony', 'Painting (Tempera/Oil)'),
          _WorkSeed('Crouching Boy', 'Sculpture (Marble)'),
        ],
      ),
      _ArtistSeed(
        artist: 'Raphael',
        period: 'High Renaissance',
        works: const [
          _WorkSeed('The School of Athens', 'Fresco'),
          _WorkSeed('Sistine Madonna', 'Painting (Oil)'),
          _WorkSeed('The Transfiguration', 'Painting (Oil)'),
          _WorkSeed('Portrait of Baldassare Castiglione', 'Painting (Oil)'),
          _WorkSeed('The Marriage of the Virgin', 'Painting (Oil)'),
          _WorkSeed('Disputation of the Holy Sacrament', 'Fresco'),
          _WorkSeed('Galatea', 'Fresco'),
          _WorkSeed('Madonna del Prato (Madonna of the Meadow)', 'Painting (Oil)'),
          _WorkSeed('La Fornarina', 'Painting (Oil)'),
          _WorkSeed('Portrait of Pope Julius II', 'Painting (Oil)'),
          _WorkSeed('Portrait of Pope Leo X with Two Cardinals', 'Painting (Oil)'),
          _WorkSeed('The Parnassus', 'Fresco'),
          _WorkSeed('Saint George and the Dragon', 'Painting (Oil)'),
          _WorkSeed('Madonna of the Goldfinch', 'Painting (Oil)'),
          _WorkSeed('Aldobrandini Madonna', 'Painting (Oil)'),
          _WorkSeed('The Liberation of Saint Peter', 'Fresco'),
          _WorkSeed('Christ Falling on the Way to Calvary', 'Painting (Oil/Panel)'),
          _WorkSeed('Madonna della Seggiola', 'Painting (Oil)'),
          _WorkSeed('Self-Portrait', 'Painting (Oil)'),
          _WorkSeed('The Miraculous Draught of Fishes', 'Tapestry Design (Cartoon)'),
        ],
      ),
      _ArtistSeed(
        artist: 'Donatello',
        period: 'Early Renaissance',
        works: const [
          _WorkSeed('David (Bronze)', 'Sculpture (Bronze)'),
          _WorkSeed('Saint George', 'Sculpture (Marble)'),
          _WorkSeed('Gattamelata (Equestrian Statue)', 'Sculpture (Bronze)'),
          _WorkSeed('Penitent Magdalene', 'Sculpture (Wood)'),
          _WorkSeed('Feast of Herod', 'Relief (Bronze)'),
          _WorkSeed('Zuccone (Prophet Habakkuk)', 'Sculpture (Marble)'),
          _WorkSeed('Judith and Holofernes', 'Sculpture (Bronze)'),
          _WorkSeed('Saint John the Evangelist', 'Sculpture (Marble)'),
          _WorkSeed('Cantoria (Singing Gallery)', 'Sculpture (Marble)'),
          _WorkSeed('Pazzi Madonna', 'Relief (Marble)'),
          _WorkSeed('Saint Louis of Toulouse', 'Sculpture (Gilded Bronze)'),
          _WorkSeed('The Annunciation (Cavalcanti)', 'Relief (Limestone)'),
          _WorkSeed("Equestrian Statue of Niccolò da Uzzano", 'Sculpture (Terracotta)'),
          _WorkSeed('Atys-Amorino', 'Sculpture (Bronze)'),
          _WorkSeed('Saint Mark', 'Sculpture (Marble)'),
          _WorkSeed('Crucifix (Santa Croce)', 'Sculpture (Wood)'),
          _WorkSeed('Virgin and Child (Chellini Madonna)', 'Relief (Bronze)'),
          _WorkSeed('Prophet Jeremiah', 'Sculpture (Marble)'),
          _WorkSeed('The Ascension with Christ giving the Keys', 'Relief (Marble)'),
          _WorkSeed('Altar of Saint Anthony', 'Sculpture (Bronze/Marble)'),
        ],
      ),
      _ArtistSeed(
        artist: 'Sandro Botticelli',
        period: 'Early Renaissance',
        works: const [
          _WorkSeed('The Birth of Venus', 'Painting (Tempera)'),
          _WorkSeed('Primavera (Spring)', 'Painting (Tempera)'),
          _WorkSeed('Pallas and the Centaur', 'Painting (Tempera)'),
          _WorkSeed('Venus and Mars', 'Painting (Tempera/Oil)'),
          _WorkSeed('Adoration of the Magi (1475)', 'Painting (Tempera)'),
          _WorkSeed('Madonna of the Pomegranate', 'Painting (Tempera)'),
          _WorkSeed("Map of Hell (Dante's Inferno)", 'Drawing (Parchment)'),
          _WorkSeed('Portrait of a Young Man with a Medal', 'Painting (Tempera)'),
          _WorkSeed('Cestello Annunciation', 'Painting (Tempera)'),
          _WorkSeed('Mystic Nativity', 'Painting (Oil)'),
          _WorkSeed('The Trials of Moses', 'Fresco'),
          _WorkSeed('Punishment of the Sons of Corah', 'Fresco'),
          _WorkSeed('Temptation of Christ', 'Fresco'),
          _WorkSeed('Calumny of Apelles', 'Painting (Tempera)'),
          _WorkSeed('Fortitude', 'Painting (Tempera)'),
          _WorkSeed('Madonna of the Magnificat', 'Painting (Tempera)'),
          _WorkSeed('Portrait of Simonetta Vespucci', 'Painting (Tempera)'),
          _WorkSeed('The Discovery of the Body of Holofernes', 'Painting (Tempera)'),
          _WorkSeed('The Story of Lucretia', 'Painting (Tempera/Oil)'),
          _WorkSeed('Saint Augustine in His Study', 'Fresco'),
        ],
      ),
      _ArtistSeed(
        artist: 'Albrecht Dürer',
        period: 'Northern Renaissance',
        works: const [
          _WorkSeed('Melencolia I', 'Engraving'),
          _WorkSeed('Knight, Death and the Devil', 'Engraving'),
          _WorkSeed('Saint Jerome in His Study', 'Engraving'),
          _WorkSeed('Adam and Eve', 'Engraving'),
          _WorkSeed('The Four Horsemen (Apocalypse)', 'Woodcut'),
          _WorkSeed('Praying Hands', 'Drawing (Blue paper)'),
          _WorkSeed('Self-Portrait at Twenty-Eight', 'Painting (Oil)'),
          _WorkSeed('Young Hare', 'Watercolor / Gouache'),
          _WorkSeed('Great Piece of Turf', 'Watercolor'),
          _WorkSeed('Feast of the Rosary', 'Painting (Oil)'),
          _WorkSeed('Rhinoceros', 'Woodcut'),
          _WorkSeed('Adoration of the Magi', 'Painting (Oil)'),
          _WorkSeed('Paumgartner Altar', 'Painting (Oil)'),
          _WorkSeed('Portrait of Maximilian I', 'Painting (Oil)'),
          _WorkSeed('Haller Madonna', 'Painting (Oil)'),
          _WorkSeed('The Four Apostles', 'Painting (Oil)'),
          _WorkSeed('Sea Monster', 'Engraving'),
          _WorkSeed('Lamentation for Christ', 'Painting (Oil)'),
          _WorkSeed('The Large Turf', 'Watercolor'),
          _WorkSeed('Portrait of Hieronymus Holzschuher', 'Painting (Oil)'),
        ],
      ),
      _ArtistSeed(
        artist: 'Titian',
        period: 'High Renaissance',
        works: const [
          _WorkSeed('Venus of Urbino', 'Painting (Oil)'),
          _WorkSeed('Assumption of the Virgin', 'Painting (Oil)'),
          _WorkSeed('Bacchus and Ariadne', 'Painting (Oil)'),
          _WorkSeed('Diana and Actaeon', 'Painting (Oil)'),
          _WorkSeed('Sacred and Profane Love', 'Painting (Oil)'),
          _WorkSeed('Pesaro Madonna', 'Painting (Oil)'),
          _WorkSeed('Equestrian Portrait of Charles V', 'Painting (Oil)'),
          _WorkSeed('Danaë (with Nursemaid)', 'Painting (Oil)'),
          _WorkSeed('Rape of Europa', 'Painting (Oil)'),
          _WorkSeed('Pietà (Unfinished)', 'Painting (Oil)'),
          _WorkSeed('Portrait of Paul III and His Nephews', 'Painting (Oil)'),
          _WorkSeed('Flora', 'Painting (Oil)'),
          _WorkSeed('Venus with a Mirror', 'Painting (Oil)'),
          _WorkSeed('The Death of Actaeon', 'Painting (Oil)'),
          _WorkSeed('Tarquin and Lucretia', 'Painting (Oil)'),
          _WorkSeed('Man with a Quilted Sleeve', 'Painting (Oil)'),
          _WorkSeed('Salome', 'Painting (Oil)'),
          _WorkSeed('Jupiter and Antiope (Pardo Venus)', 'Painting (Oil)'),
          _WorkSeed('Allegory of Prudence', 'Painting (Oil)'),
          _WorkSeed('Crowning with Thorns', 'Painting (Oil)'),
        ],
      ),
    ];

    final artworks = <Artwork>[];
    var runningId = 1;

    for (final artistSeed in seeds) {
      for (final workSeed in artistSeed.works) {
        final id = 'mock_${runningId.toString().padLeft(3, '0')}';
        artworks.add(
          Artwork(
            id: id,
            title: workSeed.title,
            artist: artistSeed.artist,
            year: '',
            period: artistSeed.period,
            medium: _normalizeMedium(workSeed.category),
            dimensions: '',
            location: 'Mock Renaissance Collection',
            imageUrl: '',
            thumbnailUrl: '',
            description:
                '${workSeed.title} by ${artistSeed.artist} (${artistSeed.period}).',
            historicalContext:
                'Mock data set for Renaissance exploration and filter testing.',
            meaning: 'Category: ${workSeed.category}',
            keySymbols: const [],
            relatedArtworkIds: const [],
            department: 'European Paintings',
            isPublicDomain: true,
          ),
        );
        runningId++;
      }
    }

    return artworks;
  }

  String _normalizeMedium(String category) {
    final lower = category.toLowerCase();

    if (lower.contains('painting')) return category;
    if (lower.contains('fresco')) return category;
    if (lower.contains('sculpture') || lower.contains('relief')) return category;
    if (lower.contains('drawing')) return category;
    if (lower.contains('engraving') || lower.contains('woodcut')) {
      return 'Print (${category})';
    }
    if (lower.contains('tapestry')) return category;

    return category;
  }
}

class _ArtistSeed {
  final String artist;
  final String period;
  final List<_WorkSeed> works;

  const _ArtistSeed({
    required this.artist,
    required this.period,
    required this.works,
  });
}

class _WorkSeed {
  final String title;
  final String category;

  const _WorkSeed(this.title, this.category);
}
