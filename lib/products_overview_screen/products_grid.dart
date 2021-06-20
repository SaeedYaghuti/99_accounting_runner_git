import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../product/product.dart';
import '../product/product_provider.dart';
import '../product/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool _showFavoriteProducts;
  ProductsGrid(this._showFavoriteProducts);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final List<Product> products = _showFavoriteProducts
        ? productProvider.favoriteItems
        : productProvider.items;

    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
