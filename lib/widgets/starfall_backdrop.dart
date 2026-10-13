import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A faint shower of small stars drifting down behind a showcased seal, with
/// a soft halo in the seal's [tint]. Loops seamlessly; still when [animate]
/// is false or the system asks for reduced motion.
class StarfallBackdrop extends StatefulWidget {
  const StarfallBackdrop({super.key, required this.tint, this.animate = true});

  /// Rarity colour mixed into the stars and the halo.
  final Color tint;
  final bool animate;

  @override
  State<StarfallBackdrop> createState() => _StarfallBackdropState();
}

class _StarfallBackdropState extends State<StarfallBackdrop>
    with SingleTickerProviderStateMixin {
  late final _fall = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  void _sync() {
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      if (!_fall.isAnimating) _fall.repeat();
    } else {
      _fall.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(StarfallBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _StarfallPainter(_fall, widget.tint),
        size: Size.infinite,
      ),
    ),
  );
}

class _Star {
  const _Star(this.x, this.offset, this.speed, this.size, this.twinkle);
  final double x, offset, speed, size, twinkle;
}

class _StarfallPainter extends CustomPainter {
  _StarfallPainter(this.fall, this.tint) : super(repaint: fall);
  final Animation<double> fall;
  final Color tint;

  /// Fixed positions so every frame and every run looks the same.
  static final _stars = () {
    final random = math.Random(21);
    return [
      for (var i = 0; i < 26; i++)
        _Star(
          random.nextDouble(),
          random.nextDouble(),
          // Whole numbers of passes per cycle keep the loop seamless.
          (1 + random.nextInt(2)).toDouble(),
          1 + random.nextDouble() * 1.8,
          random.nextDouble() * math.pi * 2,
        ),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final halo = size.shortestSide * .46;
    canvas.drawCircle(
      center,
      halo,
      Paint()
        ..shader = RadialGradient(
          colors: [
            tint.withValues(alpha: .16),
            tint.withValues(alpha: .05),
            tint.withValues(alpha: 0),
          ],
          stops: const [0, .55, 1],
        ).createShader(Rect.fromCircle(center: center, radius: halo)),
    );
    final t = fall.value;
    final starColor = Color.lerp(tint, const Color(0xFFB88A3E), .35)!;
    for (final star in _stars) {
      final progress = (star.offset + t * star.speed) % 1;
      // Slight diagonal drift while falling.
      final x = (star.x + progress * .08) % 1 * size.width;
      final y = progress * (size.height + 20) - 10;
      // Fade in at the top and out at the bottom, with a gentle twinkle.
      final edge = math.sin(progress * math.pi);
      final twinkle = .65 + .35 * math.sin(t * math.pi * 8 + star.twinkle);
      final alpha = (.55 * edge * twinkle).clamp(0.0, 1.0);
      if (alpha < .02) continue;
      final paint = Paint()
        ..color = starColor.withValues(alpha: alpha)
        ..strokeWidth = .9
        ..strokeCap = StrokeCap.round;
      final p = Offset(x, y);
      final r = star.size;
      canvas.drawCircle(p, r * .45, paint);
      if (r > 2) {
        // The larger stars get four short rays.
        canvas
          ..drawLine(p - Offset(r * 1.6, 0), p + Offset(r * 1.6, 0), paint)
          ..drawLine(p - Offset(0, r * 1.6), p + Offset(0, r * 1.6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_StarfallPainter oldDelegate) => oldDelegate.tint != tint;
}
