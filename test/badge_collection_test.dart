import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triluma/main.dart';
import 'package:triluma/data/badge_demo.dart';
import 'package:triluma/models/home_models.dart';
import 'package:triluma/screens/badge_collection_page.dart';
import 'package:triluma/screens/badge_detail_page.dart';
import 'package:triluma/widgets/home/home_sections.dart';
import 'package:triluma/widgets/holographic_sticker.dart';
import 'package:triluma/widgets/holographic/badge_rarity_style.dart';
import 'package:triluma/widgets/holographic/sticker_effects.dart';
import 'package:triluma/theme/triluma_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BadgeDemo data;
  setUpAll(() async {
    data = await BadgeDemo.load();
  });

  test('Each rarity maps to its seal and finish', () {
    expect(
      [for (final r in BadgeRarity.values) BadgeRarityStyle.shapeOf(r)],
      [
        SealShape.pressedThick,
        SealShape.pressed,
        SealShape.pressed,
        SealShape.poured,
      ],
    );
    expect(
      BadgeRarityStyle.of(BadgeRarity.common).frameStyle,
      BadgeFrameStyle.matte,
    );
    for (final r in [
      BadgeRarity.rare,
      BadgeRarity.epic,
      BadgeRarity.legendary,
    ]) {
      expect(BadgeRarityStyle.of(r).frameStyle, BadgeFrameStyle.prismatic);
    }
    // Rare and epic share a silhouette, so their foil must tell them apart.
    expect(
      BadgeRarityStyle.of(BadgeRarity.rare).colors,
      isNot(BadgeRarityStyle.of(BadgeRarity.epic).colors),
    );
  });

  for (final rarity in BadgeRarity.values) {
    testWidgets('${rarity.label} sends its frame profile to compact painter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HolographicSticker(
            compact: true,
            rarity: rarity,
            imagePath: 'assets/images/imagem1.webp',
          ),
        ),
      );
      final frame = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<StickerFramePainter>()
          .first;
      expect(frame.frameStyle, BadgeRarityStyle.of(rarity).frameStyle);
    });
  }

  test(
    'Every bar image in the manifest is registered once; filters intersect',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final paths = manifest
          .listAssets()
          .where((p) => p.startsWith('assets/images/imagem_selos_bares/'))
          .map((p) => 'bar-${p.split('/').last.split('.').first}')
          .toSet();
      final bars = data.filter(category: BadgeCategory.bars);
      // Ids come from the photo; art may be a finished emblem instead.
      expect(bars.map((b) => b.id).toSet(), paths);
      expect(bars.length, 5);
      expect(
        data.collections.singleWhere((c) => c.id == 'bares').badgeIds.length,
        5,
      );
      for (final category in BadgeCategory.values) {
        for (final rarity in BadgeRarity.values) {
          expect(
            data
                .filter(category: category, rarity: rarity)
                .every((b) => b.category == category && b.rarity == rarity),
            isTrue,
          );
        }
      }
      expect(BadgeDemo.progress, closeTo(1 / 3, .001));
    },
  );

  testWidgets(
    'Selos opens collection; filters work and survive detail navigation',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Selos'));
      await tester.pump();
      await tester.runAsync(() async {
        await BadgeDemo.load();
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(find.byType(BadgeCollectionPage), findsOneWidget);
      final bars = find.byKey(const ValueKey('filter-Rolês e Bares'));
      await tester.ensureVisible(bars);
      await tester.tap(bars);
      await tester.pumpAndSettle();
      expect(find.text('5 selos · coleção de demonstração'), findsOneWidget);
      final rare = find.byKey(const ValueKey('filter-Raro'));
      await tester.ensureVisible(rare);
      await tester.tap(rare);
      await tester.pumpAndSettle();
      expect(find.text('1 selo · coleção de demonstração'), findsOneWidget);
      final tile = find.byKey(const ValueKey('badge-bar-barbudos'));
      await tester.ensureVisible(tile);
      final collectionScroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final position = collectionScroll.position.pixels;
      await tester.tap(tile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(BadgeDetailPage), findsOneWidget);
      expect(
        tester
            .widget<HolographicSticker>(find.byType(HolographicSticker).last)
            .compact,
        isFalse,
      );
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(collectionScroll.position.pixels, closeTo(position, .01));
      collectionScroll.position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(tester.widget<RarityFilterPill>(rare).selected, isTrue);
      expect(tester.widget<SealFilterTab>(bars).active, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('Collection fits $size text $scale; grid is static', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            theme: TrilumaTheme.light,
            home: const BadgeCollectionPage(),
          ),
        );
        await tester.runAsync(() async {
          await BadgeDemo.load();
          await Future<void>.delayed(Duration.zero);
        });
        await tester.pumpAndSettle();
        final scroll = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        do {
          expect(tester.takeException(), isNull);
          for (final w in tester.widgetList<HolographicSticker>(
            find.byType(HolographicSticker),
          )) {
            expect(w.compact, isTrue);
          }
          expect(
            tester
                .widgetList<CustomPaint>(find.byType(CustomPaint))
                .where((p) => p.foregroundPainter is HolographicLightPainter),
            isEmpty,
          );
          scroll.position.jumpTo(
            (scroll.position.pixels + 200).clamp(
              0,
              scroll.position.maxScrollExtent,
            ),
          );
          await tester.pumpAndSettle();
        } while (scroll.position.pixels < scroll.position.maxScrollExtent);
        expect(tester.takeException(), isNull);
        expect(tester.hasRunningAnimations, isFalse);
      });
    }
  }

  for (final locked in [true, false]) {
    testWidgets(
      'Detail ${locked ? 'locked' : 'unlocked'} fits; expands without granting a badge',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final badge = data.badges.firstWhere((b) => b.isUnlocked != locked);
        await tester.pumpWidget(
          MaterialApp(
            theme: TrilumaTheme.light,
            home: BadgeDetailPage(badge: badge, data: data),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        final expand = find.byKey(const ValueKey('expand-description'));
        await tester.ensureVisible(expand);
        await tester.tap(expand);
        await tester.pumpAndSettle();
        expect(find.text(badge.longDescription), findsOneWidget);
        expect(badge.isUnlocked, !locked);
        if (locked) {
          expect(find.text('Como conquistar este selo'), findsOneWidget);
        }
        final scroll = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Showcase animates its rim, pauses off screen and respects reduced motion',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BadgeDetailPage(badge: data.badges.first, data: data),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      StickerSparkPainter rim() => tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.foregroundPainter)
          .whereType<StickerSparkPainter>()
          .first;
      final firstPhase = rim().idle;
      expect(rim().rimColors, isNotEmpty);
      expect(
        rim().frameStyle,
        BadgeRarityStyle.of(data.badges.first.rarity).frameStyle,
      );
      final frame = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<StickerFramePainter>()
          .first;
      expect(frame.frameStyle, rim().frameStyle);
      await tester.pump(const Duration(seconds: 2));
      expect(rim().idle, isNot(firstPhase));
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: BadgeDetailPage(badge: data.badges.first, data: data),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(rim().idle, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
