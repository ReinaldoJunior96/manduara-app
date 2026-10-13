import 'package:flutter/material.dart' hide Badge;

import '../data/badge_demo.dart';
import '../models/home_models.dart';
import '../theme/triluma_theme.dart';
import '../widgets/holographic_sticker.dart';
import 'badge_detail_page.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({
    super.key,
    required this.place,
    required this.badge,
    required this.data,
  });

  final Place place;
  final Badge badge;
  final BadgeDemo data;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Conheça o local')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Text(
              place.name,
              style: TrilumaTheme.editorial.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text('${place.region}\n${place.category}'),
            const SizedBox(height: 24),
            if (place.photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColoredBox(
                  color: TrilumaColors.surface,
                  child: Image.asset(
                    place.photo!,
                    height: 360,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              place.description,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Emblema do local',
              style: TrilumaTheme.editorial.copyWith(fontSize: 26),
            ),
            Center(
              child: SizedBox(
                width: 280,
                child: HolographicSticker(
                  imagePath: badge.art,
                  focus: badge.focus,
                  title: badge.name,
                  rarity: badge.rarity,
                  compact: true,
                  isUnlocked: badge.isUnlocked,
                  padding: const EdgeInsets.all(8),
                  statusLabel: 'Conquistado (demonstração)',
                ),
              ),
            ),
            Text(
              '${badge.rarity.label} · Coleção ${data.collectionName(badge.collectionId)}',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BadgeDetailPage(badge: badge, data: data),
                ),
              ),
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Explorar emblema'),
            ),
          ],
        ),
      ),
    ),
  );
}
