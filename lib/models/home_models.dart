enum BadgeRarity {
  common('Comum'),
  rare('Raro'),
  epic('Épico'),
  legendary('Lendário');

  const BadgeRarity(this.label);
  final String label;
}

class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.art,
    required this.rarity,
    this.category = BadgeCategory.culture,
    this.collectionId = 'sao-luis',
    this.description = 'Descrição provisória de demonstração. Cada lugar guarda uma história para descobrir.',
    this.longDescription = 'Texto expandido de demonstração: este espaço receberá a história e o significado do selo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nenhuma informação histórica ou comercial foi validada nesta prévia.',
    this.status = BadgeUnlockStatus.unlocked,
    this.unlockedAt,
    this.isLogo = false,
    this.placeId,
    this.focusX = .5,
    this.focusY = .5,
  });
  final String id;
  final String name;
  final String art;
  final BadgeRarity rarity;
  final BadgeCategory category;
  final String collectionId, description, longDescription;
  final BadgeUnlockStatus status;
  final DateTime? unlockedAt;
  final bool isLogo;
  final String? placeId;

  /// Subject of the photo, 0…1 from left/top, chosen in the admin. The seal
  /// keeps this point in view when cropping the photo to its disc.
  final double focusX, focusY;
  bool get isUnlocked => status == BadgeUnlockStatus.unlocked;
  String get imagePath => art;
}

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.region,
    required this.category,
    this.description = '',
    this.photo,
    this.badgeRarity,
  });
  final String id;
  final String name;
  final String region;
  final String category;
  final String description;
  final String? photo;
  final BadgeRarity? badgeRarity;
}

class Collection {
  const Collection({
    required this.id,
    required this.name,
    required this.earned,
    required this.total,
    this.cover,
  });
  final String id;
  final String name;
  final String? cover;
  final int earned;
  final int total;
  double get progress => total > 0 ? (earned / total).clamp(0, 1) : 0;
}

enum BadgeUnlockStatus { locked, unlocked }

enum BadgeCategory {
  places('Lugares'),
  culture('Cultura'),
  nature('Natureza'),
  bars('Rolês e Bares');

  const BadgeCategory(this.label);
  final String label;
}

class BadgeCollection {
  const BadgeCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.badgeIds,
  });
  final String id, name, description, coverImage;
  final List<String> badgeIds;
}
