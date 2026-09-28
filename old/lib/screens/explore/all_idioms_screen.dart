import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/idiom_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/idiom_card.dart';
import '../detail/idiom_detail_screen.dart';

/// Screen that lists all idioms, optionally filtered by difficulty.
class AllIdiomsScreen extends StatefulWidget {
  final String? difficulty;

  const AllIdiomsScreen({super.key, this.difficulty});

  @override
  State<AllIdiomsScreen> createState() => _AllIdiomsScreenState();
}

class _AllIdiomsScreenState extends State<AllIdiomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdiomProvider>().loadAllIdioms(
            difficulty: widget.difficulty,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final idiomProvider = context.watch<IdiomProvider>();
    final title = widget.difficulty != null
        ? '${widget.difficulty![0].toUpperCase()}${widget.difficulty!.substring(1)} Idioms'
        : 'All Idioms';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (idiomProvider.allIdioms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${idiomProvider.allIdioms.length} idioms',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
      body: idiomProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppConstants.teal,
                strokeWidth: 2,
              ),
            )
          : idiomProvider.allIdioms.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No Idioms Found',
                  subtitle: 'No idioms match this filter.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: idiomProvider.allIdioms.length,
                  itemBuilder: (context, index) {
                    final idiom = idiomProvider.allIdioms[index];
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
                        final favProvider =
                            context.read<FavoritesProvider>();
                        final isFav =
                            await favProvider.toggleFavorite(idiom.id);
                        idiomProvider.updateIdiomFavoriteState(
                            idiom.id, isFav);
                      },
                    );
                  },
                ),
    );
  }
}
