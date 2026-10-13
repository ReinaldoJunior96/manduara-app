import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triluma/main.dart';
import 'package:triluma/models/home_models.dart';
import 'package:triluma/widgets/home/home_sections.dart';
import 'package:triluma/widgets/holographic/badge_rarity_style.dart';
import 'package:triluma/widgets/holographic/sticker_effects.dart';
import 'package:triluma/widgets/holographic_sticker.dart';

void main() {
  testWidgets(
    'Gallery gives each sticker its own shape and independent interaction',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: HolographicSticker(
                    key: ValueKey('heritage-sticker'),
                    enableIdleAnimation: false,
                    enableUnlockAnimation: false,
                  ),
                ),
                Expanded(
                  child: HolographicSticker(
                    key: ValueKey('pescador-sticker'),
                    imagePath: 'assets/images/pescador.jpg',
                    rarity: BadgeRarity.legendary,
                    enableIdleAnimation: false,
                    enableUnlockAnimation: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await _loadPhoto(tester);
      await tester.pump(const Duration(seconds: 2));
      final fisher = find.byKey(const ValueKey('pescador-sticker'));
      final heritage = find.byKey(const ValueKey('heritage-sticker'));
      final fisherTilt = find.descendant(
        of: fisher,
        matching: find.byKey(const ValueKey('sticker-tilt')),
      );
      final heritageTilt = find.descendant(
        of: heritage,
        matching: find.byKey(const ValueKey('sticker-tilt')),
      );
      final original = tester.widget<Transform>(heritageTilt).transform.clone();
      final fisherOriginal = tester
          .widget<Transform>(fisherTilt)
          .transform
          .clone();
      final gesture = await tester.startGesture(tester.getCenter(fisherTilt));
      await gesture.moveBy(const Offset(65, 40));
      await tester.pump();
      expect(
        tester.widget<Transform>(fisherTilt).transform,
        isNot(fisherOriginal),
      );
      expect(tester.widget<Transform>(heritageTilt).transform, original);
      final clips = tester
          .widgetList<ClipPath>(
            find.descendant(of: fisher, matching: find.byType(ClipPath)),
          )
          .map((w) => w.clipper)
          .whereType<StickerClipper>();
      expect(clips.single.style, SealShape.poured);
      final lights = tester
          .widgetList<CustomPaint>(
            find.descendant(of: fisher, matching: find.byType(CustomPaint)),
          )
          .map((w) => w.foregroundPainter)
          .whereType<HolographicLightPainter>();
      expect(lights.single.style, SealShape.poured);
      expect(lights.single.light.dx, greaterThan(0));
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Sticker pointer drives tilt, foil and spring return', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HolographicSticker(
            imagePath: 'assets/images/images-7.jpg',
            title: 'Arte de Rua',
            enableIdleAnimation: false,
            enableUnlockAnimation: false,
          ),
        ),
      ),
    );
    await _loadPhoto(tester);
    final tiltFinder = find.byKey(const ValueKey('sticker-tilt'));
    final neutral = tester.widget<Transform>(tiltFinder).transform.clone();
    final center = tester.getCenter(tiltFinder);
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(100, 70));
    await tester.pump();
    final tilted = tester.widget<Transform>(tiltFinder).transform;
    expect(tilted, isNot(neutral));
    final light = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.foregroundPainter)
        .whereType<HolographicLightPainter>()
        .single;
    expect(light.style, SealShape.pressed);
    expect(light.light.dx, greaterThan(0));
    expect(light.light.dy, greaterThan(0));
    expect(light.light.dx, lessThanOrEqualTo(1));
    expect(light.light.dy, lessThanOrEqualTo(1));
    expect(find.byType(ClipPath), findsWidgets);
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    final returned = tester.widget<Transform>(tiltFinder).transform;
    for (var i = 0; i < 16; i++) {
      expect(returned.storage[i], closeTo(neutral.storage[i], 0.001));
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('Touch interrupts unlock immediately; disposal stops tickers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HolographicSticker())),
    );
    await _loadPhoto(tester);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.hasRunningAnimations, isTrue);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('sticker-tilt'))),
    );
    await tester.pump();
    final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    expect(
      paints
          .map((p) => p.foregroundPainter)
          .whereType<StickerSparkPainter>()
          .single
          .unlock,
      1,
    );
    expect(tester.hasRunningAnimations, isFalse);
    await gesture.up();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  for (final size in [
    const Size(320, 568),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('Home fits $size at text scale $scale throughout scrolling', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        // The drifting contour lines never settle; layout is what matters here.
        _reduceMotion(tester);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        expect(find.textContaining('Que lembrança'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
        final scrollable = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        while (scrollable.position.pixels <
            scrollable.position.maxScrollExtent) {
          scrollable.position.jumpTo(
            (scrollable.position.pixels + 250).clamp(
              0,
              scrollable.position.maxScrollExtent,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(tester.hasRunningAnimations, isFalse);
      });
    }
  }

  testWidgets(
    'Home demo actions stay on Home and rarity selector updates finish',
    (tester) async {
      _reduceMotion(tester);
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.textContaining('próxima etapa'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(ManduaraNavigationBar), findsOneWidget);
      expect(find.text('Perto de você'), findsNothing);
      expect(find.text('Uma descoberta especial'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(FeaturedPlaceCard),
          matching: find.byType(HolographicSticker),
        ),
        findsOneWidget,
      );
      for (final rarity in BadgeRarity.values) {
        await tester.ensureVisible(
          find.byKey(const ValueKey('heritage-sticker')),
        );
        await tester.longPress(find.byKey(const ValueKey('heritage-sticker')));
        await tester.pumpAndSettle();
        final chip = find.widgetWithText(ChoiceChip, rarity.label);
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        final sticker = tester.widget<HolographicSticker>(
          find.byType(HolographicSticker),
        );
        expect(sticker.rarity, rarity);
        expect(sticker.imagePath, 'assets/images/imagem1.webp');
        expect(sticker.title, 'Centro Histórico de São Luís');
        expect(tester.takeException(), isNull);
      }
    },
  );

  for (final rarity in BadgeRarity.values) {
    testWidgets(
      '${rarity.label}: seal tilt returns and foil retains its mask',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HolographicSticker(
                rarity: rarity,
                enableIdleAnimation: false,
                enableUnlockAnimation: false,
              ),
            ),
          ),
        );
        await _loadPhoto(tester);
        final finder = find.byKey(const ValueKey('sticker-tilt'));
        final neutral = tester.widget<Transform>(finder).transform.clone();
        final gesture = await tester.startGesture(tester.getCenter(finder));
        await gesture.moveBy(const Offset(70, 50));
        await tester.pump();
        expect(tester.widget<Transform>(finder).transform, isNot(neutral));
        final light = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((p) => p.foregroundPainter)
            .whereType<HolographicLightPainter>()
            .single;
        expect(light.style, BadgeRarityStyle.shapeOf(rarity));
        expect(light.light.dx, greaterThan(0));
        expect(
          light.intensity,
          rarity == BadgeRarity.common ? 0 : greaterThan(0),
        );
        final clip = tester
            .widgetList<ClipPath>(find.byType(ClipPath))
            .map((p) => p.clipper)
            .whereType<StickerClipper>()
            .single;
        expect(clip.style, light.style);
        await gesture.up();
        await tester.pumpAndSettle();
        final returned = tester.widget<Transform>(finder).transform;
        for (var i = 0; i < 16; i++) {
          expect(returned.storage[i], closeTo(neutral.storage[i], .001));
        }
        expect(tester.hasRunningAnimations, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Contour lines drift on Home, pause off screen and when reduced',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.hasRunningAnimations, isTrue);
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      scroll.position.jumpTo(0);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.hasRunningAnimations, isTrue);
      _reduceMotion(tester);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Reduced motion disables reveal, idle and tilt', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: HolographicSticker()),
        ),
      ),
    );
    await _loadPhoto(tester);
    await tester.pumpAndSettle();
    final tilt = find.byKey(const ValueKey('sticker-tilt'));
    final neutral = tester.widget<Transform>(tilt).transform.clone();
    await tester.drag(tilt, const Offset(80, 60));
    await tester.pumpAndSettle();
    expect(tester.widget<Transform>(tilt).transform, neutral);
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });
}

/// Turns on the system "reduce motion" setting for one test.
void _reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

Future<void> _loadPhoto(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(HolographicSticker).evaluate()) {
      final widget = element.widget as HolographicSticker;
      await precacheImage(AssetImage(widget.imagePath), element);
    }
  });
  await tester.pump();
  expect(tester.takeException(), isNull);
  for (final image in find.byType(Image).evaluate()) {
    expect((image.renderObject! as RenderBox).size.height, greaterThan(0));
  }
}
