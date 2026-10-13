import '../models/home_models.dart';

/// Presentation fixtures only. No proximity or ownership is inferred.
abstract final class HomeDemo {
  static const heritagePhoto = 'assets/images/imagem1.webp';
  static const featured = Place(
    id: 'centro-historico',
    name: 'Centro Histórico de São Luís',
    region: 'Maranhão',
    category: 'Cultura',
    photo: heritagePhoto,
    description: 'Ruas que guardam séculos de histórias, cores, cultura e um patrimônio único do Brasil.',
    badgeRarity: BadgeRarity.rare,
  );
  static const collections = [
    Collection(
      id: 'sao-luis',
      name: 'São Luís',
      earned: 8,
      total: 24,
      cover: heritagePhoto,
    ),
    Collection(id: 'praias', name: 'Praias do Maranhão', earned: 5, total: 18),
    Collection(
      id: 'cultura',
      name: 'Cultura Maranhense',
      earned: 6,
      total: 20,
      cover: heritagePhoto,
    ),
  ];
  static const nearby = [
    featured,
    Place(
      id: 'calhau',
      name: 'Praia do Calhau',
      region: 'Maranhão',
      category: 'Natureza',
      badgeRarity: BadgeRarity.common,
    ),
    Place(
      id: 'goncalves-dias',
      name: 'Praça Gonçalves Dias',
      region: 'Maranhão',
      category: 'História',
      badgeRarity: BadgeRarity.epic,
    ),
  ];
  static const badge = Badge(
    id: 'selo-centro-historico',
    name: 'Centro Histórico de São Luís',
    art: heritagePhoto,
    rarity: BadgeRarity.rare,
  );
}
