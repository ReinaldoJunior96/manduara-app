import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../models/home_models.dart';

class BadgeDemo {
  BadgeDemo(this.badges);
  final List<Badge> badges;
  static const collected = 8;
  static const total = 24;
  static double get progress => collected / total;
  static Future<BadgeDemo>? _cached;
  static Future<BadgeDemo> reload() {
    _cached = null;
    return load();
  }

  static Future<BadgeDemo> load() => _cached ??= _load();

  List<BadgeCollection> get collections => [
    for (final (id, name) in [
      ('sao-luis', 'São Luís'),
      ('bares', 'Rolês e Bares'),
    ])
      BadgeCollection(
        id: id,
        name: name,
        description: 'Coleção de demonstração',
        coverImage: badges.firstWhere((b) => b.collectionId == id).art,
        badgeIds: badges
            .where((b) => b.collectionId == id)
            .map((b) => b.id)
            .toList(),
      ),
  ];
  String collectionName(String id) =>
      id == 'bares' ? 'Rolês e Bares' : 'São Luís';
  List<Badge> filter({BadgeCategory? category, BadgeRarity? rarity}) => badges
      .where(
        (badge) =>
            (category == null || badge.category == category) &&
            (rarity == null || badge.rarity == rarity),
      )
      .toList();

  static Future<BadgeDemo> _load() async {
    final badges = <Badge>[
      Badge(
        id: 'centro',
        name: 'Centro Histórico de São Luís',
        art: 'assets/images/imagem1.webp',
        rarity: BadgeRarity.rare,
        category: BadgeCategory.places,
        unlockedAt: DateTime(2026, 9, 12),
      ),
      Badge(
        id: 'pescador',
        name: 'Praça do Pescador',
        art: 'assets/images/pescador.jpg',
        rarity: BadgeRarity.common,
        category: BadgeCategory.nature,
        unlockedAt: DateTime(2026, 9, 14),
      ),
      Badge(
        id: 'arte',
        name: 'Arte de Rua',
        art: 'assets/images/images-7.jpg',
        rarity: BadgeRarity.epic,
        unlockedAt: DateTime(2026, 9, 18),
      ),
      const Badge(
        id: 'patrimonio',
        name: 'Patrimônio de São Luís · prévia',
        art: 'assets/images/imagem1.webp',
        rarity: BadgeRarity.legendary,
        status: BadgeUnlockStatus.locked,
      ),
      const Badge(
        id: 'avenida-do-reggae',
        name: 'Avenida do Reggae',
        art: 'assets/images/avenida_do_reggae_reference.jpg',
        // The couple stands in the upper half; flowers fill the bottom.
        focusY: .25,
        placeId: 'avenida-do-reggae',
        rarity: BadgeRarity.rare,
        category: BadgeCategory.culture,
        description: 'Um abraço em ritmo de reggae. O casal de esculturas dançando é o coração deste selo de São Luís, Maranhão.',
        longDescription: 'A Avenida do Reggae celebra a ligação de São Luís com o ritmo jamaicano. Segundo o histórico fornecido para este cadastro, a revitalização de 2025 transformou um trecho da antiga Avenida Quarto Centenário, conectando bairros como Camboa e Alemanha. Cadastro e estado de conquista demonstrativos.',
      ),
    ];
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths =
        manifest
            .listAssets()
            .where(
              (path) =>
                  path.startsWith('assets/images/imagem_selos_bares/') &&
                  RegExp(
                    r'\.(png|jpe?g|webp)$',
                    caseSensitive: false,
                  ).hasMatch(path),
            )
            .toList()
          ..sort();
    for (final (index, path) in paths.indexed) {
      // Validate actual decoding, not just the extension. Assets stay local.
      try {
        final bytes = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          targetWidth: 1,
        );
        final frame = await codec.getNextFrame();
        frame.image.dispose();
        codec.dispose();
      } catch (_) {
        // Ignore non-decodable files; each valid bundled image gets one mock.
        continue;
      }
      final stem = path.split('/').last.replaceFirst(RegExp(r'\.[^.]+$'), '');
      final name = stem
          .split('_')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' ');
      badges.add(
        Badge(
          id: 'bar-$stem',
          name: name,
          art: path,
          category: BadgeCategory.bars,
          collectionId: 'bares',
          rarity: BadgeRarity.values[index % BadgeRarity.values.length],
          status: index == paths.length - 1
              ? BadgeUnlockStatus.locked
              : BadgeUnlockStatus.unlocked,
          unlockedAt: index == paths.length - 1
              ? null
              : DateTime(2026, 9, 20 + index),
          isLogo: stem == 'barbudos',
          description: 'Texto provisório. Nome organizado a partir do arquivo; cadastro sujeito a revisão.',
        ),
      );
    }
    return BadgeDemo(List.unmodifiable(badges));
  }
}
