import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cosmetic_shop/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  CartItem(this.product, this.quantity);
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final newList = List<CartItem>.from(state);
      newList[index] = CartItem(product, state[index].quantity + 1);
      state = newList;
    } else {
      state = [...state, CartItem(product, 1)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      final newList = List<CartItem>.from(state);
      newList[index] = CartItem(state[index].product, quantity);
      state = newList;
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalPrice {
    double total = 0;
    for (var item in state) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  int get itemCount {
    int count = 0;
    for (var item in state) {
      count += item.quantity;
    }
    return count;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  double total = 0;
  for (var item in cart) {
    total += item.product.price * item.quantity;
  }
  return total;
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  int count = 0;
  for (var item in cart) {
    count += item.quantity;
  }
  return count;
});