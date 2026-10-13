import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Experimental badge compiled by Flutter.
///
/// Edit this file, save it, then trigger Hot Reload in the Flutter process.
/// The Playground editor never evaluates this source at runtime.
class PlaygroundBadge extends StatefulWidget {
  const PlaygroundBadge({
    super.key,
    this.restartToken = 0,
    this.enableMotion = true,
  });

  final int restartToken;
  final bool enableMotion;

  @override
  State<PlaygroundBadge> createState() => _PlaygroundBadgeState();
}

class _PlaygroundBadgeState extends State<PlaygroundBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );
  Offset _pointer = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (widget.enableMotion) _controller.repeat();
  }

  @override
  void didUpdateWidget(PlaygroundBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restartToken != widget.restartToken) {
      _controller
        ..stop()
        ..value = 0;
      if (widget.enableMotion) _controller.repeat();
    }
    if (oldWidget.enableMotion != widget.enableMotion) {
      widget.enableMotion ? _controller.repeat() : _controller.stop();
    }
  }

  void _updatePointer(Offset localPosition, Size size) {
    setState(() {
      _pointer = Offset(
        ((localPosition.dx / size.width) * 2 - 1).clamp(-1, 1),
        ((localPosition.dy / size.height) * 2 - 1).clamp(-1, 1),
      );
    });
  }

  void _resetPointer() => setState(() => _pointer = Offset.zero);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          cursor: SystemMouseCursors.grab,
          onHover: (event) => _updatePointer(event.localPosition, size),
          onExit: (_) => _resetPointer(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (event) => _updatePointer(event.localPosition, size),
            onPanEnd: (_) => _resetPointer(),
            onPanCancel: _resetPointer,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final phase = reduceMotion ? 0.0 : _controller.value;
                final idle = widget.enableMotion && !reduceMotion
                    ? math.sin(phase * math.pi * 2)
                    : 0.0;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, .0015)
                  ..rotateX(-_pointer.dy * .20)
                  ..rotateY(_pointer.dx * .20)
                  ..rotateZ(idle * .012);
                return Transform.translate(
                  offset: Offset(0, idle * 4),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: transform,
                    child: CustomPaint(
                      painter: _PlaygroundShadowPainter(pointer: _pointer),
                      child: CustomPaint(
                        painter: _PlaygroundBadgePainter(
                          phase: phase,
                          pointer: _pointer,
                        ),
                        foregroundPainter: _PlaygroundFoilPainter(
                          phase: phase,
                          pointer: _pointer,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Path _badgePath(Size size, {double inset = 0}) {
  final center = size.center(Offset.zero);
  final radius = math.min(size.width, size.height) / 2 - inset;
  final path = Path();
  const points = 32;
  for (var index = 0; index < points; index++) {
    final angle = -math.pi / 2 + index * math.pi * 2 / points;
    final wave = index.isEven ? 1.0 : .91;
    final point = Offset(
      center.dx + math.cos(angle) * radius * wave,
      center.dy + math.sin(angle) * radius * wave,
    );
    index == 0
        ? path.moveTo(point.dx, point.dy)
        : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

class _PlaygroundShadowPainter extends CustomPainter {
  const _PlaygroundShadowPainter({required this.pointer});

  final Offset pointer;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-pointer.dx * 8, 12 - pointer.dy * 6);
    canvas.drawShadow(
      _badgePath(size, inset: size.width * .04),
      const Color(0xAA001C18),
      18,
      true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlaygroundShadowPainter oldDelegate) =>
      oldDelegate.pointer != pointer;
}

class _PlaygroundBadgePainter extends CustomPainter {
  const _PlaygroundBadgePainter({required this.phase, required this.pointer});

  final double phase;
  final Offset pointer;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final outer = _badgePath(size, inset: size.width * .035);
    final inner = _badgePath(size, inset: size.width * .105);
    canvas.drawPath(
      outer,
      Paint()
        ..shader = SweepGradient(
          transform: GradientRotation(phase * math.pi * 2),
          colors: const [
            Color(0xFFFFD76A),
            Color(0xFF6FE1D3),
            Color(0xFF9D83EF),
            Color(0xFFFFB7DF),
            Color(0xFFFFD76A),
          ],
        ).createShader(bounds),
    );
    canvas.drawPath(inner, Paint()..color = const Color(0xFF073B34));
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .012
        ..color = const Color(0xFFFFE6A6),
    );

    final center = size.center(Offset.zero);
    final compass = Paint()
      ..color = const Color(0xFFFFF6DB)
      ..style = PaintingStyle.fill;
    for (var index = 0; index < 8; index++) {
      final angle = index * math.pi / 4 + phase * math.pi * .25;
      final long = index.isEven ? size.width * .25 : size.width * .16;
      final side = size.width * .035;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-direction.dy, direction.dx);
      canvas.drawPath(
        Path()
          ..moveTo(
            center.dx + direction.dx * long,
            center.dy + direction.dy * long,
          )
          ..lineTo(center.dx + normal.dx * side, center.dy + normal.dy * side)
          ..lineTo(center.dx - normal.dx * side, center.dy - normal.dy * side)
          ..close(),
        compass,
      );
    }
    canvas.drawCircle(
      center,
      size.width * .092,
      Paint()..color = const Color(0xFFBE9146),
    );
    canvas.drawCircle(
      center,
      size.width * .055,
      Paint()..color = const Color(0xFF073B34),
    );

    final title = TextPainter(
      text: TextSpan(
        text: 'TRILUMA',
        style: TextStyle(
          color: const Color(0xFFFFF6DB),
          fontFamily: 'DM Serif Display',
          fontSize: size.width * .082,
          letterSpacing: size.width * .006,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset(center.dx - title.width / 2, size.height * .70));
  }

  @override
  bool shouldRepaint(_PlaygroundBadgePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.pointer != pointer;
}

class _PlaygroundFoilPainter extends CustomPainter {
  const _PlaygroundFoilPainter({required this.phase, required this.pointer});

  final double phase;
  final Offset pointer;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.save();
    canvas.clipPath(_badgePath(size, inset: size.width * .035));
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          begin: Alignment(-1.5 + pointer.dx + phase * 2, -1),
          end: Alignment(.4 + pointer.dx + phase * 2, 1),
          colors: const [
            Colors.transparent,
            Color(0xAAFFFFFF),
            Color(0x337FE8FF),
            Colors.transparent,
          ],
          stops: const [0, .42, .56, 1],
        ).createShader(bounds),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlaygroundFoilPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.pointer != pointer;
}
