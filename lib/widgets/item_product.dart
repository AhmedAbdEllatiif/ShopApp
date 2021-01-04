import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/product_details.dart';
import 'package:shop_app/services/http_requests.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductModel loadedProduct =
        Provider.of<ProductModel>(context, listen: false);
    final CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GridTile(
        ///ProductImage ==> Direct Child of GridTile
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: loadedProduct.id,
            );
          },
          child: Hero(//For Animation transition
            tag: loadedProduct.id, //any unique tag
            child: FadeInImage(
              image: NetworkImage(loadedProduct.imageUrl),
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        ///Footer
        footer: GridTileBar(
          backgroundColor: Colors.black87,

          ///FavoriteIcon
          //Used if i want to listen with provider because
          // listen with provider rebuild the whole widget,
          // so we used consumer above the widget we want to rebuild
          leading: Consumer<ProductModel>(
            builder: (context, product, child) {
              return LikeButton(
                onTap: (isLiked) {
                  print('LikeButton isLiked: $isLiked');
                  return onFavoriteButtonTapped(
                      authProvider.userId, isLiked, product, context);
                },
                size: 30.0,
                isLiked: product.isFavorite,
                circleColor: CircleColor(
                    start: Theme.of(context).primaryColor,
                    end: Theme.of(context).primaryColor),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: Theme.of(context).primaryColor,
                  dotSecondaryColor: Theme.of(context).accentColor,
                ),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.favorite,
                    color:
                        isLiked ? Theme.of(context).accentColor : Colors.grey,
                    size: 30.0,
                  );
                },
              );
            },
          ),

          ///Footer title
          title: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: Text(
                    "${loadedProduct.title}",
                    textAlign: TextAlign.center,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.cover,
                  child: Text(
                    "\$${loadedProduct.price}",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          ///CartIcon
          trailing: Consumer<ProductModel>(
            builder: (_, product, child) {
              return LikeButton(
                onTap: (isLiked) {
                  return onAddToCartButtonTapped(
                      context, isLiked, product, cartProvider);
                },
                size: 30.0,
                isLiked: product.isAddedToCart,
                circleColor: CircleColor(
                    start: Theme.of(context).primaryColor,
                    end: Theme.of(context).primaryColor),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: Theme.of(context).primaryColor,
                  dotSecondaryColor: Theme.of(context).accentColor,
                ),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.shopping_cart,
                    color:
                        isLiked ? Theme.of(context).accentColor : Colors.grey,
                    size: 30.0,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> onFavoriteButtonTapped(userId, bool isLiked,
      ProductModel productModel, BuildContext context) async {
    /// send your request here
    // final bool success= await sendRequest();
    productModel.toggleFavorite();
    print(
        'onFavoriteButtonTapped ==> productModel.isFavorite: ${productModel.isFavorite}');
    Provider.of<ProductsProvider>(context, listen: false).toggleFavorite(
        userId: userId,
        product: productModel,
        isFavorite: productModel.isFavorite);

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;

    return !isLiked;
  }

  Future<bool> onAddToCartButtonTapped(context, bool isAddedToCart,
      ProductModel loadedProduct, CartProvider cartProvider) async {
    //delete product if if already added to cart
    if (loadedProduct.isAddedToCart) {
      cartProvider.deleteItem(loadedProduct.id);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Item Removed from Cart"),
          duration: Duration(milliseconds: 500),
        ),
      );
    } else {
      //Add product to cart
      cartProvider.addItem(
        productId: loadedProduct.id,
        price: loadedProduct.price,
        title: loadedProduct.title,
        image: loadedProduct.imageUrl,
        description: loadedProduct.description,
      );
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Item Added to Cart"),
          backgroundColor: Theme.of(context).accentColor,
          duration: Duration(milliseconds: 800),
        ),
      );
    }
    loadedProduct.toggleIsAddedToCart();
    RequestStatus status =
        await Provider.of<ProductsProvider>(context, listen: false)
            .toggleAddToCart(loadedProduct, loadedProduct.isAddedToCart);

    switch (status) {
      case RequestStatus.success:
        return !isAddedToCart;
        break;
      case RequestStatus.failed:
        return false;
        break;
      case RequestStatus.unauthorized:
        return false;
        break;
      default:
        return false;
    }
  }
}
