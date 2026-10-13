import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triluma/data/badge_demo.dart';
import 'package:triluma/data/place_demo.dart';
import 'package:triluma/screens/place_detail_page.dart';
import 'package:triluma/models/home_models.dart';
import 'package:triluma/screens/badge_detail_page.dart';
import 'package:triluma/widgets/holographic_sticker.dart';

void main() {
  testWidgets(
    'Reggae is registered in São Luís culture and its seal shows the photo',
    (tester) async {
      final data = await tester.runAsync(BadgeDemo.load);
      final badge = data!.badges.singleWhere(
        (b) => b.id == 'avenida-do-reggae',
      );
      expect(badge.rarity, BadgeRarity.rare);
      expect(PlaceDemo.byId(badge.placeId), PlaceDemo.avenidaDoReggae);
      expect(badge.art, 'assets/images/avenida_do_reggae_reference.jpg');
      expect(data.filter(category: BadgeCategory.culture), contains(badge));
      expect(data.collections.first.badgeIds, contains(badge.id));
      await tester.pumpWidget(
        MaterialApp(
          home: BadgeDetailPage(badge: badge, data: data),
        ),
      );
      await tester.pump();
      expect(
        tester
            .widget<HolographicSticker>(find.byType(HolographicSticker).first)
            .imagePath,
        badge.art,
      );
      expect(find.text('Avenida do Reggae'), findsWidgets);
      final localButton = find.text('Conhecer o local');
      await tester.scrollUntilVisible(
        localButton,
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(localButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(PlaceDetailPage), findsOneWidget);
      expect(find.text('Avenida do Reggae'), findsWidgets);
      final badgeButton = find.text('Explorar emblema');
      await tester.scrollUntilVisible(
        badgeButton,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(badgeButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(PlaceDetailPage), findsNothing);
      expect(find.byType(HolographicSticker), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
