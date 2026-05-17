import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:cosmetic_shop/models/product.dart';
import 'package:cosmetic_shop/providers/cart_provider.dart';
import 'package:cosmetic_shop/providers/theme_provider.dart';
import 'package:cosmetic_shop/providers/auth_provider.dart';
import 'package:cosmetic_shop/widgets/product_card.dart';
import 'package:cosmetic_shop/data/products_data.dart';

final productListProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier() : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();

    try {
      print('[HTTP REQUEST] Loading products from API...');
      print('URL: https://dummyjson.com/products/category/beauty');

      final response = await http.get(
        Uri.parse('https://dummyjson.com/products/category/beauty'),
      );

      print('HTTP Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsJson = data['products'];

        print('Received ${productsJson.length} products from API (beauty category only)');
        print('API limit: only 6 beauty products available');
        print('Loading ${ProductsData.products.length} products from local data instead');

        await Future.delayed(const Duration(milliseconds: 500));

        state = AsyncValue.data(ProductsData.products);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e, stack) {
      print('HTTP request error: $e, using local data');
      state = AsyncValue.data(ProductsData.products);
    }
  }

  Future<void> refreshProducts() async {
    print('[MANUAL REFRESH] User requested update...');
    await loadProducts();
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productListProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);
    final currentUser = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmetic Shop'),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  'Hello, ${currentUser.name.split(' ')[0]}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              print('[USER ACTION] Search button clicked');
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(ref),
              );
            },
            tooltip: 'Search products',
          ),

          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  print('[USER ACTION] Cart button clicked');
                  context.go('/cart');
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              print('[USER ACTION] Favorites button clicked');
              context.go('/favorites');
            },
          ),

          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              print('[USER ACTION] Order history button clicked');
              context.go('/orders');
            },
          ),

          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              print('[USER ACTION] Theme toggle button clicked');
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              print('[USER ACTION] Sign out button clicked');
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: productsState.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(productListProvider.notifier).refreshProducts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  ProductSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return productsAsync.when(
      data: (allProducts) {
        final filteredProducts = allProducts
            .where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: filteredProducts[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return productsAsync.when(
      data: (allProducts) {
        final suggestions = query.isEmpty
            ? allProducts
            : allProducts
            .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
            .toList()
            .take(5)
            .toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final product = suggestions[index];
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              onTap: () {
                query = product.name;
                showResults(context);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}