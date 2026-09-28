import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/idiom_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/idiom_card.dart';
import '../detail/idiom_detail_screen.dart';

/// Screen showing all idioms in a specific category.
class CategoryIdiomsScreen extends StatefulWidget {
  final String category;

  const CategoryIdiomsScreen({super.key, required this.category});

  @override
  State<CategoryIdiomsScreen> createState() =>
      _CategoryIdiomsScreenState();
}

class _CategoryIdiomsScreenState extends State<CategoryIdiomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdiomProvider>().loadCategoryIdioms(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final idiomProvider = context.watch<IdiomProvider>();

    final categoryData = AppConstants.categories.firstWhere(
      (c) => c['name'] == widget.category,
      orElse: () => {
        'name': widget.category,
        'icon': Icons.label_rounded,
        'color': AppConstants.teal,
      },
    );
    final color = categoryData['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              categoryData['icon'] as IconData,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(widget.category),
          ],
        ),
        actions: [
          if (idiomProvider.categoryIdioms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    '${idiomProvider.categoryIdioms.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
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
          : idiomProvider.categoryIdioms.isEmpty
              ? EmptyState(
                  icon: Icons.category_rounded,
                  title: 'No Idioms Yet',
                  subtitle:
                      'No idioms found in the "${widget.category}" category.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: idiomProvider.categoryIdioms.length,
                  itemBuilder: (context, index) {
                    final idiom = idiomProvider.categoryIdioms[index];
                    return IdiomCard(
                      idiom: idiom,
                      showCategory: false,
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
