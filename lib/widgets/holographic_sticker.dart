import 'dart:math' as math;

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'holographic/sticker_effects.dart';
import 'holographic/badge_rarity_style.dart';
import '../models/home_models.dart';

export 'holographic/sticker_effects.dart' show SealShape;

/// A badge seal: the place photo inside the wax seal of its [rarity], with
/// simulated foil optics and pointer-driven depth.
/// The badge's photo focus as an [Alignment] for [HolographicSticker.focus].
extension BadgeFocus on Badge {
  Alignment get focus => Alignment(focusX * 2 - 1, focusY * 2 - 1);
}

class HolographicSticker extends StatefulWidget {
  const HolographicSticker({
    super.key,
    this.imagePath = 'assets/images/imagem1.webp',
    this.title = 'Centro Histórico de São Luís',
    this.rarity = BadgeRarity.rare,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
    this.showcase = false,
    this.compact = false,
    this.isUnlocked = true,
    this.imageFit = BoxFit.cover,
    this.statusLabel = 'prévia',
    this.enableTilt = true,
    this.enableIdleAnimation = true,
    this.enableUnlockAnimation = true,
    this.focus = Alignment.center,
  });

  /// Point of the photo kept in view when it is cropped to the seal's disc,
  /// e.g. the subject chosen in the admin. Defaults to the centre.
  final Alignment focus;

  final bool showcase;
  final bool compact, isUnlocked;
  final BoxFit imageFit;
  final String statusLabel;
  final EdgeInsets padding;
  final String imagePath;
  final String title;
  final BadgeRarity rarity;
  final bool enableTilt;
  final bool enableIdleAnimation;
  final bool enableUnlockAnimation;

  @override
  State<HolographicSticker> createState() => _HolographicStickerState();
}

class _HolographicStickerState extends State<HolographicSticker>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final _unlock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  late final _idle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );
  late final _spring = AnimationController.unbounded(vsync: this);
  late final _frames = Listenable.merge([_unlock, _idle, _spring]);
  Offset _tilt = Offset.zero;
  Offset _releasedTilt = Offset.zero;
  bool _pressed = false;
  bool _returning = false;
  bool _reduceMotion = false;
  bool _foreground = true;
  bool _started = false;
  int? _pointer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!widget.compact && widget.isUnlocked) _configureAnimations();
  }

  @override
  void didUpdateWidget(HolographicSticker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enableTilt) {
      _tilt = Offset.zero;
      _returning = false;
      _spring.stop();
    }
    _configureAnimations();
  }

  void _configureAnimations() {
    if (widget.compact || !widget.isUnlocked) {
      _unlock.value = 1;
      _idle.stop();
      _spring.stop();
      return;
    }
    if (_reduceMotion || !widget.enableUnlockAnimation) {
      _unlock.value = 1;
    } else if (!_started) {
      _unlock.forward();
    }
    _started = true;
    if (_reduceMotion) {
      _spring.stop();
      _tilt = Offset.zero;
      _returning = false;
    }
    if (!_reduceMotion &&
        widget.enableIdleAnimation &&
        TickerMode.valuesOf(context).enabled &&
        _foreground &&
        !_pressed) {
      if (!_idle.isAnimating) _idle.repeat();
    } else {
      _idle.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      _configureAnimations();
    } else {
      _idle.stop();
      _unlock.value = 1;
      _spring.stop();
      setState(() {
        _pressed = false;
        _pointer = null;
        _returning = false;
        _tilt = Offset.zero;
      });
    }
  }

  Offset _normalized(Offset point, Size size) => Offset(
    (point.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
    (point.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
  );

  void _begin(PointerDownEvent event, Size size) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    // Raw pointer-down interrupts the reveal before the gesture arena settles.
    _unlock.value = 1;
    _idle.stop();
    _spring.stop();
    HapticFeedback.selectionClick();
    setState(() {
      _pressed = true;
      _returning = false;
      _tilt = widget.enableTilt && !_reduceMotion
          ? _normalized(event.localPosition, size)
          : Offset.zero;
    });
  }

  void _move(Offset point, Size size) {
    if (!_pressed || !widget.enableTilt || _reduceMotion) return;
    setState(() => _tilt = _normalized(point, size));
  }

  void _end() {
    if (!_pressed) return;
    _pointer = null;
    _releasedTilt = _tilt;
    setState(() {
      _pressed = false;
      _returning = !_reduceMotion;
    });
    if (!_reduceMotion) {
      _spring.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 170, damping: 19),
          1,
          0,
          0,
        ),
      );
    }
    _configureAnimations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unlock.dispose();
    _idle.dispose();
    _spring.dispose();
    super.dispose();
  }

  SealShape get _style => BadgeRarityStyle.shapeOf(widget.rarity);

  /// The photo framed to the seal's disc, so the crop matches what shows.
  Widget _framed(Widget photo) => Center(
    child: FractionallySizedBox(
      widthFactor: _style.discFraction,
      heightFactor: _style.discFraction,
      child: photo,
    ),
  );

  Widget _staticSticker() {
    final finish = BadgeRarityStyle.of(
      widget.isUnlocked ? widget.rarity : BadgeRarity.common,
    );
    final image = Image.asset(
      widget.imagePath,
      fit: widget.imageFit,
      alignment: widget.focus,
      cacheWidth: widget.compact ? 400 : 1000,
      errorBuilder: (_, _, _) =>
          const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
    final art = _framed(
      widget.imageFit == BoxFit.contain
          ? Transform.scale(scale: .75, child: image)
          : image,
    );
    return Semantics(
      image: true,
      label:
          '${widget.title}, ${widget.rarity.label}, ${widget.isUnlocked ? widget.statusLabel : 'Ainda não conquistado'}',
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: Padding(
            padding: widget.padding,
            child: AspectRatio(
              aspectRatio: .94,
              child: CustomPaint(
                painter: StickerFramePainter(
                  light: Offset.zero,
                  colors: finish.colors,
                  frameStyle: finish.frameStyle,
                  ornate: finish.ornate,
                  style: _style,
                ),
                child: ClipPath(
                  clipper: StickerClipper(style: _style),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: const Color(0xFF243F3B),
                        child: widget.isUnlocked
                            ? art
                            : ColorFiltered(
                                colorFilter: const ColorFilter.matrix([
                                  .2126,
                                  .7152,
                                  .0722,
                                  0,
                                  0,
                                  .2126,
                                  .7152,
                                  .0722,
                                  0,
                                  0,
                                  .2126,
                                  .7152,
                                  .0722,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                ]),
                                child: Opacity(opacity: .35, child: art),
                              ),
                      ),
                      if (!widget.isUnlocked)
                        const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            size: 30,
                            color: Color(0xFFFFFCF7),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact || !widget.isUnlocked) return _staticSticker();
    final finish = BadgeRarityStyle.of(widget.rarity);
    final colors = finish.colors;
    return Semantics(
      label:
          '${widget.title}, selo ${widget.rarity.label}, ${widget.statusLabel}. Arraste para explorar.',
      image: true,
      child: ExcludeSemantics(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: widget.padding,
              child: AspectRatio(
                aspectRatio: 0.94,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return Listener(
                      onPointerDown: (event) => _begin(event, size),
                      onPointerUp: (event) {
                        if (event.pointer == _pointer) _end();
                      },
                      onPointerCancel: (event) {
                        if (event.pointer == _pointer) _end();
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (event) => _move(event.localPosition, size),
                        onPanUpdate: (event) =>
                            _move(event.localPosition, size),
                        onPanEnd: (_) => _end(),
                        onPanCancel: _end,
                        child: RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _frames,
                            child: _framed(
                              RepaintBoundary(
                                child: Image.asset(
                                  widget.imagePath,
                                  fit: widget.imageFit,
                                  alignment: widget.focus,
                                  cacheWidth: 1000,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                            builder: (context, photo) {
                              final t = _unlock.value;
                              final reveal = Curves.elasticOut.transform(
                                (t / 0.78).clamp(0.0, 1.0),
                              );
                              final idleEnabled =
                                  widget.enableIdleAnimation &&
                                  !_reduceMotion &&
                                  TickerMode.valuesOf(context).enabled &&
                                  _foreground &&
                                  !_pressed;
                              final wave = idleEnabled
                                  ? math.sin(_idle.value * math.pi * 2)
                                  : 0.0;
                              final pointerTilt = _returning
                                  ? _releasedTilt * _spring.value
                                  : _tilt;
                              final entranceTilt =
                                  math.sin(t * math.pi * 2) * (1 - t) * 0.35;
                              final tilt =
                                  pointerTilt * finish.tilt +
                                  Offset(entranceTilt, 0);
                              // +/- 18 degrees. Translation and light share the
                              // same normalized pointer, so optics track tilt.
                              final transform = Matrix4.identity()
                                ..setEntry(3, 2, 0.0014)
                                ..rotateX(-tilt.dy * math.pi / 10)
                                ..rotateY(tilt.dx * math.pi / 10)
                                ..rotateZ(
                                  entranceTilt * 0.12 +
                                      (widget.showcase ? wave * .012 : 0),
                                );
                              final light =
                                  tilt +
                                  (widget.showcase
                                      ? Offset(
                                          wave * .65,
                                          idleEnabled
                                              ? math.cos(
                                                      _idle.value * math.pi * 2,
                                                    ) *
                                                    .35
                                              : 0,
                                        )
                                      : Offset(wave * .08, 0));
                              return Opacity(
                                opacity: (t * 5).clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    wave * (widget.showcase ? 7 : 2),
                                  ),
                                  child: Transform.scale(
                                    scale: 0.66 + 0.34 * reveal,
                                    child: CustomPaint(
                                      painter: StickerShadowPainter(
                                        style: _style,
                                        tilt: tilt,
                                        lift: wave,
                                        strength:
                                            finish.shadow *
                                            (widget.showcase ? .45 : 1),
                                        glow: finish.glow,
                                        glowColor: finish.colors.first,
                                      ),
                                      child: Transform(
                                        key: const ValueKey('sticker-tilt'),
                                        alignment: Alignment.center,
                                        transform: transform,
                                        child: CustomPaint(
                                          foregroundPainter:
                                              StickerSparkPainter(
                                                style: _style,
                                                frameStyle: finish.frameStyle,
                                                ornate: finish.ornate,
                                                unlock: t,
                                                particleCount: widget.showcase
                                                    ? 0
                                                    : finish.particles,
                                                rimColors: widget.showcase
                                                    ? finish.showcaseColors
                                                    : const [],
                                                rimStrength: widget.showcase
                                                    ? math.max(
                                                        .35,
                                                        finish.shine,
                                                      )
                                                    : 0,
                                                light: light,
                                                idle:
                                                    (idleEnabled ||
                                                        widget.showcase &&
                                                            !_reduceMotion)
                                                    ? _idle.value
                                                    : 0,
                                                enableIdle: idleEnabled,
                                              ),
                                          child: CustomPaint(
                                            painter: StickerFramePainter(
                                              style: _style,
                                              frameStyle: finish.frameStyle,
                                              ornate: finish.ornate,
                                              light: light,
                                              colors: colors,
                                            ),
                                            foregroundPainter:
                                                HolographicLightPainter(
                                                  style: _style,
                                                  light: light,
                                                  sweep: t < 1
                                                      ? -2.5 + t * 5
                                                      : 0,
                                                  colors: colors,
                                                  intensity:
                                                      finish.shine *
                                                      (widget.showcase
                                                          ? .75
                                                          : 1),
                                                  glint: finish.glint,
                                                ),
                                            child: ClipPath(
                                              clipper: StickerClipper(
                                                style: _style,
                                              ),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  const ColoredBox(
                                                    color: Color(0xFF243F3B),
                                                  ),
                                                  Transform.translate(
                                                    offset:
                                                        tilt *
                                                        (7 * finish.parallax),
                                                    child: Transform.scale(
                                                      scale:
                                                          widget.imageFit ==
                                                              BoxFit.contain
                                                          ? .75
                                                          : 1.08,
                                                      child: photo,
                                                    ),
                                                  ),
                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: const [
                                                          Color(0x66233130),
                                                          Colors.transparent,
                                                          Color(0x11233130),
                                                          Color(0xF51A302D),
                                                          Color(0xFF172F2D),
                                                        ],
                                                        stops: [
                                                          0,
                                                          0.22,
                                                          0.48,
                                                          0.79,
                                                          1,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Transform.translate(
                                                    offset:
                                                        tilt *
                                                        (-4 * finish.parallax),
                                                    child: _StickerLettering(
                                                      style: _style,
                                                      title: widget.title,
                                                      rarity:
                                                          widget.rarity.label,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerLettering extends StatelessWidget {
  const _StickerLettering({
    required this.title,
    required this.rarity,
    required this.style,
  });

  final SealShape style;

  final String title;
  final String rarity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final unit = constraints.maxWidth;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              // Pressed seals keep the title inside their smaller disc.
              bottom: unit * (style.isPressed ? 0.21 : 0.13),
              left: unit * (style.isPressed ? 0.25 : 0.16),
              right: unit * (style.isPressed ? 0.25 : 0.16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: unit * 0.067,
                      height: 1.08,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFF3D9),
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                  ),
                  SizedBox(height: unit * 0.025),
                  Text(
                    '✦  ${rarity.toUpperCase()}  ✦',
                    textScaler: TextScaler.noScaling,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFBFE5E1),
                      fontSize: unit * 0.027,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
