import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/triluma_theme.dart';
import '../holographic/sticker_effects.dart';

class TopographicDecoration extends CustomPainter {
  const TopographicDecoration({this.opacity = .22, this.rightOnly = false});
  final double opacity;
  final bool rightOnly;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .55
      ..color = TrilumaColors.gold.withValues(alpha: opacity);
    if (rightOnly) {
      paint.shader = LinearGradient(
        colors: [
          TrilumaColors.gold.withValues(alpha: 0),
          TrilumaColors.gold.withValues(alpha: 0),
          TrilumaColors.gold.withValues(alpha: opacity),
        ],
        stops: const [0, .48, .8],
      ).createShader(Offset.zero & size);
    }
    for (var i = 0; i < 10; i++) {
      final path = Path();
      for (var j = 0; j <= 150; j++) {
        final t = j / 150 * math.pi * 2;
        final r = 1 + .12 * math.sin(3 * t) + .07 * math.cos(7 * t);
        final x =
            size.width * .77 + math.cos(t) * (size.width * .35 + i * 9) * r;
        final y =
            size.height * .40 + math.sin(t) * (size.height * .25 + i * 8) * r;
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path..close(), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(TopographicDecoration oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.rightOnly != rightOnly;
}

class CompassRose extends CustomPainter {
  const CompassRose();
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final radius = size.shortestSide * (i.isEven ? .48 : .26);
      final tip = c + Offset(math.sin(a), math.cos(a)) * radius;
      final side = Offset(math.cos(a), -math.sin(a)) * size.shortestSide * .065;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo((c + side).dx, (c + side).dy)
          ..lineTo(tip.dx, tip.dy)
          ..close(),
        Paint()..color = TrilumaColors.gold,
      );
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo((c - side).dx, (c - side).dy)
          ..lineTo(tip.dx, tip.dy)
          ..close(),
        Paint()..color = TrilumaColors.paleGold,
      );
    }
  }

  @override
  bool shouldRepaint(CompassRose oldDelegate) => false;
}

/// Samples only the collection artwork from the user-supplied approved mockup.
/// Layout, lettering, progress and interactions remain native Flutter widgets.
class CollectionArtwork extends StatelessWidget {
  const CollectionArtwork({super.key, required this.index});
  final int index;
  static const regions = [
    Rect.fromLTWH(84, 1164, 182, 181),
    Rect.fromLTWH(341, 1152, 191, 191),
    Rect.fromLTWH(598, 1153, 190, 191),
  ];
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final rect = regions[index.clamp(0, 2)];
      final scale = box.maxWidth / rect.width;
      return ClipPath(
        clipper: const _CollectionArtClipper(),
        child: SizedBox(
          height: rect.height * scale,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 941 * scale,
            maxWidth: 941 * scale,
            minHeight: 1672 * scale,
            maxHeight: 1672 * scale,
            child: Transform.translate(
              offset: Offset(-rect.left * scale, -rect.top * scale),
              child: Image.asset(
                'assets/images/home_reference.png',
                width: 941 * scale,
                height: 1672 * scale,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _CollectionArtClipper extends CustomClipper<Path> {
  const _CollectionArtClipper();
  @override
  Path getClip(Size size) => stickerOutline(size);
  @override
  bool shouldReclip(_CollectionArtClipper oldClipper) => false;
}
