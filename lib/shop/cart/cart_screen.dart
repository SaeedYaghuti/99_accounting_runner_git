import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/shared/show_error_dialog.dart';
import '../order/order_provider.dart';
import '../order/order_screen.dart';

import 'cart_item.dart';
import 'cart_provider.dart';
import './cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final cartItems = cartProvider.items.values.toList();

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Cart'),
        ),
        body: Column(
          children: [
            _buildSummeryCard(context, theme, cartProvider, cartItems),
            SizedBox(height: 10),
            _buildCartItems(
              cartProvider,
              cartItems,
            ),
          ],
        ));
  }

  Widget _buildSummeryCard(
    BuildContext context,
    ThemeData theme,
    CartProvider cartProvider,
    List<CartItem> cartItems,
  ) {
    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Total:', style: TextStyle(fontSize: 20)),
            Spacer(),
            _buildAmountChip(context, cartProvider, theme),
            // _buildOrderNowButton(context, theme, cartProvider, cartItems),
            OrderNowButton(cartItems: cartItems),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountChip(
    BuildContext context,
    CartProvider cartProvider,
    ThemeData theme,
  ) {
    return Chip(
      backgroundColor: theme.primaryColor,
      label: Text(
        '\$${cartProvider.totalAmount}',
        style: TextStyle(
          color: theme.primaryTextTheme.title?.color ?? Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrderNowButton(
    BuildContext context,
    ThemeData theme,
    CartProvider cartProvider,
    List<CartItem> cartItems,
  ) {
    return FlatButton(
      child: Text('ORDER NOW'),
      textColor: theme.primaryColor,
      onPressed: cartItems.length <= 0
          ? null
          : () {
              // listen: false => important ; we would have error
              Provider.of<OrderProvider>(context, listen: false).addOrder(
                cartItems,
                cartProvider.totalAmount,
              );
              cartProvider.clearCart();
            },
    );
  }

  Widget _buildCartItems(
    CartProvider cartProvider,
    List<CartItem> cartItems,
  ) {
    return Expanded(
      child: ListView.builder(
        itemCount: cartProvider.itemCount,
        itemBuilder: (buildCtx, index) => CartItemWidget(
          id: cartItems[index].id,
          title: cartItems[index].title,
          price: cartItems[index].price,
          quantity: cartItems[index].quantity,
          imageUrl: cartItems[index].imageUrl,
        ),
      ),
    );
  }
}

class OrderNowButton extends StatefulWidget {
  final List<CartItem> cartItems;

  const OrderNowButton({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  _OrderNowButtonState createState() => _OrderNowButtonState();
}

class _OrderNowButtonState extends State<OrderNowButton> {
  var _isLoading = false;

  void _loadingStart() {
    setState(() {
      _isLoading = true;
    });
  }

  void _loadingEnd() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: true);

    return FlatButton(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Text('ORDER NOW'),
      textColor: Theme.of(context).primaryColor,
      onPressed: (widget.cartItems.length <= 0 || _isLoading)
          ? null
          : () {
              _loadingStart();
              Provider.of<OrderProvider>(context, listen: false)
                  .addOrder(widget.cartItems, cartProvider.totalAmount)
                  .then(
                (value) {
                  cartProvider.clearCart();
                  _loadingEnd();
                },
              ).catchError(
                (e) {
                  _loadingEnd();
                  showErrorDialog(
                    context,
                    'addOrder',
                    'OrderNowButton',
                    e,
                  );
                },
              );
            },
    );
  }
}
