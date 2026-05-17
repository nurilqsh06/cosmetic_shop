import 'package:cosmetic_shop/screens/cart_screen.dart';
import 'package:cosmetic_shop/screens/checkout_screen.dart';
import 'package:cosmetic_shop/screens/favorites_screen.dart';
import 'package:cosmetic_shop/screens/home_screen.dart';
import 'package:cosmetic_shop/screens/order_history_screen.dart';
import 'package:cosmetic_shop/screens/product_detail_screen.dart';
import 'package:cosmetic_shop/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: 'productDetail',
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        name: 'cart',
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        name: 'favorites',
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        name: 'checkout',
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        name: 'orders',
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
    ],
  );
}