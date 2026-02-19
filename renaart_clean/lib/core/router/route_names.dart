class RouteNames {
  static const home = '/';
  static const search = '/search';
  static const collection = '/collection';
  static const profile = '/profile';
  static const artworkDetail = '/artwork/:id';

  static String artworkDetailPath(String id) => '/artwork/$id';
}
