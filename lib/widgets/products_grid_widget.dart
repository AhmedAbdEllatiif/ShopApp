import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/item_product.dart';

class ProductsGridWidget extends StatelessWidget {
  final bool isShowOnlyFavorites;

  ProductsGridWidget({this.isShowOnlyFavorites = false});

  @override
  Widget build(BuildContext context) {
    var productsData = Provider.of<ProductsProvider>(context);
    //productsData.fetchProductsFromServer(context);
    final List<ProductModel> productsList = isShowOnlyFavorites
        ? productsData.favoriteProducts
        : productsData.productsList;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: productsList.length,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        itemBuilder: (BuildContext context, int index) {
          return ChangeNotifierProvider.value(
            value: productsList[index],
            //Recommended to use is value with list item to avoid providers from use the same widget with different data
            child: ProductItem(),
          );
        },
        staggeredTileBuilder: (index) {
          return StaggeredTile.count(2, index.isEven ? 3 : 2);
        },
      ),
    );
  }
}
