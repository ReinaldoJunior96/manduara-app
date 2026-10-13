import 'package:flutter/material.dart';

import 'topographic_decoration.dart';

import '../../models/home_models.dart';
import '../../theme/triluma_theme.dart';
import '../holographic/badge_rarity_style.dart';

void showDemoNotice(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '$feature estará disponível em uma próxima etapa. Esta é uma demonstração visual.',
        ),
      ),
    );
}

class TrilumaHeader extends StatelessWidget {
  const TrilumaHeader({
    super.key,
    this.headline = 'Sua próxima descoberta',
    this.subtitle = 'História, cultura e lugares extraordinários para explorar pelo Maranhão.',
  });
  final String headline, subtitle;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const TopographicDecoration(opacity: .18, rightOnly: true),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Manduarã',
                style: TrilumaTheme.editorial.copyWith(
                  fontSize: 52,
                  height: 1.05,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Pesquisar (demonstração)',
              onPressed: () => showDemoNotice(context, 'A pesquisa'),
              icon: const Icon(Icons.search, size: 25),
            ),
            const SizedBox(
              width: 40,
              height: 48,
              child: Tooltip(
                message: 'Notificações — em breve',
                child: Icon(Icons.notifications_none, size: 25),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'LUGARES QUE FICAM COM VOCÊ',
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 2.2,
            color: TrilumaColors.gold,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, box) {
            final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: TrilumaTheme.editorial.copyWith(
                          fontSize: box.maxWidth < 330 ? 32 : 36,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 28,
                        height: 2,
                        color: TrilumaColors.gold,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: TrilumaColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!largeText)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 34,
                            height: 42,
                            child: CustomPaint(painter: CompassRose()),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'EXPLORAR\nCOLECIONAR\nPERTENCER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 7,
                              height: 2.1,
                              letterSpacing: 1.4,
                              color: TrilumaColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

/// Local imagery only; a missing photo never masquerades as another place.
class RarityChip extends StatelessWidget {
  const RarityChip({super.key, required this.rarity});
  final BadgeRarity rarity;
  @override
  Widget build(BuildContext context) {
    final style = BadgeRarityStyle.of(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.accent.withValues(alpha: .18)),
      ),
      child: Text(
        rarity.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: style.accent,
        ),
      ),
    );
  }
}
