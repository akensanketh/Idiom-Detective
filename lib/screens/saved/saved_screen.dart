import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/idiom_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/idiom_card.dart';
import '../detail/idiom_detail_screen.dart';

/// Saved screen — shows the user's favorite (starred) idioms and recently viewed.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
      context.read<IdiomProvider>().loadRecentlyViewed();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.teal,
          labelColor: AppConstants.teal,
          unselectedLabelColor:
              isDark ? AppConstants.slateText : AppConstants.warmGrayDark,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(
              icon: Icon(Icons.star_rounded, size: 20),
              text: 'Favorites',
            ),
            Tab(
              icon: Icon(Icons.history_rounded, size: 20),
              text: 'Recent',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FavoritesTab(),
          _RecentTab(),
        ],
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final idiomProvider = context.read<IdiomProvider>();

    if (favProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppConstants.teal,
          strokeWidth: 2,
        ),
      );
    }

    if (favProvider.favorites.isEmpty) {
      return const EmptyState(
        icon: Icons.star_border_rounded,
        title: 'No Favorites Yet',
        subtitle:
            'Tap the star icon on any idiom to save it here for quick access.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: favProvider.favorites.length,
      itemBuilder: (context, index) {
        final idiom = favProvider.favorites[index];
        return Dismissible(
          key: Key('fav_${idiom.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppConstants.errorRed.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: AppConstants.errorRed,
            ),
          ),
          onDismissed: (_) async {
            await favProvider.toggleFavorite(idiom.id);
            idiomProvider.updateIdiomFavoriteState(idiom.id, false);
          },
          child: IdiomCard(
            idiom: idiom,
            onTap: () {
              idiomProvider.selectIdiom(idiom.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IdiomDetailScreen(idiomId: idiom.id),
                ),
              );
            },
            onFavorite: () async {
              final isFav = await favProvider.toggleFavorite(idiom.id);
              idiomProvider.updateIdiomFavoriteState(idiom.id, isFav);
            },
          ),
        );
      },
    );
  }
}

class _RecentTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final idiomProvider = context.watch<IdiomProvider>();
    final favProvider = context.read<FavoritesProvider>();

    if (idiomProvider.recentlyViewed.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'No History Yet',
        subtitle:
            'Idioms you view will appear here for quick reference.',
      );
    }

    return Column(
      children: [
        // Clear history button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => idiomProvider.clearRecentlyViewed(),
                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                label: const Text('Clear History'),
                style: TextButton.styleFrom(
                  foregroundColor: AppConstants.errorRed,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: idiomProvider.recentlyViewed.length,
            itemBuilder: (context, index) {
              final idiom = idiomProvider.recentlyViewed[index];
              return IdiomCard(
                idiom: idiom,
                onTap: () {
                  idiomProvider.selectIdiom(idiom.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          IdiomDetailScreen(idiomId: idiom.id),
                    ),
                  );
                },
                onFavorite: () async {
                  final isFav =
                      await favProvider.toggleFavorite(idiom.id);
                  idiomProvider.updateIdiomFavoriteState(
                      idiom.id, isFav);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
