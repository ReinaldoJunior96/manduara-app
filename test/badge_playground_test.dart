import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triluma/screens/badge_playground_page.dart';
import 'package:triluma/theme/triluma_theme.dart';
import 'package:triluma/widgets/playground/playground_badge.dart';

void main() {
  testWidgets('Playground shows real source beside compiled preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: TrilumaTheme.light, home: const BadgePlaygroundPage()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Editor Dart'), findsOneWidget);
    expect(find.text('Preview compilado'), findsOneWidget);
    expect(find.byType(PlaygroundBadge), findsOneWidget);
    expect(find.text('Executar'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      contains('class PlaygroundBadge'),
    );

    final before = tester.widget<PlaygroundBadge>(find.byType(PlaygroundBadge));
    await tester.tap(find.byTooltip('Reiniciar animação'));
    await tester.pump();
    final after = tester.widget<PlaygroundBadge>(find.byType(PlaygroundBadge));
    expect(after.restartToken, before.restartToken + 1);

    await tester.tap(find.text('Salvar .dart'));
    await tester.pump();
    expect(
      find.text('A gravação local está disponível apenas no Flutter Web.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground stacks panels on a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: TrilumaTheme.light, home: const BadgePlaygroundPage()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Editor Dart'), findsOneWidget);
    expect(find.text('Preview compilado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
