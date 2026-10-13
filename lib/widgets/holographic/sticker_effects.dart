import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Silhouette of a badge seal. The rarity picks one (see
/// `BadgeRarityStyle.shapeOf`); the place photo sits on the central disc.
enum SealShape {
  /// Pressed wax seal with a thicker body of wax (common).
  pressedThick,

  /// Pressed wax seal, wax leaked to one side (rare and epic).
  pressed,

  /// Poured wax with uneven drips around a round disc (legendary).
  poured;

  /// Pressed seals have a smaller, stamped disc and an embossed groove.
  bool get isPressed => this != poured;

  /// Share of the sticker box covered by the photo disc, with a little
  /// bleed. The photo is framed to this box so the visible disc shows the
  /// whole crop instead of a magnified middle.
  double get discFraction => switch (this) {
    pressedThick => .79,
    pressed => .815,
    poured => .855,
  };
}

/// Frame layers are drawn at this share of their nominal inset: thin frames.
const _thinFrame = .55;

/// How the rim is built: matte wax, or polished foil that catches the light.
enum BadgeFrameStyle { matte, prismatic }

/// Die-cut mask shared by every layer: foil, light, shadow and the photo clip.
Path stickerOutline(
  Size size, {
  double inset = 0,
  SealShape style = SealShape.pressed,
}) {
  inset *= _thinFrame;
  return switch (style) {
    SealShape.pressedThick => _seal(size, inset, _sealThick),
    SealShape.pressed => _seal(size, inset, _sealPressed),
    SealShape.poured => _polar(size, inset, _pouredRadius),
  };
}

/// Outer irregularities belong to the frame only: they fade with the inset
/// and are gone by the photo's clip.
double _pointReach(Size size, double inset) =>
    (1 - inset / (size.width * .022)).clamp(0.0, 1.0);

/// Closed contour from a radius profile `k(angle, reach)` in 0…1 of the
/// half-size. `reach` fades the outer irregularities with the inset.
Path _polar(
  Size size,
  double inset,
  double Function(double angle, double reach) radius,
) {
  final c = size.center(Offset.zero);
  final rx = size.width / 2 - inset;
  final ry = size.height / 2 - inset;
  final reach = _pointReach(size, inset);
  final path = Path();
  for (var i = 0; i <= 360; i++) {
    final a = i / 360 * math.pi * 2;
    final k = radius(a, reach);
    final p = c + Offset(math.cos(a) * rx * k, math.sin(a) * ry * k);
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  return path..close();
}

/// Smooth bump of half-width [width] (radians) centred on [at].
double _bump(double a, double at, double width) {
  var d = (a - at).abs() % (math.pi * 2);
  if (d > math.pi) d = math.pi * 2 - d;
  if (d >= width) return 0;
  final t = d / width;
  return (1 - t * t) * (1 - t * t);
}

/// Poured wax: an uneven pool with wide, shallow drips around a round disc.
double _pouredRadius(double a, double reach) {
  const drips = [
    (0.35, .32, .09),
    (1.05, .22, .06),
    (1.62, .30, .10),
    (2.35, .26, .07),
    (3.05, .34, .09),
    (3.80, .20, .05),
    (4.45, .30, .08),
    (5.20, .24, .07),
    (5.85, .28, .06),
  ];
  var pool = 0.0;
  for (final (at, width, amp) in drips) {
    // Wide, shallow drips melt into each other without sharp crests.
    pool += amp * .85 * _bump(a, at, width * 1.5);
  }
  return (.9 + pool * reach) / 1.02;
}

/// Wax seal drips as (angle, half-width, height) in radians / half-size.
typedef _Drip = (double, double, double);

/// A pressed seal: wax leaks further towards [leak] (radians, 0 = right,
/// pi/2 = down), [drips] add uneven runs and [phase] varies the wobble.
/// [body] is the extra wax around the disc beyond the thin default; the disc
/// shrinks by the same amount so the seal keeps its overall size.
typedef _Seal = ({double leak, double phase, double body, List<_Drip> drips});

const _sealThick = (
  leak: .8,
  body: .025,
  phase: .3,
  drips: <_Drip>[(.8, .50, .040), (3.6, .35, .020), (5.3, .30, .015)],
);

const _sealPressed = (
  leak: 2.4,
  body: 0.0,
  phase: 1.9,
  drips: <_Drip>[
    (2.4, .45, .050),
    (0.4, .30, .025),
    (4.6, .40, .030),
    (5.6, .25, .020),
  ],
);

/// Pressed seal: a stamped disc (the photo) inside a thin pool of wax that
/// leaked unevenly. The pool is solid on every rim layer and gone before the
/// photo clip, so the wax takes the rarity foil and the disc keeps a clean
/// edge. The press also squashes the disc slightly.
Path _seal(Size size, double inset, _Seal seal) {
  final pool = inset <= size.width * .012 ? 1.0 : 0.0;
  return _polar(size, inset, (a, _) {
    var wax =
        .03 +
        seal.body +
        .05 * (1 + math.cos(a - seal.leak)) / 2 +
        .009 * math.sin(5 * a + seal.phase) +
        .006 * math.sin(9 * a + seal.phase * 1.7);
    for (final (at, width, height) in seal.drips) {
      wax += height * _bump(a, at, width);
    }
    final disc = .84 - seal.body + .012 * math.cos(2 * (a - seal.leak));
    return disc + pool * wax;
  });
}

class StickerClipper extends CustomClipper<Path> {
  const StickerClipper({this.style = SealShape.pressed});

  final SealShape style;

  @override
  Path getClip(Size size) =>
      stickerOutline(size, inset: size.width * 0.045, style: style);

  @override
  bool shouldReclip(StickerClipper oldClipper) => oldClipper.style != style;
}

class StickerFramePainter extends CustomPainter {
  const StickerFramePainter({
    required this.light,
    required this.colors,
    this.style = SealShape.pressed,
    this.frameStyle = BadgeFrameStyle.prismatic,
    this.ornate = true,
  });

  final SealShape style;
  final BadgeFrameStyle frameStyle;

  /// False keeps only the coloured rings: no studs or nodes on the rim.
  final bool ornate;

  final Offset light;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final outer = stickerOutline(size, style: style);
    canvas.drawPath(outer, Paint()..color = const Color(0xFFFFFDF5));
    final foil = stickerOutline(size, inset: size.width * 0.019, style: style);
    canvas.drawPath(
      foil,
      Paint()
        ..shader = SweepGradient(
          center: Alignment(light.dx * 0.45, light.dy * 0.45),
          transform: GradientRotation(light.dx * 0.8 + light.dy * 0.4),
          colors: [...colors, colors.first],
        ).createShader(bounds),
    );
    canvas.drawPath(
      stickerOutline(size, inset: size.width * 0.039, style: style),
      Paint()..color = const Color(0xFFFCF4DB),
    );
    _paintRarityConstruction(canvas, size, bounds);
    // Thin luminous outline follows the die-cut contour, without a blur layer.
    canvas.drawPath(
      foil,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  void _paintRarityConstruction(Canvas canvas, Size size, Rect bounds) {
    switch (frameStyle) {
      case BadgeFrameStyle.matte:
        canvas.drawPath(
          stickerOutline(size, inset: size.width * .025, style: style),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * .017
            ..color = const Color(0xFFD8D1C2),
        );
        canvas.drawPath(
          stickerOutline(size, inset: size.width * .039, style: style),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = const Color(0xFF8D8578).withValues(alpha: .65),
        );
        _paintDashes(canvas, size, count: 38);
        return;
      case BadgeFrameStyle.prismatic:
        for (final (inset, width, alpha) in [
          (.014, .010, .72),
          (.027, .009, .92),
          (.040, .004, .78),
        ]) {
          canvas.drawPath(
            stickerOutline(size, inset: size.width * inset, style: style),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size.width * width
              ..shader = SweepGradient(
                transform: GradientRotation(light.dx - light.dy),
                colors: [
                  ...colors.map((color) => color.withValues(alpha: alpha)),
                  colors.first.withValues(alpha: alpha),
                ],
              ).createShader(bounds),
          );
        }
        if (ornate) {
          _paintNodes(canvas, size, count: 6, inset: .030, radiusScale: .009);
        }
        return;
    }
  }

  void _paintDashes(Canvas canvas, Size size, {required int count}) {
    final metric = stickerOutline(
      size,
      inset: size.width * .031,
      style: style,
    ).computeMetrics().first;
    final paint = Paint()
      ..color = const Color(0xFFFAF7EE).withValues(alpha: .8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2;
    for (var index = 0; index < count; index++) {
      final start = metric.length * index / count;
      final end = start + metric.length / count * .42;
      canvas.drawPath(metric.extractPath(start, end), paint);
    }
  }

  void _paintNodes(
    Canvas canvas,
    Size size, {
    required int count,
    double inset = .039,
    double radiusScale = .007,
    Color color = Colors.white,
  }) {
    final metric = stickerOutline(
      size,
      inset: size.width * inset,
      style: style,
    ).computeMetrics().first;
    final paint = Paint()..color = color.withValues(alpha: .9);
    for (var index = 0; index < count; index++) {
      final point = metric
          .getTangentForOffset(metric.length * index / count)!
          .position;
      canvas.drawCircle(point, size.width * radiusScale, paint);
    }
  }

  @override
  bool shouldRepaint(StickerFramePainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.frameStyle != frameStyle ||
      oldDelegate.ornate != ornate ||
      oldDelegate.light != light ||
      oldDelegate.colors != colors;
}

class StickerShadowPainter extends CustomPainter {
  const StickerShadowPainter({
    required this.tilt,
    required this.lift,
    this.strength = 1,
    this.glow = 0,
    this.glowColor = Colors.transparent,
    this.style = SealShape.pressed,
  });

  final SealShape style;

  final Offset tilt;
  final double lift;
  final double strength, glow;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-tilt.dx * 15, 12 + lift * 3 - tilt.dy * 8);
    if (glow > 0) {
      canvas.drawShadow(
        stickerOutline(size, style: style),
        glowColor.withValues(alpha: glow),
        12,
        true,
      );
    }
    canvas.drawShadow(
      stickerOutline(size, style: style),
      Color.fromRGBO(0, 0, 0, 221 / 255 * strength),
      15,
      true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(StickerShadowPainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.tilt != tilt ||
      oldDelegate.lift != lift ||
      oldDelegate.strength != strength ||
      oldDelegate.glow != glow ||
      oldDelegate.glowColor != glowColor;
}

/// Foil optics are simulated with gradients and blend modes on a clipped path.
class HolographicLightPainter extends CustomPainter {
  const HolographicLightPainter({
    required this.light,
    required this.sweep,
    this.style = SealShape.pressed,
    required this.colors,
    this.intensity = 1,
    this.glint = 0,
  });

  final Offset light;
  final double sweep;
  final double intensity;

  /// Soft highlight floating over the glass, opposite the light like a real
  /// reflection. 0 disables it.
  final double glint;
  final SealShape style;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity == 0) return;
    final bounds = Offset.zero & size;
    final outline = stickerOutline(size, style: style);
    canvas.save();
    canvas.clipPath(outline);
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.softLight
        ..shader = LinearGradient(
          begin: Alignment(-1 + light.dx, -1 + light.dy),
          end: Alignment(1 + light.dx * 0.5, 1 + light.dy * 0.5),
          transform: GradientRotation(light.dx * 0.7 - light.dy * 0.5),
          colors: colors
              .map((c) => c.withValues(alpha: 0.34 * intensity))
              .toList(),
        ).createShader(bounds),
    );
    final highlight = Alignment(light.dx * 0.85, light.dy * 0.85);
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          center: highlight,
          radius: 0.85,
          colors: [
            const Color(0xFFE0FCFF).withValues(alpha: 0.20 * intensity),
            const Color(0xFFAA92E4).withValues(alpha: 0.05 * intensity),
            Colors.transparent,
          ],
        ).createShader(bounds),
    );
    // The diagonal reflection moves with the pointer, and sweeps on unlock.
    final band = light.dx * 0.50 + light.dy * 0.25 + sweep;
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          begin: Alignment(-1.4 + band, -0.7),
          end: Alignment(1.4 + band, 0.7),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.015 * intensity),
            const Color(0xFFD8F8FF).withValues(alpha: 0.24 * intensity),
            Colors.white.withValues(alpha: 0.035 * intensity),
            Colors.transparent,
          ],
          stops: const [0, 0.37, 0.49, 0.59, 1],
        ).createShader(bounds),
    );
    // Fine foil lines are intentionally faint and clipped to the same mask.
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.035 * intensity)
      ..strokeWidth = 0.6;
    for (double x = -size.height; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), line);
    }
    canvas.drawPath(
      stickerOutline(size, inset: size.width * 0.026, style: style),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = RadialGradient(
          center: highlight,
          radius: 1,
          colors: [
            Colors.white.withValues(alpha: (0.8 * intensity).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
        ).createShader(bounds),
    );
    if (glint > 0) _paintGlint(canvas, size, bounds);
    canvas.restore();
  }

  void _paintGlint(Canvas canvas, Size size, Rect bounds) {
    final at = Alignment(
      -.25 - light.dx * .55,
      -.35 - light.dy * .45,
    ).withinRect(bounds);
    final radius = size.width * .2;
    canvas.drawCircle(
      at,
      radius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: .34 * glint),
            Colors.white.withValues(alpha: .08 * glint),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, .45, 1],
        ).createShader(Rect.fromCircle(center: at, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(HolographicLightPainter oldDelegate) =>
      oldDelegate.glint != glint ||
      oldDelegate.style != style ||
      oldDelegate.light != light ||
      oldDelegate.sweep != sweep ||
      oldDelegate.colors != colors ||
      oldDelegate.intensity != intensity;
}

class StickerSparkPainter extends CustomPainter {
  const StickerSparkPainter({
    required this.unlock,
    required this.idle,
    required this.enableIdle,
    this.particleCount = 14,
    this.rimColors = const [],
    this.light = Offset.zero,
    this.rimStrength = 0,
    this.frameStyle = BadgeFrameStyle.prismatic,
    this.style = SealShape.pressed,
    this.ornate = true,
  });

  final double unlock;
  final double idle;
  final bool enableIdle;
  final int particleCount;
  final List<Color> rimColors;
  final Offset light;
  final double rimStrength;
  final BadgeFrameStyle frameStyle;
  final SealShape style;
  final bool ornate;

  @override
  void paint(Canvas canvas, Size size) {
    if (rimColors.isNotEmpty) {
      PrismaticRimPainter(
        light: light,
        phase: idle,
        colors: rimColors,
        strength: rimStrength,
        frameStyle: frameStyle,
        style: style,
        ornate: ornate,
      ).paint(canvas, size);
      if (style.isPressed) _paintWaxRelief(canvas, size);
    }
    final metric = stickerOutline(size, style: style).computeMetrics().first;
    final burst = unlock > 0 && unlock < 1 ? math.sin(unlock * math.pi) : 0.0;
    for (var i = 0; i < particleCount; i++) {
      final tangent = metric.getTangentForOffset(
        metric.length * i / particleCount,
      )!;
      final outward = tangent.position - size.center(Offset.zero);
      final point = tangent.position + outward / outward.distance * unlock * 22;
      final twinkle = !enableIdle
          ? 0.0
          : math
                    .pow(
                      math.max(0.0, math.sin(idle * math.pi * 2 + i * 2.4)),
                      24,
                    )
                    .toDouble() *
                0.35;
      final alpha = math.max(burst * 0.8, twinkle);
      if (alpha < 0.05) continue;
      final paint = Paint()
        ..color = const Color(0xFFE4F5F2).withValues(alpha: alpha)
        ..strokeWidth = 1;
      final r = 1.2 + burst * 2;
      canvas.drawLine(point - Offset(r, 0), point + Offset(r, 0), paint);
      canvas.drawLine(point - Offset(0, r), point + Offset(0, r), paint);
    }
  }

  /// Volume for wax seals: the groove where the stamp sank into the wax and
  /// a lit, rounded outer edge. Light comes from the top left and follows
  /// the tilt a little.
  void _paintWaxRelief(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final disc = stickerOutline(size, inset: size.width * .045, style: style);
    final rim = stickerOutline(size, style: style);
    final lightFrom = Alignment(-.7 + light.dx * .4, -.8 + light.dy * .4);
    final lightTo = Alignment(.7 + light.dx * .4, .8 + light.dy * .4);
    // Groove: dark on the lit side's opposite wall, bright on the other.
    canvas.drawPath(
      disc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .016
        ..shader = LinearGradient(
          begin: lightFrom,
          end: lightTo,
          colors: const [
            Color(0x55000000),
            Color(0x10000000),
            Color(0x60FFFFFF),
          ],
        ).createShader(bounds),
    );
    canvas.drawPath(
      disc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: .55),
    );
    // Rounded outer edge of the poured wax.
    canvas.save();
    canvas.clipPath(rim);
    canvas.drawPath(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .022
        ..shader = LinearGradient(
          begin: lightFrom,
          end: lightTo,
          colors: const [
            Color(0x70FFFFFF),
            Color(0x00FFFFFF),
            Color(0x40000000),
          ],
        ).createShader(bounds),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(StickerSparkPainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.unlock != unlock ||
      oldDelegate.idle != idle ||
      oldDelegate.enableIdle != enableIdle ||
      oldDelegate.particleCount != particleCount ||
      oldDelegate.rimColors != rimColors ||
      oldDelegate.light != light ||
      oldDelegate.rimStrength != rimStrength ||
      oldDelegate.frameStyle != frameStyle ||
      oldDelegate.ornate != ornate;
}

/// Layered foil restricted to an annulus of the original die-cut silhouette.
/// No full-image glow or rectangular overlay: only the rim catches this light.
class PrismaticRimPainter extends CustomPainter {
  const PrismaticRimPainter({
    required this.light,
    required this.phase,
    required this.colors,
    required this.strength,
    this.frameStyle = BadgeFrameStyle.prismatic,
    this.style = SealShape.pressed,
    this.ornate = true,
  });
  final Offset light;
  final double phase, strength;
  final List<Color> colors;
  final BadgeFrameStyle frameStyle;
  final SealShape style;

  /// False: plain foil ring with one outline. No engraving, studs, extra
  /// lines or travelling sparkles.
  final bool ornate;
  @override
  void paint(Canvas canvas, Size size) {
    if (strength == 0) return;
    final bounds = Offset.zero & size;
    final (outerInset, innerInset) = switch (frameStyle) {
      BadgeFrameStyle.matte => (.024, .048),
      BadgeFrameStyle.prismatic => (.016, .061),
    };
    final outer = stickerOutline(
      size,
      inset: size.width * outerInset,
      style: style,
    );
    final inner = stickerOutline(
      size,
      inset: size.width * innerInset,
      style: style,
    );
    // Even-odd fill of two nested contours instead of Path.combine: on web the
    // boolean difference of these curves can return the whole outline, which
    // painted the foil over the entire photo.
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(outer, Offset.zero)
      ..addPath(inner, Offset.zero);
    // Polished foil turns slowly on its own; matte wax only follows the tilt.
    final circulates = frameStyle == BadgeFrameStyle.prismatic;
    // Strength below 1 calms the polished bands and the travelling sparkles.
    final foil = strength.clamp(0.0, 1.0);
    final rotation =
        (circulates ? phase * math.pi * 2 : 0) + light.dx * 1.5 - light.dy;
    canvas.save();
    canvas.clipPath(ring);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = SweepGradient(
          transform: GradientRotation(rotation),
          colors: [...colors, colors.first],
        ).createShader(bounds),
    );
    // Tight reflected bands simulate polished foil. Matte keeps a satin edge.
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = SweepGradient(
          transform: GradientRotation(-rotation * .7),
          colors: [
            Colors.transparent,
            Colors.white.withValues(
              alpha: frameStyle == BadgeFrameStyle.matte ? .24 : .95 * foil,
            ),
            Colors.transparent,
            Colors.transparent,
            Colors.white.withValues(
              alpha: frameStyle == BadgeFrameStyle.matte ? .18 : .85 * foil,
            ),
            Colors.transparent,
          ],
          stops: const [0, .10, .16, .52, .60, 1],
        ).createShader(bounds),
    );
    if (frameStyle == BadgeFrameStyle.matte) {
      canvas.restore();
      canvas.drawPath(
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFE1DBCE),
      );
      return;
    }
    final engraving = stickerOutline(
      size,
      inset: size.width * .041,
      style: style,
    ).computeMetrics().first;
    final hairline = Paint()
      ..color = Colors.white.withValues(alpha: .30)
      ..strokeWidth = .6;
    final engravingCount = ornate ? 110 : 0;
    for (var i = 0; i < engravingCount; i++) {
      final tangent = engraving.getTangentForOffset(
        engraving.length * i / engravingCount,
      )!;
      final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
      canvas.drawLine(
        tangent.position - normal * size.width * .006,
        tangent.position + normal * size.width * .006,
        hairline,
      );
    }
    canvas.restore();
    if (ornate) {
      _paintPrismaticStuds(canvas, size, rotation);
    }
    for (final inset in ornate ? [.018, .055, .063] : [.055]) {
      canvas.drawPath(
        stickerOutline(size, inset: size.width * inset, style: style),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = inset == .055 ? 1.6 : .8
          ..color = Colors.white.withValues(alpha: inset == .063 ? .90 : .65),
      );
    }
    final orbit = stickerOutline(
      size,
      inset: size.width * .034,
      style: style,
    ).computeMetrics().first;
    // Sparkles travel along ornate polished rims only.
    final sparkleCount = circulates && ornate ? (3 * foil).floor() : 0;
    for (var i = 0; i < sparkleCount; i++) {
      final position =
          (phase + i / sparkleCount + light.dx * .08 + light.dy * .06) % 1;
      final point = orbit
          .getTangentForOffset(orbit.length * position)!
          .position;
      final radius =
          (2.2 + math.sin((phase + i) * math.pi * 2).abs() * 1.8) * strength;
      canvas.drawCircle(
        point,
        radius * 3,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: .6),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: point, radius: radius * 3)),
      );
      final sparkle = Paint()
        ..color = Colors.white.withValues(alpha: .94)
        ..strokeWidth = 1;
      canvas.drawLine(
        point - Offset(radius, 0),
        point + Offset(radius, 0),
        sparkle,
      );
      canvas.drawLine(
        point - Offset(0, radius),
        point + Offset(0, radius),
        sparkle,
      );
    }
  }

  void _paintPrismaticStuds(Canvas canvas, Size size, double rotation) {
    final metric = stickerOutline(
      size,
      inset: size.width * .031,
      style: style,
    ).computeMetrics().first;
    final bounds = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(
        transform: GradientRotation(rotation),
        colors: [...colors, colors.first],
      ).createShader(bounds);
    for (var index = 0; index < 6; index++) {
      final point = metric
          .getTangentForOffset(metric.length * (index + .5) / 6)!
          .position;
      canvas.drawCircle(point, size.width * .011, paint);
      canvas.drawCircle(
        point,
        size.width * .004,
        Paint()..color = Colors.white.withValues(alpha: .9),
      );
    }
  }

  @override
  bool shouldRepaint(PrismaticRimPainter oldDelegate) =>
      oldDelegate.ornate != ornate ||
      oldDelegate.light != light ||
      oldDelegate.phase != phase ||
      oldDelegate.colors != colors ||
      oldDelegate.strength != strength ||
      oldDelegate.frameStyle != frameStyle ||
      oldDelegate.style != style;
}
