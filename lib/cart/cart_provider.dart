import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += (cartItem.price * cartItem.quantity);
    });
    return total;
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity >= 2) {
      _items.update(
          productId,
          (old) => CartItem(
                id: productId,
                title: old.title,
                quantity: old.quantity - 1,
                price: old.price,
                imageUrl: old.imageUrl,
              ));
    } else {
      // quantity = 1
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void addItem({
    required String id,
    required String title,
    required double price,
    required String imageUrl,
  }) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (oldCartItem) => CartItem(
          id: id,
          title: title,
          price: price,
          quantity: oldCartItem.quantity + 1,
          imageUrl: imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        id,
        () => CartItem(
          id: id,
          title: title,
          price: price,
          quantity: 1,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }
}
