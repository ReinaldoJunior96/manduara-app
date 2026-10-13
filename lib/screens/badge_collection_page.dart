import 'package:flutter/material.dart' hide Badge;

import '../data/badge_demo.dart';
import '../models/home_models.dart';
import '../theme/manduara_icons.dart';
import '../theme/manduara_theme.dart';
import '../widgets/holographic/badge_rarity_style.dart';
import '../widgets/home/home_components.dart' show showDemoNotice;
import '../widgets/home/home_sections.dart';
import 'badge_detail_page.dart';

/// "Selos": every seal of the collection, with the journey so far and
/// filters by category and rarity, in the Manduarã travel-journal style.
class BadgeCollectionPage extends StatefulWidget {
  const BadgeCollectionPage({super.key, this.initialCategory});
  final BadgeCategory? initialCategory;
  @override
  State<BadgeCollectionPage> createState() => _BadgeCollectionPageState();
}

class _BadgeCollectionPageState extends State<BadgeCollectionPage> {
  final _scroll = ScrollController();
  late Future<BadgeDemo> _data = BadgeDemo.load();
  late BadgeCategory? _category = widget.initialCategory;
  BadgeRarity? _rarity;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ManduaraColors.paper,
    extendBody: true,
    bottomNavigationBar: ManduaraNavigationBar(
      selectedIndex: 3,
      onHome: () => Navigator.maybePop(context),
      onBadges: () {
        if (_scroll.hasClients) _scroll.jumpTo(0);
      },
    ),
    body: Stack(
      children: [
        SafeArea(
          bottom: false,
          child: FutureBuilder<BadgeDemo>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _Message(
                  icon: ManduaraIcons.compass,
                  text: 'Não foi possível carregar os selos locais.',
                  action: 'Tentar novamente',
                  onAction: () => setState(() => _data = BadgeDemo.reload()),
                );
              }
              final data = snapshot.data;
              // The local catalogue loads in a moment; keep the page still.
              if (data == null) return const SizedBox.expand();
              return _content(data);
            },
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 120,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .6],
                  colors: [Color(0x00F5EFE4), ManduaraColors.paper],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _content(BadgeDemo data) {
    final badges = data.filter(category: _category, rarity: _rarity);
    final unlocked = data.badges.where((b) => b.isUnlocked).toList();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: LayoutBuilder(
          builder: (context, box) {
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final columns = scale > 1.6 ? 1 : (box.maxWidth >= 650 ? 3 : 2);
            return CustomScrollView(
              key: const PageStorageKey('badge-collection-scroll'),
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const ManduaraMark(size: 30),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'MANDUARÃ · COLEÇÃO',
                            style: ManduaraText.eyebrow,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Buscar selos',
                          onPressed: () =>
                              showDemoNotice(context, 'A busca de selos'),
                          style: IconButton.styleFrom(
                            fixedSize: const Size(44, 44),
                            backgroundColor: ManduaraColors.card,
                            side: const BorderSide(
                              color: ManduaraColors.hairline,
                            ),
                          ),
                          icon: const Icon(
                            ManduaraIcons.compass,
                            size: 20,
                            color: ManduaraColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Sua '),
                          TextSpan(
                            text: 'coleção',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: ManduaraColors.wax,
                            ),
                          ),
                        ],
                      ),
                      style: ManduaraText.headline,
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Cada selo guarda a lembrança de um lugar.',
                      style: TextStyle(
                        fontFamily: ManduaraText.body,
                        fontSize: 15,
                        color: ManduaraColors.muted,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _JourneyCard(unlocked: unlocked),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: SealFilterTabs(
                      selected: _category,
                      onChanged: (category) =>
                          setState(() => _category = category),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        RarityFilterPill(
                          key: const ValueKey('filter-Todas'),
                          label: 'Todas',
                          selected: _rarity == null,
                          onTap: () => setState(() => _rarity = null),
                        ),
                        for (final rarity in BadgeRarity.values)
                          RarityFilterPill(
                            key: ValueKey('filter-${rarity.label}'),
                            label: rarity.label,
                            dot: BadgeRarityStyle.of(rarity).colors.first,
                            selected: _rarity == rarity,
                            onTap: () => setState(() => _rarity = rarity),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '${badges.length} ${badges.length == 1 ? 'selo' : 'selos'} · coleção de demonstração',
                      style: const TextStyle(
                        fontFamily: ManduaraText.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ManduaraColors.muted,
                      ),
                    ),
                  ),
                ),
                if (badges.isEmpty)
                  SliverToBoxAdapter(
                    child: _Message(
                      icon: ManduaraIcons.compass,
                      text: 'Nenhum selo com estes filtros.',
                      action: 'Limpar filtros',
                      onAction: () => setState(() {
                        _category = null;
                        _rarity = null;
                      }),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverGrid.builder(
                    itemCount: badges.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: _cardHeight(
                        (box.maxWidth - 40 - (columns - 1) * 12) / columns,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return SealCard(
                        key: ValueKey('badge-${badge.id}'),
                        badge: badge,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                BadgeDetailPage(badge: badge, data: data),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// A [SealCard] is a square seal plus two lines of name and a rarity line.
  double _cardHeight(double width) {
    final scaler = MediaQuery.textScalerOf(context);
    return (width - 16) +
        22 +
        4 +
        scaler.scale(13) * 1.25 * 2 +
        2 +
        scaler.scale(11) * 1.4 +
        6;
  }
}

/// Journey so far: overall progress and the seals collected per rarity.
class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.unlocked});
  final List<Badge> unlocked;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: ManduaraColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: ManduaraColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox.square(
              dimension: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CircularProgressIndicator(
                    value: BadgeDemo.collected / BadgeDemo.total,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    color: ManduaraColors.ink,
                    backgroundColor: ManduaraColors.hairline,
                  ),
                  Center(
                    child: Text(
                      '${(BadgeDemo.progress * 100).round()}%',
                      style: ManduaraText.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sua jornada', style: ManduaraText.title),
                  SizedBox(height: 2),
                  Text(
                    '${BadgeDemo.collected} de ${BadgeDemo.total} lembranças guardadas',
                    style: TextStyle(
                      fontFamily: ManduaraText.body,
                      fontSize: 14,
                      color: ManduaraColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: ManduaraColors.hairline),
        const SizedBox(height: 14),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            for (final rarity in BadgeRarity.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: BadgeRarityStyle.of(rarity).colors.first,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${unlocked.where((b) => b.rarity == rarity).length}',
                    style: ManduaraText.bodyStrong,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      rarity.label,
                      style: const TextStyle(
                        fontFamily: ManduaraText.body,
                        fontSize: 13,
                        color: ManduaraColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  );
}

/// Rarity filter: an outlined pill with the rarity's colour dot; filled in
/// ink when selected.
class RarityFilterPill extends StatelessWidget {
  const RarityFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dot;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? ManduaraColors.ink : ManduaraColors.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? ManduaraColors.ink : ManduaraColors.hairline,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dot case final color?) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: ManduaraText.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? ManduaraColors.paper
                          : ManduaraColors.ink,
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

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final String text, action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: ManduaraColors.wax),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: ManduaraText.body,
            fontSize: 15,
            color: ManduaraColors.muted,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(foregroundColor: ManduaraColors.ink),
          child: Text(action, style: ManduaraText.bodyStrong),
        ),
      ],
    ),
  );
}
