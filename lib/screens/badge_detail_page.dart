import 'package:flutter/material.dart' hide Badge;

import '../data/badge_demo.dart';
import '../data/place_demo.dart';
import '../models/home_models.dart';
import '../theme/manduara_icons.dart';
import '../theme/manduara_theme.dart';
import '../widgets/holographic/badge_rarity_style.dart';
import '../widgets/holographic_sticker.dart';
import '../widgets/home/home_components.dart' show showDemoNotice;
import '../widgets/starfall_backdrop.dart';
import 'place_detail_page.dart';

/// A seal up close: the interactive sticker over a faint starfall, then its
/// story, status and place, in the Manduarã travel-journal style.
class BadgeDetailPage extends StatefulWidget {
  const BadgeDetailPage({super.key, required this.badge, required this.data});
  final Badge badge;
  final BadgeDemo data;
  @override
  State<BadgeDetailPage> createState() => _BadgeDetailPageState();
}

class _BadgeDetailPageState extends State<BadgeDetailPage> {
  bool _expanded = false;

  /// The showcase only animates while it is on screen.
  bool _showcaseVisible = true;

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final date = badge.unlockedAt;
    final collection = widget.data.collectionName(badge.collectionId);
    final siblings = widget.data.badges
        .where((b) => b.collectionId == badge.collectionId)
        .toList();
    final next = siblings[(siblings.indexOf(badge) + 1) % siblings.length];
    final place = PlaceDemo.byId(badge.placeId);
    final tint = BadgeRarityStyle.of(badge.rarity).colors.first;
    return Scaffold(
      backgroundColor: ManduaraColors.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth == 0) {
                  final width = MediaQuery.sizeOf(context).width.clamp(0, 680);
                  final visible = notification.metrics.pixels < width * 1.1;
                  if (visible != _showcaseVisible) {
                    setState(() => _showcaseVisible = visible);
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          _RoundButton(
                            tooltip: 'Voltar',
                            icon: ManduaraIcons.arrowLeft,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'UM LUGAR, UMA LEMBRANÇA',
                              textAlign: TextAlign.center,
                              style: ManduaraText.eyebrow,
                            ),
                          ),
                          _RoundButton(
                            tooltip: 'Compartilhar',
                            icon: ManduaraIcons.share,
                            onPressed: () =>
                                showDemoNotice(context, 'O compartilhamento'),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Positioned.fill(
                          child: StarfallBackdrop(
                            tint: tint,
                            animate: badge.isUnlocked && _showcaseVisible,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          key: ValueKey(badge.id),
                          tween: Tween(begin: .94, end: 1),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, child) =>
                              Transform.scale(scale: value, child: child),
                          child: HolographicSticker(
                            imagePath: badge.art,
                            focus: badge.focus,
                            title: badge.name,
                            rarity: badge.rarity,
                            isUnlocked: badge.isUnlocked,
                            imageFit: badge.isLogo
                                ? BoxFit.contain
                                : BoxFit.cover,
                            statusLabel: 'Conquistado (demonstração)',
                            enableUnlockAnimation: false,
                            showcase: true,
                            enableIdleAnimation:
                                badge.isUnlocked && _showcaseVisible,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      badge.isUnlocked
                          ? 'Arraste para explorar os reflexos'
                          : 'Ainda não conquistado',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: ManduaraText.body,
                        fontSize: 12,
                        color: ManduaraColors.muted,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.toUpperCase(),
                            style: ManduaraText.eyebrow,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.name,
                            style: ManduaraText.headline.copyWith(fontSize: 36),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _RarityPill(rarity: badge.rarity),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    ManduaraIcons.tag,
                                    size: 15,
                                    color: ManduaraColors.muted,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    badge.category.label,
                                    style: const TextStyle(
                                      fontFamily: ManduaraText.body,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: ManduaraColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(badge.description, style: _bodyText),
                          if (_expanded) ...[
                            const SizedBox(height: 12),
                            Text(badge.longDescription, style: _bodyText),
                          ],
                          TextButton(
                            key: const ValueKey('expand-description'),
                            onPressed: () =>
                                setState(() => _expanded = !_expanded),
                            style: TextButton.styleFrom(
                              foregroundColor: ManduaraColors.ink,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              _expanded ? 'Ler menos' : 'Ler mais',
                              style: ManduaraText.bodyStrong,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _InfoCard(
                            icon: ManduaraIcons.award,
                            title: 'Sobre o selo',
                            text: '${badge.rarity.label} · $collection',
                          ),
                          _InfoCard(
                            icon: badge.isUnlocked
                                ? ManduaraIcons.circleCheck
                                : ManduaraIcons.lock,
                            title: 'Status de conquista',
                            text: badge.isUnlocked
                                ? 'Conquistado — demonstração'
                                      '${date == null ? '' : '\nData fictícia: ${_date(date)}'}'
                                : 'Ainda não conquistado',
                          ),
                          if (!badge.isUnlocked)
                            const _InfoCard(
                              icon: ManduaraIcons.compass,
                              title: 'Como conquistar este selo',
                              text: 'Na versão completa, os requisitos de visita serão apresentados aqui. Esta demonstração não realiza check-in nem concede conquistas.',
                            ),
                          _InfoCard(
                            icon: ManduaraIcons.bookOpen,
                            title: 'História ou significado',
                            text: badge.id == 'avenida-do-reggae'
                                ? badge.longDescription
                                : 'Conteúdo provisório: a história deste selo será adicionada após revisão editorial.',
                          ),
                          _InfoCard(
                            icon: ManduaraIcons.mapPin,
                            title: 'Local relacionado',
                            text: place != null
                                ? '${place.name}\n${place.region}\n${place.category}'
                                : '${badge.name}\nInformações de localização ainda não cadastradas nesta demonstração.',
                          ),
                          const SizedBox(height: 8),
                          if (place != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: ManduaraColors.ink,
                                  foregroundColor: ManduaraColors.paper,
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  textStyle: ManduaraText.bodyStrong.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                icon: const Icon(
                                  ManduaraIcons.mapPin,
                                  size: 18,
                                ),
                                label: const Text('Conhecer o local'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => PlaceDetailPage(
                                      place: place,
                                      badge: badge,
                                      data: widget.data,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (siblings.length > 1)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ManduaraColors.ink,
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(
                                  color: ManduaraColors.hairline,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: ManduaraText.bodyStrong.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => BadgeDetailPage(
                                    badge: next,
                                    data: widget.data,
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                ManduaraIcons.arrowRight,
                                size: 18,
                              ),
                              label: const Text('Próximo selo da coleção'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _bodyText = TextStyle(
    fontFamily: ManduaraText.body,
    fontSize: 16,
    height: 1.55,
    color: ManduaraColors.muted,
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      fixedSize: const Size(44, 44),
      backgroundColor: ManduaraColors.card,
      side: const BorderSide(color: ManduaraColors.hairline),
    ),
    icon: Icon(icon, size: 20, color: ManduaraColors.ink),
  );
}

/// Rarity as a small pill: a dot in the seal's colour and its name.
class _RarityPill extends StatelessWidget {
  const _RarityPill({required this.rarity});
  final BadgeRarity rarity;

  @override
  Widget build(BuildContext context) {
    final tint = BadgeRarityStyle.of(rarity).colors.first;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          tint.withValues(alpha: .18),
          ManduaraColors.card,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color.alphaBlend(
            tint.withValues(alpha: .45),
            ManduaraColors.hairline,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(rarity.label, style: ManduaraText.bodyStrong),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title, text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: ManduaraColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: ManduaraColors.cardBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ManduaraColors.wax.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: ManduaraColors.wax),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ManduaraText.title.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: ManduaraText.body,
                  fontSize: 14,
                  height: 1.5,
                  color: ManduaraColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
