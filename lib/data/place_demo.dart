import '../models/home_models.dart';

/// Local catalogue for the current offline demonstration.
abstract final class PlaceDemo {
  static const avenidaDoReggae = Place(
    id: 'avenida-do-reggae',
    name: 'Avenida do Reggae',
    region: 'São Luís · Maranhão',
    category: 'Cultura / Arte urbana',
    photo: 'assets/images/avenida_do_reggae_reference.jpg',
    badgeRarity: BadgeRarity.rare,
    description:
        'Um espaço dedicado à cultura do reggae em São Luís. '
        'O casal de esculturas dançando, as cores verde, amarelo e vermelho '
        'e o jardim inspiram seu emblema colecionável exclusivo.',
  );
  static const places = [avenidaDoReggae];

  static Place? byId(String? id) {
    for (final place in places) {
      if (place.id == id) return place;
    }
    return null;
  }
}
