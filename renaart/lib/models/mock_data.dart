import '../models/artwork_model.dart';

class MockData {
  static final List<Artwork> artworks = [
    Artwork(
      id: '1',
      title: 'Mona Lisa',
      artist: 'Leonardo da Vinci',
      year: '1503–1519',
      period: 'High Renaissance',
      medium: 'Oil on poplar panel',
      dimensions: '77 cm × 53 cm',
      location: 'Louvre Museum, Paris',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/402px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/402px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg',
      description:
          'The Mona Lisa is a half-length portrait painting by Italian artist Leonardo da Vinci, considered an archetypal masterpiece of the Italian Renaissance.',
      historicalContext:
          'Painted during the Italian Renaissance, a period of great cultural and artistic flourishing.',
      meaning:
          'The subject\'s enigmatic expression has puzzled viewers for centuries. The sfumato technique creates an atmospheric haze around the figure.',
      keySymbols: ['Sfumato technique', 'Enigmatic smile', 'Aerial perspective'],
      department: 'European Paintings',
      aspectRatio: 0.69,
    ),
    Artwork(
      id: '2',
      title: 'The Birth of Venus',
      artist: 'Sandro Botticelli',
      year: '1484–1486',
      period: 'Early Renaissance',
      medium: 'Tempera on canvas',
      dimensions: '172.5 cm × 278.9 cm',
      location: 'Uffizi Gallery, Florence',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg/1280px-Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg/640px-Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg',
      description:
          'The Birth of Venus depicts the goddess Venus emerging from the sea as a fully grown woman, born of sea-foam and the severed genitals of Uranus.',
      historicalContext:
          'Commissioned by the Medici family, this painting reflects the Neo-Platonic philosophy popular in Florence.',
      meaning:
          'Venus represents divine beauty and love. The painting synthesizes classical mythology with Renaissance humanism.',
      keySymbols: ['Venus on shell', 'Zephyr blowing wind', 'Horae with cloak'],
      department: 'European Paintings',
      aspectRatio: 1.62,
    ),
    Artwork(
      id: '3',
      title: 'The School of Athens',
      artist: 'Raphael',
      year: '1509–1511',
      period: 'High Renaissance',
      medium: 'Fresco',
      dimensions: '500 cm × 770 cm',
      location: 'Vatican Museums, Rome',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/%22The_School_of_Athens%22_by_Raffaello_Sanzio_da_Urbino.jpg/1280px-%22The_School_of_Athens%22_by_Raffaello_Sanzio_da_Urbino.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/%22The_School_of_Athens%22_by_Raffaello_Sanzio_da_Urbino.jpg/640px-%22The_School_of_Athens%22_by_Raffaello_Sanzio_da_Urbino.jpg',
      description:
          'The School of Athens is one of four main frescoes in the Apostolic Palace of the Vatican, depicting the great philosophers of antiquity.',
      historicalContext:
          'Commissioned by Pope Julius II, this fresco represents the synthesis of classical philosophy and Renaissance thought.',
      meaning:
          'Raphael places figures from different eras together, representing Philosophy as one of the four branches of human knowledge.',
      keySymbols: ['Plato and Aristotle', 'Architectural arches', 'Geometric diagram'],
      department: 'Frescoes',
      aspectRatio: 1.54,
    ),
    Artwork(
      id: '4',
      title: 'David',
      artist: 'Michelangelo',
      year: '1501–1504',
      period: 'High Renaissance',
      medium: 'Marble sculpture',
      dimensions: '517 cm height',
      location: 'Galleria dell\'Accademia, Florence',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Michelangelo%27s_David_-_right_view_2.jpg/456px-Michelangelo%27s_David_-_right_view_2.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Michelangelo%27s_David_-_right_view_2.jpg/456px-Michelangelo%27s_David_-_right_view_2.jpg',
      description:
          'Michelangelo\'s David is a masterpiece of Renaissance sculpture created between 1501 and 1504.',
      historicalContext:
          'Commissioned by the Arte della Lana and the Operai of Santa Maria del Fiore as one of a series of prophets for the Florence Cathedral.',
      meaning:
          'Represents the ideal of human physical perfection, depicting David before his battle with Goliath.',
      keySymbols: ['Contrapposto pose', 'Tense hand', 'Calm face'],
      department: 'Sculptures',
      aspectRatio: 0.53,
    ),
    Artwork(
      id: '5',
      title: 'Primavera',
      artist: 'Sandro Botticelli',
      year: '1477–1482',
      period: 'Early Renaissance',
      medium: 'Tempera on panel',
      dimensions: '202 cm × 314 cm',
      location: 'Uffizi Gallery, Florence',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Botticelli-primavera.jpg/1280px-Botticelli-primavera.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Botticelli-primavera.jpg/640px-Botticelli-primavera.jpg',
      description:
          'Primavera is a large panel painting in tempera paint by the Italian Renaissance painter Sandro Botticelli.',
      historicalContext:
          'This painting is generally accepted today as a depiction of the Roman goddess of spring, surrounded by her entourage.',
      meaning:
          'The painting celebrates spring and love, with complex Neo-Platonic symbolism throughout the composition.',
      keySymbols: ['Three Graces', 'Mercury', 'Cupid'],
      department: 'European Paintings',
      aspectRatio: 1.55,
    ),
    Artwork(
      id: '6',
      title: 'The Creation of Adam',
      artist: 'Michelangelo',
      year: '1508–1512',
      period: 'High Renaissance',
      medium: 'Fresco',
      dimensions: '280 cm × 570 cm',
      location: 'Sistine Chapel, Vatican',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg/1280px-Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg/640px-Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg',
      description:
          'The Creation of Adam is a fresco painting by Michelangelo, part of the Sistine Chapel\'s ceiling painted c. 1508–1512.',
      historicalContext:
          'Part of the nine scenes from the Book of Genesis that form the centerpiece of the ceiling\'s decorative scheme.',
      meaning:
          'The almost-touching hands of God and Adam has become one of the most reproduced religious paintings of all time.',
      keySymbols: ['Almost-touching fingers', 'God in mantle', 'Adam on Earth'],
      department: 'Frescoes',
      aspectRatio: 2.04,
    ),
    Artwork(
      id: '7',
      title: 'The Last Supper',
      artist: 'Leonardo da Vinci',
      year: '1495–1498',
      period: 'High Renaissance',
      medium: 'Tempera and oil on plaster',
      dimensions: '460 cm × 880 cm',
      location: 'Santa Maria delle Grazie, Milan',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/%C3%9Altima_Cena_-_Da_Vinci_5.jpg/1280px-%C3%9Altima_Cena_-_Da_Vinci_5.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/%C3%9Altima_Cena_-_Da_Vinci_5.jpg/640px-%C3%9Altima_Cena_-_Da_Vinci_5.jpg',
      description:
          'The Last Supper is a late 15th-century mural painting by Italian artist Leonardo da Vinci housed in the refectory of the Convent of Santa Maria delle Grazie in Milan.',
      historicalContext:
          'Commissioned by Ludovico Sforza, Duke of Milan, depicting the moment Jesus announces that one of his apostles will betray him.',
      meaning:
          'The painting captures the reactions of all 12 apostles to Jesus\'s revelation, showing a spectrum of human emotions.',
      keySymbols: ['Triangular composition', 'Group reactions', 'Vanishing point'],
      department: 'Murals',
      aspectRatio: 1.91,
    ),
    Artwork(
      id: '8',
      title: 'Portrait of a Young Woman',
      artist: 'Petrus Christus',
      year: 'c. 1470',
      period: 'Northern Renaissance',
      medium: 'Oil on oak panel',
      dimensions: '29 cm × 22.5 cm',
      location: 'Gemäldegalerie, Berlin',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Petrus_Christus_Portrait_of_a_Young_Girl.jpg/464px-Petrus_Christus_Portrait_of_a_Young_Girl.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Petrus_Christus_Portrait_of_a_Young_Girl.jpg/464px-Petrus_Christus_Portrait_of_a_Young_Girl.jpg',
      description:
          'This intimate portrait by Flemish master Petrus Christus depicts a young woman with remarkable psychological depth.',
      historicalContext:
          'Created during the Northern Renaissance, a period where Flemish painters pioneered oil painting techniques.',
      meaning:
          'The direct gaze and precise details of costume reflect the Flemish obsession with minute observation of the physical world.',
      keySymbols: ['Direct gaze', 'Hennin headdress', 'Trompe-l\'oeil frame'],
      department: 'Northern European',
      aspectRatio: 0.78,
    ),
    Artwork(
      id: '9',
      title: 'Pietà',
      artist: 'Michelangelo',
      year: '1498–1499',
      period: 'High Renaissance',
      medium: 'Marble sculpture',
      dimensions: '174 cm × 195 cm',
      location: 'St. Peter\'s Basilica, Vatican',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Michelangelo%27s_Pieta_5450_cropncleaned_edit.jpg/768px-Michelangelo%27s_Pieta_5450_cropncleaned_edit.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Michelangelo%27s_Pieta_5450_cropncleaned_edit.jpg/768px-Michelangelo%27s_Pieta_5450_cropncleaned_edit.jpg',
      description:
          'Michelangelo\'s Pietà depicts the body of Jesus on the lap of his mother Mary after the Crucifixion.',
      historicalContext:
          'Commissioned by a French cardinal, this was Michelangelo\'s first large-scale work and made him famous throughout Rome.',
      meaning:
          'The composition creates a sense of profound stillness and grief, with Mary\'s youth representing her spiritual purity.',
      keySymbols: ['Pyramidal composition', 'Drapery detail', 'Youthful Mary'],
      department: 'Sculptures',
      aspectRatio: 0.89,
    ),
    Artwork(
      id: '10',
      title: 'The Arnolfini Portrait',
      artist: 'Jan van Eyck',
      year: '1434',
      period: 'Flemish',
      medium: 'Oil on oak panel',
      dimensions: '82.2 cm × 60 cm',
      location: 'National Gallery, London',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Van_Eyck_-_Arnolfini_Portrait.jpg/493px-Van_Eyck_-_Arnolfini_Portrait.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Van_Eyck_-_Arnolfini_Portrait.jpg/493px-Van_Eyck_-_Arnolfini_Portrait.jpg',
      description:
          'The Arnolfini Portrait is a painting by the Early Netherlandish painter Jan van Eyck, created in 1434.',
      historicalContext:
          'One of the most original and complex paintings in Western art history, this work represents a crucial moment in the development of the art of portraiture.',
      meaning:
          'The convex mirror in the background reflects two additional figures, believed to be witnesses to the couple\'s union.',
      keySymbols: ['Convex mirror', 'Single candle', 'Dog symbolizing fidelity'],
      department: 'Northern European',
      aspectRatio: 0.73,
    ),
    Artwork(
      id: '11',
      title: 'The Sistine Madonna',
      artist: 'Raphael',
      year: '1512',
      period: 'High Renaissance',
      medium: 'Oil on canvas',
      dimensions: '269.5 cm × 201 cm',
      location: 'Gemäldegalerie Alte Meister, Dresden',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Raffael_Sixtinische_Madonna.jpg/557px-Raffael_Sixtinische_Madonna.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Raffael_Sixtinische_Madonna.jpg/557px-Raffael_Sixtinische_Madonna.jpg',
      description:
          'The Sistine Madonna, also called the Madonna di San Sisto, is an oil painting by Raphael, commissioned by Pope Julius II.',
      historicalContext:
          'Commissioned as an altarpiece for the church of San Sisto in Piacenza, it is now one of the most reproduced works of art in the world.',
      meaning:
          'The two cherubs at the bottom have become iconic in popular culture, representing classical ideals of beauty and innocence.',
      keySymbols: ['Green curtain', 'Two iconic cherubs', 'Pope Sixtus II'],
      department: 'European Paintings',
      aspectRatio: 0.75,
    ),
    Artwork(
      id: '12',
      title: 'Venus of Urbino',
      artist: 'Titian',
      year: '1538',
      period: 'High Renaissance',
      medium: 'Oil on canvas',
      dimensions: '119 cm × 165 cm',
      location: 'Uffizi Gallery, Florence',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Giorgione_%28attributed%29_-_Sleeping_Venus_-_Google_Art_Project_2.jpg/1280px-Giorgione_%28attributed%29_-_Sleeping_Venus_-_Google_Art_Project_2.jpg',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Giorgione_%28attributed%29_-_Sleeping_Venus_-_Google_Art_Project_2.jpg/640px-Giorgione_%28attributed%29_-_Sleeping_Venus_-_Google_Art_Project_2.jpg',
      description:
          'The Venus of Urbino is an oil painting by the Italian master Titian, depicting a reclining nude woman in the pose of Venus.',
      historicalContext:
          'Created for Guidobaldo II della Rovere, this work influenced a long tradition of reclining nude paintings in Western art.',
      meaning:
          'The figure makes direct eye contact with the viewer, suggesting a knowing sophistication rather than innocent vulnerability.',
      keySymbols: ['Direct gaze', 'Rose flowers', 'Domestic interior'],
      department: 'European Paintings',
      aspectRatio: 1.39,
    ),
  ];

  static List<Artwork> getByPeriod(String period) {
    if (period == 'All') return artworks;
    return artworks.where((a) => a.period == period).toList();
  }

  static List<Artwork> search(String query) {
    final q = query.toLowerCase();
    return artworks.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.artist.toLowerCase().contains(q) ||
          a.period.toLowerCase().contains(q) ||
          a.medium.toLowerCase().contains(q);
    }).toList();
  }

  static List<Artwork> getRelated(Artwork artwork) {
    return artworks
        .where((a) => a.id != artwork.id && a.period == artwork.period)
        .take(4)
        .toList();
  }
}
