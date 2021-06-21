import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../common/app_drawer.dart';
import '../../shared/show_dialog.dart';
import '../product/product_provider.dart';

import '../products_overview_screen/products_grid.dart';
import '../../shared/badge.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavoriteProducts = false;
  var _isFresh = true;
  var _isLoading = false;

  void loadingStart() {
    setState(() {
      _isLoading = true;
    });
  }

  void loadingEnd() {
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildPopupMenuButton() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          child: Text('show favorites products'),
          value: FilterOptions.Favorites,
        ),
        PopupMenuItem(
          child: Text('show all products'),
          value: FilterOptions.all,
        ),
      ],
      onSelected: (FilterOptions selectedValue) {
        if (selectedValue == FilterOptions.Favorites) {
          setState(() {
            _showFavoriteProducts = true;
          });
        } else {
          setState(() {
            _showFavoriteProducts = false;
          });
        }
      },
    );
  }

  Widget buildBadgeAndCart(BuildContext context) {
    return Consumer<CartProvider>(
      child: IconButton(
        icon: Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.of(context).pushNamed(CartScreen.routeName);
        },
      ),
      builder: (ctx, cart, iconButton) => Badge(
        child: iconButton ?? Container(),
        value: cart.itemCount.toString(),
      ),
    );
  }

  @override
  void initState() {
    // 1) first solution to use context in initState: => listen: false
    // try {
    //   Provider.of<ProductProvider>(context, listen: false)
    //       .fetchAndSetProducts();
    // } catch (e) {
    //   print(e.toString());
    // }

    // 2) second solution: use future.delayed => didn't work
    // Future.delayed(Duration.zero).then(
    //   (_) {
    //     Provider.of<ProductProvider>(context).fetchAndSetProducts();
    //   },
    // );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // it is not working to use async => use then()
    if (_isFresh) {
      loadingStart();
      Provider.of<ProductProvider>(context).fetchAndSetProducts().then((_) {
        loadingEnd();
        _isFresh = false;
      }).catchError((e) {
        showErrorDialog(
          context,
          'didChangeDependencies',
          'at Products Overview Screen',
          e,
        );
        print(e.toString());
        loadingEnd();
      });
    }
    super.didChangeDependencies();
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          buildBadgeAndCart(context),
          buildPopupMenuButton(),
        ],
      ),
      drawer: AppDrwer(),
      body: _isLoading
          ? _buildLoadingIndicator()
          : ProductsGrid(_showFavoriteProducts),
    );
  }
}

enum FilterOptions {
  Favorites,
  all,
}
