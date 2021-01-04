import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/services/http_requests.dart';

class ProductsProvider with ChangeNotifier {
  final tokenId;
  final userId;

  ProductsProvider(this.tokenId, {this.userId, this.productsList});

  List<ProductModel> productsList;

//*************************************************************************************************************\\
//*                                                                                                             *\\
//*                                            Calling Server                                                     *\\
//*                                                                                                                 *\\
//**********************************************************************************************************************/

  ///Add Products to server
  Future<RequestStatus> addProduct(ProductModel productModel) async {
    return await ApiManager.sendProduct(productModel,
            userId: userId, tokenId: tokenId)
        .then((response) {
      var statusCode = response.statusCode;
      if (statusCode == 200) {
        String id = json.decode(response.body)['name'];
        _addProductLocal(productModel, id);
        return Future<RequestStatus>.value(RequestStatus.success);
      }
      if (statusCode == 401) {
        return Future<RequestStatus>.value(RequestStatus.unauthorized);
      }

      return Future<RequestStatus>.value(RequestStatus.failed);
    }).catchError((error) {
      throw error;
    });
  }

  ///To fetch products from server
  ///Then add it to provider list
  Future<RequestStatus> get fetchProductsFromServer async {
    return await ApiManager.fetchProducts(tokenId: tokenId, userId: userId)
        .then((response) {
      final int statusCode = response.statusCode;
      switch (statusCode) {
        case 200:
          //print('ProductsProvider ==> fetchProductsFromServer: Status 200');
          ApiManager.fetchFavoritesProductsByUser(
                  tokenId: tokenId, userId: userId)
              .then((favoriteResponse) {
            final favoriteData = json.decode(favoriteResponse.body);
            if (!isDisposed) {
              productsList.clear();
              productsList
                  .addAll(ProductModel.fromJson(response.body, favoriteData));
              notifyListeners();
            }
          });
          return Future.value(RequestStatus.success);
        case 401:
          return Future.value(RequestStatus.unauthorized);
        default:
          return Future.value(RequestStatus.failed);
      }
    });
  }

  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  ///To toggle favorite
  Future<RequestStatus> toggleFavorite(
      {String userId, ProductModel product, bool isFavorite}) async {
    return await ApiManager.toggleFavorite(
            userId: userId,
            tokenId: tokenId,
            product: product,
            isFavorite: isFavorite)
        .then((response) {
      final int statusCode = response.statusCode;
      switch (statusCode) {
        case 200:
          notifyListeners();
          return Future<RequestStatus>.value(RequestStatus.success);
        case 401:
          return Future<RequestStatus>.value(RequestStatus.unauthorized);
        default:
          return Future<RequestStatus>.value(RequestStatus.failed);
      }
    });
  }

  ///To toggle favorite
  Future<RequestStatus> toggleAddToCart(
      ProductModel product, bool isAddedToCart) async {
    return await ApiManager.toggleAddToCart(tokenId, product, isAddedToCart)
        .then((response) {
      final int statusCode = response.statusCode;
      switch (statusCode) {
        case 200:
          notifyListeners();
          return Future<RequestStatus>.value(RequestStatus.success);
        case 401:
          return Future<RequestStatus>.value(RequestStatus.unauthorized);
        default:
          return Future<RequestStatus>.value(RequestStatus.failed);
      }
    });
  }

  ///To update product
  Future<RequestStatus> updateProduct(ProductModel productModel) async {
    return await ApiManager.editProduct(productModel, tokenId).then((response) {
      final int statusCode = response.statusCode;
      switch (statusCode) {
        case 200:
          notifyListeners();
          return Future<RequestStatus>.value(RequestStatus.success);
        case 401:
          return Future<RequestStatus>.value(RequestStatus.unauthorized);

        default:
          return Future<RequestStatus>.value(RequestStatus.failed);
      }
    });
  }

  ///To delete product
  Future<RequestStatus> deleteProduct(String productId) async {
    final productIndex =
        productsList.indexWhere((element) => element.id == productId);
    var product = productsList[productIndex];
    productsList.removeAt(productIndex);
    RequestStatus status =
        await ApiManager.deleteProduct(productId, tokenId).then((response) {
      final int statusCode = response.statusCode;
      switch (statusCode) {
        case 200:
          product = null;
          return Future<RequestStatus>.value(RequestStatus.success);
        case 401:
          productsList.insert(productIndex, product);
          // notifyListeners();

          return Future<RequestStatus>.value(RequestStatus.unauthorized);
        default:
          productsList.insert(productIndex, product);
          // notifyListeners();
          return Future<RequestStatus>.value(RequestStatus.failed);
      }
    });
    notifyListeners();

    return status;
  }

//*************************************************************************************************************\\
//*                                                                                                             *\\
//*                                            Filter Products                                                    *\\
//*                                                                                                                 *\\
//**********************************************************************************************************************/

  ///To return only FavoriteProducts
  List<ProductModel> get favoriteProducts {
    return productsList.where((product) => product.isFavorite).toList();
  }

//*************************************************************************************************************\\
//*                                                                                                             *\\
//*                                            Handle List local                                                  *\\
//*                                                                                                                 *\\
//**********************************************************************************************************************/

  ///Local
  void _addProductLocal(ProductModel productModel, String id) {
    productModel = ProductModel(
      id: id,
      title: productModel.title,
      description: productModel.description,
      price: productModel.price,
      imageUrl: productModel.imageUrl,
      isAddedToCart: productModel.isAddedToCart,
      isFavorite: productModel.isFavorite,
    );
    productsList.add(productModel);
    print('Product id = ${productModel.id}');
    notifyListeners();
  }

  ProductModel productById(String productId) {
    return productsList.firstWhere((product) => product.id == productId);
  }

  void removeCartFromAll() {
    productsList.forEach((product) {
      product.isAddedToCart = false;
    });
    notifyListeners();
  }

  void removeSingleItemFromCart(String id) {
    ProductModel productModel =
        productsList.firstWhere((product) => product.id == id);
    productModel.isAddedToCart = false;
    notifyListeners();
  }

  void removeProduct(String id) {
    productsList.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
