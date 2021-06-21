import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../product/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-details-screen';
  const ProductDetailScreen();

  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context)!.settings.arguments as String;
    var productsProvider = Provider.of<ProductProvider>(context, listen: false);
    var product = productsProvider.getById(id);

    Widget buildProductImage() {
      return Container(
        width: double.infinity,
        height: 300,
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProductImage(),
            SizedBox(height: 10),
            Text(
              '\$${product.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text('${product.description}',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
