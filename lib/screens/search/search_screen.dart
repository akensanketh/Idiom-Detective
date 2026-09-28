import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/idiom_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/idiom_card.dart';
import '../../widgets/search_field.dart';
import '../detail/idiom_detail_screen.dart';

/// Full search screen with debounced text search.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<IdiomProvider>().search(query);
    });
    setState(() {}); // Rebuild to update clear button visibility
  }

  void _clearSearch() {
    _controller.clear();
    context.read<IdiomProvider>().clearSearch();
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final idiomProvider = context.watch<IdiomProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Idioms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            idiomProvider.clearSearch();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Search field
          SearchField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            hintText: 'Type an idiom, meaning, or keyword...',
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _buildResults(context, idiomProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, IdiomProvider provider) {
    // Initial state
    if (provider.searchQuery.isEmpty) {
      return const EmptyState(
        icon: Icons.search_rounded,
        title: 'Search 1,000+ Idioms',
        subtitle: 'Type an idiom, its meaning, or any keyword to start searching.',
      );
    }

    // Loading
    if (provider.isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppConstants.teal,
          strokeWidth: 2,
        ),
      );
    }

    // No results
    if (provider.searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Clues Found',
        subtitle:
            'No idioms match "${provider.searchQuery}". Try a different keyword.',
      );
    }

    // Results list
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final idiom = provider.searchResults[index];
        return IdiomCard(
          idiom: idiom,
          onTap: () {
            provider.selectIdiom(idiom.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IdiomDetailScreen(idiomId: idiom.id),
              ),
            );
          },
          onFavorite: () async {
            final favProvider = context.read<FavoritesProvider>();
            final isFav = await favProvider.toggleFavorite(idiom.id);
            provider.updateIdiomFavoriteState(idiom.id, isFav);
          },
        );
      },
    );
  }
}
