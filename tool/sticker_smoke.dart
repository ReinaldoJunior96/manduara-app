// Run with: flutter run -d <simulator-id> -t tool/sticker_smoke.dart
// Debug simulator timings are diagnostics, not a release-mode FPS guarantee.
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:triluma/main.dart' as app;

Future<void> main() async {
  app.main();
  await Future<void>.delayed(const Duration(seconds: 4));
  Element? sticker;
  void visit(Element element) {
    if (sticker == null &&
        element.widget.key == const ValueKey('sticker-tilt')) {
      sticker = element;
    }
    element.visitChildren(visit);
  }

  visit(WidgetsBinding.instance.rootElement!);
  if (sticker == null) throw StateError('Sticker is missing from the Home.');
  await Scrollable.ensureVisible(sticker!, alignment: .5);
  await Future<void>.delayed(const Duration(milliseconds: 500));
  final box = sticker!.findRenderObject()! as RenderBox;
  final center = box.localToGlobal(box.size.center(Offset.zero));
  final timings = <FrameTiming>[];
  void collect(List<FrameTiming> frames) => timings.addAll(frames);
  SchedulerBinding.instance.addTimingsCallback(collect);
  var point = center;
  GestureBinding.instance.handlePointerEvent(
    PointerDownEvent(pointer: 1, position: point),
  );
  for (var i = 1; i <= 180; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 16));
    final next =
        center +
        Offset(
          math.sin(i / 180 * math.pi * 4) * box.size.width * 0.38,
          math.sin(i / 180 * math.pi * 2) * box.size.height * 0.35,
        );
    GestureBinding.instance.handlePointerEvent(
      PointerMoveEvent(pointer: 1, position: next, delta: next - point),
    );
    point = next;
  }
  GestureBinding.instance.handlePointerEvent(
    PointerUpEvent(pointer: 1, position: point),
  );
  await Future<void>.delayed(const Duration(seconds: 2));
  SchedulerBinding.instance.removeTimingsCallback(collect);
  if (timings.isEmpty) throw StateError('No frame timings were collected.');
  double percentile(List<double> values) {
    values.sort();
    return values[((values.length - 1) * 0.95).round()];
  }

  final result = {
    'mode': 'debug simulator',
    'frames': timings.length,
    'build_p95_ms': percentile(
      timings.map((t) => t.buildDuration.inMicroseconds / 1000).toList(),
    ),
    'raster_p95_ms': percentile(
      timings.map((t) => t.rasterDuration.inMicroseconds / 1000).toList(),
    ),
    'frames_with_build_or_raster_over_16_67ms': timings
        .where(
          (t) =>
              t.buildDuration.inMicroseconds > 16670 ||
              t.rasterDuration.inMicroseconds > 16670,
        )
        .length,
  };
  debugPrint('STICKER_SMOKE ${jsonEncode(result)}');
}
