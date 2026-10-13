import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;

import '../../data/badge_demo.dart';
import '../../data/home_demo.dart';
import '../../models/home_models.dart';
import '../../screens/badge_collection_page.dart';
import '../../screens/badge_detail_page.dart';
import '../../theme/manduara_icons.dart';
import '../../theme/manduara_theme.dart';
import '../holographic/badge_rarity_style.dart';
import '../holographic_sticker.dart';
import 'home_components.dart' show showDemoNotice;

/// Text scale relative to 14 px, used to grow fixed-height blocks.
double _scaleOf(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14;

/// Faint contour lines behind the top of the Home, like a travel map. They
/// drift slowly sideways; still when motion is reduced or the Home is hidden.
class ContourBackdrop extends StatefulWidget {
  const ContourBackdrop({super.key, this.animate = true});

  /// False pauses the drift, e.g. once the lines have scrolled out of view.
  final bool animate;

  @override
  State<ContourBackdrop> createState() => _ContourBackdropState();
}

class _ContourBackdropState extends State<ContourBackdrop>
    with SingleTickerProviderStateMixin {
  late final _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  void _sync() {
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      if (!_drift.isAnimating) _drift.repeat();
    } else {
      _drift.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(ContourBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(painter: _ContourPainter(_drift), size: Size.infinite),
    ),
  );
}

class _ContourPainter extends CustomPainter {
  _ContourPainter(this.drift) : super(repaint: drift);
  final Animation<double> drift;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ManduaraColors.contour.withValues(alpha: .7);
    final w = size.width;
    final shift = drift.value * math.pi * 2;
    // Two families of lines: a low band and a tighter group up right. Each
    // line is two mixed sine waves, so the sideways drift loops seamlessly.
    for (var i = 0; i < 5; i++) {
      final base = 62.0 + i * 26;
      final path = Path();
      for (var x = -20.0; x <= w + 20; x += 6) {
        final t = x / w * math.pi * 2;
        final y =
            base +
            14 * math.sin(t * .9 + shift + i * .55) +
            6 * math.sin(t * 2.1 - shift * 2 + i);
        x == -20 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
    for (var i = 0; i < 3; i++) {
      final base = 18.0 + i * 16;
      final path = Path();
      for (var x = w * .5; x <= w + 20; x += 6) {
        final t = x / w * math.pi * 2;
        final y = base + 10 * math.sin(t * 1.4 - shift + i * .8);
        x == w * .5 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ContourPainter oldDelegate) => false;
}

/// Brand mark: a terracotta wax seal pressed with an "M".
class ManduaraMark extends StatelessWidget {
  const ManduaraMark({super.key, this.size = 34});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Manduarã',
    image: true,
    child: SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _MarkPainter()),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final blob = Path();
    for (var i = 0; i <= 120; i++) {
      final a = i / 120 * math.pi * 2;
      final k = .9 + .05 * math.sin(5 * a + .5) + .03 * math.sin(9 * a + 1.3);
      final p = c + Offset(math.cos(a), math.sin(a)) * r * k;
      i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(blob..close(), Paint()..color = ManduaraColors.wax);
    canvas.drawCircle(
      c,
      r * .56,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .08
        ..color = ManduaraColors.paper.withValues(alpha: .7),
    );
    final m = r * .3;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - m, c.dy + m)
        ..lineTo(c.dx - m, c.dy - m)
        ..lineTo(c.dx, c.dy + m * .1)
        ..lineTo(c.dx + m, c.dy - m)
        ..lineTo(c.dx + m, c.dy + m),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = ManduaraColors.paper,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}

class ManduaraHeader extends StatelessWidget {
  const ManduaraHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const ManduaraMark(),
      const SizedBox(width: 10),
      const Expanded(
        child: Text(
          'Manduarã',
          style: TextStyle(
            fontFamily: ManduaraText.display,
            fontSize: 30,
            height: 1,
            color: ManduaraColors.ink,
          ),
        ),
      ),
      Stack(
        children: [
          IconButton(
            tooltip: 'Notificações',
            onPressed: () => showDemoNotice(context, 'As notificações'),
            style: IconButton.styleFrom(
              fixedSize: const Size(44, 44),
              backgroundColor: ManduaraColors.card,
              side: const BorderSide(color: ManduaraColors.hairline),
            ),
            icon: const Icon(
              ManduaraIcons.bell,
              size: 20,
              color: ManduaraColors.ink,
            ),
          ),
          const Positioned(
            top: 11,
            right: 12,
            child: IgnorePointer(
              child: SizedBox.square(
                dimension: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ManduaraColors.wax,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('SÃO LUÍS · MARANHÃO', style: ManduaraText.eyebrow),
      const SizedBox(height: 8),
      const Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Que lembrança você '),
            TextSpan(
              text: 'guarda',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: ManduaraColors.wax,
              ),
            ),
            TextSpan(text: ' hoje?'),
          ],
        ),
        style: ManduaraText.headline,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: const LinearProgressIndicator(
                value: BadgeDemo.collected / BadgeDemo.total,
                minHeight: 4,
                color: ManduaraColors.ink,
                backgroundColor: ManduaraColors.hairline,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Flexible so large accessibility text wraps instead of overflowing.
          const Flexible(
            child: Text(
              '${BadgeDemo.collected} de ${BadgeDemo.total} selos',
              textAlign: TextAlign.end,
              style: ManduaraText.bodyStrong,
            ),
          ),
        ],
      ),
    ],
  );
}

/// Category tabs with an underline on the active one. `null` means all.
class SealFilterTabs extends StatelessWidget {
  const SealFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final BadgeCategory? selected;
  final ValueChanged<BadgeCategory?> onChanged;

  static const _tabs = <(BadgeCategory?, String, IconData?)>[
    (null, 'Todos', null),
    (BadgeCategory.bars, 'Rolês e Bares', ManduaraIcons.beer),
    (BadgeCategory.culture, 'Cultura', ManduaraIcons.landmark),
    (BadgeCategory.nature, 'Natureza', ManduaraIcons.leaf),
    (BadgeCategory.places, 'Lugares', ManduaraIcons.mapPin),
  ];

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: ManduaraColors.hairline)),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (category, label, icon) in _tabs)
            SealFilterTab(
              key: ValueKey('filter-$label'),
              label: label,
              icon: icon,
              active: category == selected,
              onTap: () => onChanged(category),
            ),
        ],
      ),
    ),
  );
}

/// One underlined category tab, shared by the Home and the collection.
class SealFilterTab extends StatelessWidget {
  const SealFilterTab({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? ManduaraColors.ink : ManduaraColors.muted;
    return Semantics(
      selected: active,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          margin: const EdgeInsets.only(right: 22),
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: active ? ManduaraColors.wax : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: ManduaraText.body,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Featured place: photo card with its seal resting on the corner. In debug,
/// a long press on the seal previews the other rarities.
class FeaturedPlaceCard extends StatefulWidget {
  const FeaturedPlaceCard({super.key, required this.place});
  final Place place;

  @override
  State<FeaturedPlaceCard> createState() => _FeaturedPlaceCardState();
}

class _FeaturedPlaceCardState extends State<FeaturedPlaceCard> {
  BadgeRarity? _previewRarity;

  void _selectRarity() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Acabamentos · prévia de desenvolvimento'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final rarity in BadgeRarity.values)
                    ChoiceChip(
                      label: Text(rarity.label),
                      selected:
                          (_previewRarity ?? HomeDemo.badge.rarity) == rarity,
                      onSelected: (_) {
                        setState(() => _previewRarity = rarity);
                        Navigator.pop(sheetContext);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = _scaleOf(context).clamp(1.0, 2.2);
    final height = 206 * scale;
    const seal = 150.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.place.photo case final photo?)
                      Image.asset(photo, fit: BoxFit.cover, cacheWidth: 900),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [.35, 1],
                          colors: [Color(0x0017322C), Color(0xE017322C)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ManduaraColors.paper.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  child: Text(
                    'EM DESTAQUE',
                    style: TextStyle(
                      fontFamily: ManduaraText.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .9,
                      color: ManduaraColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: seal - 8,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: ManduaraText.display,
                      fontSize: 27,
                      height: 1,
                      color: ManduaraColors.paper,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.place.category,
                    style: TextStyle(
                      fontFamily: ManduaraText.body,
                      fontSize: 13,
                      color: ManduaraColors.paper.withValues(alpha: .85),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -8,
              bottom: -34,
              width: seal,
              height: seal,
              child: GestureDetector(
                onLongPress: kDebugMode ? _selectRarity : null,
                child: HolographicSticker(
                  key: const ValueKey('heritage-sticker'),
                  imagePath: HomeDemo.badge.art,
                  title: HomeDemo.badge.name,
                  rarity: _previewRarity ?? HomeDemo.badge.rarity,
                  focus: HomeDemo.badge.focus,
                  padding: EdgeInsets.zero,
                  enableIdleAnimation: false,
                  enableUnlockAnimation: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Sua estante": the seals collected so far, filtered by category.
class SealShelf extends StatefulWidget {
  const SealShelf({super.key, this.category});
  final BadgeCategory? category;

  @override
  State<SealShelf> createState() => _SealShelfState();
}

class _SealShelfState extends State<SealShelf> {
  late final Future<BadgeDemo> _data = BadgeDemo.load();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(child: Text('Sua estante', style: ManduaraText.title)),
          Flexible(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const BadgeCollectionPage(),
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: ManduaraColors.ink),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text('Ver todos', style: ManduaraText.bodyStrong),
                  ),
                  Icon(ManduaraIcons.chevronRight, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      FutureBuilder<BadgeDemo>(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          // The local catalogue loads in a moment; keep the space still
          // instead of spinning.
          if (data == null) return const SizedBox(height: 168);
          final badges = data
              .filter(category: widget.category)
              .where((b) => b.isUnlocked)
              .toList();
          if (badges.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ManduaraColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ManduaraColors.cardBorder),
              ),
              child: const Text(
                'Nenhuma lembrança nesta categoria ainda. Que tal visitar um lugar novo?',
                style: TextStyle(
                  fontFamily: ManduaraText.body,
                  fontSize: 14,
                  color: ManduaraColors.muted,
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, box) {
              // Three columns on phones, two when space or text size is tight.
              final columns = box.maxWidth >= 330 && _scaleOf(context) < 1.4
                  ? 3
                  : 2;
              const gap = 10.0;
              final width = (box.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final badge in badges.take(6))
                    SizedBox(
                      width: width,
                      child: SealCard(
                        badge: badge,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                BadgeDetailPage(badge: badge, data: data),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    ],
  );
}

/// Seal card used on the Home shelf and in the collection grid: the seal,
/// its name (always two lines tall, so rows align) and its rarity, with a
/// very faint halo in the rarity colour. Locked seals read "A descobrir".
class SealCard extends StatelessWidget {
  static const _nameHeight = 1.25;

  const SealCard({super.key, required this.badge, required this.onTap});
  final Badge badge;
  final VoidCallback onTap;

  /// Readable text colour for each rarity on the light card.
  static Color rarityTextColor(BadgeRarity rarity) => switch (rarity) {
    BadgeRarity.common => ManduaraColors.muted,
    BadgeRarity.rare => const Color(0xFF2F6FAF),
    BadgeRarity.epic => const Color(0xFF6E4C95),
    BadgeRarity.legendary => const Color(0xFF8A6418),
  };

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;
    final glow = unlocked
        ? BadgeRarityStyle.of(badge.rarity).colors.first
        : ManduaraColors.hairline;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (unlocked)
            BoxShadow(
              color: glow.withValues(alpha: .28),
              blurRadius: 16,
              spreadRadius: -2,
            ),
        ],
      ),
      child: Material(
        color: unlocked
            ? ManduaraColors.card
            : ManduaraColors.card.withValues(alpha: .55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color.alphaBlend(
              glow.withValues(alpha: .35),
              ManduaraColors.cardBorder,
            ),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: IgnorePointer(
                    child: HolographicSticker(
                      imagePath: badge.art,
                      title: badge.name,
                      rarity: badge.rarity,
                      focus: badge.focus,
                      compact: true,
                      isUnlocked: unlocked,
                      statusLabel: 'Conquistado (demonstração)',
                      padding: EdgeInsets.zero,
                      imageFit: badge.isLogo ? BoxFit.contain : BoxFit.cover,
                      enableTilt: false,
                      enableIdleAnimation: false,
                      enableUnlockAnimation: false,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height:
                      MediaQuery.textScalerOf(context).scale(13) *
                      _nameHeight *
                      2,
                  child: Center(
                    child: Text(
                      badge.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: ManduaraText.bodyStrong.copyWith(
                        height: _nameHeight,
                        color: unlocked
                            ? ManduaraColors.ink
                            : ManduaraColors.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                if (unlocked)
                  Text(
                    badge.rarity.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ManduaraText.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: rarityTextColor(badge.rarity),
                    ),
                  )
                else
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ManduaraIcons.lock,
                        size: 11,
                        color: ManduaraColors.muted,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'A descobrir',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: ManduaraText.body,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ManduaraColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Light floating navigation shared by the main screens: Início, Selos and
/// Perfil. The current tab sits on a soft pill.
class ManduaraNavigationBar extends StatelessWidget {
  const ManduaraNavigationBar({
    super.key,
    required this.onHome,
    this.onBadges,
    this.selectedIndex = 0,
  });

  /// 0 Início, 1 Selos, 2 Perfil.
  final int selectedIndex;
  final VoidCallback onHome;
  final VoidCallback? onBadges;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: ManduaraColors.card.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ManduaraColors.hairline),
        boxShadow: [
          BoxShadow(
            color: ManduaraColors.ink.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            _NavItem(
              label: 'Início',
              icon: ManduaraIcons.house,
              active: selectedIndex == 0,
              onTap: onHome,
            ),
            _NavItem(
              label: 'Selos',
              icon: ManduaraIcons.award,
              active: selectedIndex == 1,
              onTap: onBadges ?? () => showDemoNotice(context, 'Os selos'),
            ),
            _NavItem(
              label: 'Perfil',
              icon: ManduaraIcons.user,
              active: selectedIndex == 2,
              onTap: () => showDemoNotice(context, 'O perfil'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? ManduaraColors.ink : ManduaraColors.inactive;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? ManduaraColors.ink.withValues(alpha: .07)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: color),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ManduaraText.body,
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? ManduaraColors.wax : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
