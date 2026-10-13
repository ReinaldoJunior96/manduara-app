import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/home_demo.dart';
import '../models/home_models.dart';
import '../theme/manduara_theme.dart';
import '../widgets/home/home_sections.dart';
import 'badge_collection_page.dart';

class MyHomePage extends TrilumaHomePage {
  const MyHomePage({super.key, required this.title});
  final String title;
}

/// Manduarã Home: greeting with collection progress, category tabs, the
/// featured place with its seal and the shelf of collected seals.
class TrilumaHomePage extends StatefulWidget {
  const TrilumaHomePage({super.key});
  @override
  State<TrilumaHomePage> createState() => _TrilumaHomePageState();
}

class _TrilumaHomePageState extends State<TrilumaHomePage> {
  final _scroll = ScrollController();
  BadgeCategory? _category;

  /// The contour lines only animate while they are on screen.
  bool _topVisible = true;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toTop() {
    if (!_scroll.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Scaffold(
      backgroundColor: ManduaraColors.paper,
      // Content scrolls under the floating bar and fades out behind it.
      extendBody: true,
      bottomNavigationBar: ManduaraNavigationBar(
        onHome: _toTop,
        onBadges: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const BadgeCollectionPage()),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    final visible = notification.metrics.pixels < 260;
                    if (notification.depth == 0 && visible != _topVisible) {
                      setState(() => _topVisible = visible);
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    controller: _scroll,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ContourBackdrop(animate: _topVisible),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ManduaraHeader(),
                                  SizedBox(height: 26),
                                  HomeGreeting(),
                                ],
                              ),
                            ),
                          ],
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
                      const SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: FeaturedPlaceCard(place: HomeDemo.featured),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                        sliver: SliverToBoxAdapter(
                          child: SealShelf(category: _category),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
    ),
  );
}
