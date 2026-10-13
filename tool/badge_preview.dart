// Local visual review: flutter run -t tool/badge_preview.dart
// Add --dart-define=DETAIL=true to review the full interactive sticker.
import 'package:flutter/material.dart' hide Badge;
import 'package:triluma/data/badge_demo.dart';
import 'package:triluma/models/home_models.dart';
import 'package:triluma/screens/badge_collection_page.dart';
import 'package:triluma/screens/badge_detail_page.dart';
import 'package:triluma/theme/triluma_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await BadgeDemo.load();
  const rarityName = String.fromEnvironment('RARITY', defaultValue: 'rare');
  final rarity = BadgeRarity.values.firstWhere(
    (value) => value.name == rarityName,
    orElse: () => BadgeRarity.rare,
  );
  final source = data.badges.firstWhere((badge) => badge.rarity == rarity);
  final previewBadge = Badge(
    id: 'preview-${rarity.name}',
    name: '${source.name} · ${rarity.label}',
    art: source.art,
    rarity: rarity,
    category: source.category,
    collectionId: source.collectionId,
    description: source.description,
    longDescription: source.longDescription,
    unlockedAt: DateTime(2026, 10, 9),
    isLogo: source.isLogo,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TrilumaTheme.light,
      home: const bool.fromEnvironment('DETAIL')
          ? BadgeDetailPage(badge: previewBadge, data: data)
          : const BadgeCollectionPage(
              initialCategory: bool.fromEnvironment('BARS')
                  ? BadgeCategory.bars
                  : null,
            ),
    ),
  );
  if (const bool.fromEnvironment('BARS')) {
    await Future<void>.delayed(const Duration(seconds: 3));
    Element? scroll;
    void visit(Element e) {
      if (scroll == null &&
          e is StatefulElement &&
          e.state is ScrollableState) {
        scroll = e;
      }
      e.visitChildren(visit);
    }

    visit(WidgetsBinding.instance.rootElement!);
    final position =
        ((scroll as StatefulElement).state as ScrollableState).position;
    position.jumpTo(400.clamp(0, position.maxScrollExtent).toDouble());
  }
}
