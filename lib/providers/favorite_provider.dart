import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cosmetic_shop/models/product.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    state = favoritesJson;
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', state);
  }

  void toggleFavorite(Product product) {
    if (state.contains(product.id)) {
      state = state.where((id) => id != product.id).toList();
    } else {
      state = [...state, product.id];
    }
    _saveFavorites();
  }

  bool isFavorite(String productId) {
    return state.contains(productId);
  }
}

final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(productId);
});