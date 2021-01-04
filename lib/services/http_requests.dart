import 'package:http/http.dart' as http;
import 'package:shop_app/helpers/HttpException.dart';
import 'package:shop_app/model/auth_data.dart';
import 'dart:convert';

import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/providers/cart_provider.dart';

enum RequestStatus {
  success,
  failed,
  unauthorized,
  successButEmpty,
}

class ApiManager {
  static const _apiKey = 'AIzaSyCxOzbxKYzaXz8fqRugHCdo8GntbdBEAMU';
  static const _baseUrl = 'https://shopapp-7d89a-default-rtdb.firebaseio.com/';
  static const _signUp =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=';
  static const _signIn =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=';
  static const _products = 'products/';
  static const _userFavorites = 'userFavorites/';
  static const _orders = 'orders/';
  static const _jsonFormat = '.json';

  static Future<http.Response> sendProduct(ProductModel productModel,
      {userId, tokenId}) async {
    return await http
        .post(
      '$_baseUrl$_products$_jsonFormat?auth=$tokenId',
      body: _getConvertedProduct(productModel, userId),
    )
        .then((http.Response response) {
      return response;
    }).catchError((error) {
      print("Error: $error");
      throw error;
    });
  }

  static Future<http.Response> fetchProducts(
      {String tokenId, String userId}) async {
    return await http
        .get(
      '$_baseUrl$_products$_jsonFormat?auth=$tokenId&orderBy="creatorId"&equalTo="$userId"',
    )
        .then((http.Response response) {
      return response;
    });
  }

  static Future<http.Response> fetchFavoritesProductsByUser(
      {String tokenId, String userId}) async {
    return await http
        .get(
      '$_baseUrl$_userFavorites$userId$_jsonFormat?auth=$tokenId',
    )
        .then((http.Response response) {
      return response;
    });
  }

  static Future<http.Response> editProduct(
      ProductModel product, String tokenId) async {
    return await http
        .patch('$_baseUrl$_products${product.id}$_jsonFormat?auth=$tokenId',
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
            }))
        .then((http.Response response) {
      return response;
    }).catchError((error) {
      print("Error: $error");
      throw error;
    });
  }

  static Future<http.Response> deleteProduct(
      String productId, String tokenId) async {
    return await http
        .delete(
      '$_baseUrl$_products$productId$_jsonFormat?auth=$tokenId',
    )
        .then((http.Response response) {
      return response;
    }).catchError((error) {
      print("Error: $error");
      throw error;
    });
  }

  static String _getConvertedProduct(ProductModel productModel, userId) {
    return json.encode({
      'title': productModel.title,
      'description': productModel.description,
      'price': productModel.price,
      'imageUrl': productModel.imageUrl,
      'isAddToCart': productModel.isAddedToCart,
      'creatorId': userId.toString(),
    });
  }

  static Future<http.Response> toggleFavorite(
      {String userId, String tokenId, ProductModel product, isFavorite}) async {
    // isFavorite = !isFavorite;
    print('HttpRequest ==>toggleFavorite: $isFavorite ');
    return await http
        .put(
            '$_baseUrl$_userFavorites$userId/${product.id}$_jsonFormat?auth=$tokenId',
            body: json.encode(isFavorite))
        .then((http.Response response) {
      return response;
    }).catchError((error) {
      print("Error: $error");
      throw error;
    });
  }

  static Future<http.Response> toggleAddToCart(
      String tokenId, ProductModel product, bool isAddedToCart) async {
    return await http
        .patch('$_baseUrl$_products${product.id}$_jsonFormat?auth=$tokenId',
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'isAddToCart': isAddedToCart.toString(),
              'isFavorite': product.isFavorite.toString(),
            }))
        .then((http.Response response) {
      return response;
    }).catchError((error) {
      print("Error: $error");
      throw error;
    });
  }

  static Future<http.Response> fetchOrders({userId, tokenId}) async {
    return await http
        .get(
      '$_baseUrl$_orders$userId$_jsonFormat?auth=$tokenId',
    )
        .then((http.Response response) {
      return response;
    }).catchError((error) {
      print("Error: $error");
      throw error;
    });
  }

  static Future<http.Response> addOrder(
      {userId, tokenId, double amount, List<CartItem> cartItems}) async {
    //ToDo clear the cart after adding order

    return await http
        .post(
      '$_baseUrl$_orders$userId$_jsonFormat?auth=$tokenId',
      body: _getConvertedOrder(amount: amount, cartItems: cartItems),
    )
        .then((http.Response response) {
      return response;
    }).catchError((error) {
      print("Error: $error");
      throw error;
    });
  }

  static String _getConvertedOrder({double amount, List<CartItem> cartItems}) {
    final timeStamp = DateTime.now();

    return json.encode({
      'id': timeStamp.toIso8601String().toString(),
      'amount': amount,
      'dateTime': timeStamp.toIso8601String().toString(),
      'products': cartItems
          .map((cartItem) => {
                "id": cartItem.id,
                'title': cartItem.title,
                'quantity': cartItem.quantity,
                'price': cartItem.price,
                'image': cartItem.image,
                'description': cartItem.description,
              })
          .toList(),
    });
  }

  static Future<AuthData> signUp(AuthData data) async {
    try {
      final response = await http.post(
        '$_signUp$_apiKey',
        body: data.toJson,
        headers: {"Content-Type": "application/json"},
      );
      print('Response:\n ${json.decode(response.body)}');
      final responseData = json.decode(response.body);
      data = AuthData.fromJson(responseData);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      return data;
    } catch (error) {
      print('HttpRequest signUp ==>  catch error ==> ${error.toString()}');
      throw (error);
    }
  }

  static Future<AuthData> logIn(AuthData data) async {
    try {
      final response = await http.post(
        '$_signIn$_apiKey',
        body: data.toJson,
        headers: {"Content-Type": "application/json"},
      );
      print('Response:\n ${json.decode(response.body)}');
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      data = AuthData.fromJson(responseData);
      return data;
    } catch (error) {
      print('HttpRequest logIn ==> catch error ==> ${error.toString()}');
      throw (error);
    }
  }
}
