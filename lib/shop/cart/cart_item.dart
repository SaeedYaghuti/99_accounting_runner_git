import 'dart:convert';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  String encodeToJson() {
    return json.encode({
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  static String encodeListToJson(List<CartItem> cartItems) {
    return json.encode(
      cartItems
          .map(
            (c) => c.encodeToJson(),
          )
          .toList(),
    );
  }

  static CartItem convertToCartItemClass(String mapCartItem) {
    var cartData = json.decode(mapCartItem) as Map<String, dynamic>;

    return CartItem(
      id: cartData['id'],
      title: cartData['title'],
      quantity: cartData['quantity'],
      price: cartData['price'],
      imageUrl: cartData['imageUrl'],
    );
  }

  static List<CartItem> convertToListOfCartItems(String mapCartItems) {
    var decoded = json.decode(mapCartItems) as List<dynamic>;
    List<CartItem> convertedCartItems = [];
    decoded.forEach(
      (cartItem) {
        var decoded = json.decode(cartItem) as Map<String, dynamic>;
        convertedCartItems.add(
          CartItem(
            id: decoded['id'],
            title: decoded['title'],
            quantity: decoded['quantity'],
            price: decoded['price'],
            imageUrl: decoded['imageUrl'],
          ),
        );
      },
    );
    return convertedCartItems;
  }
}
