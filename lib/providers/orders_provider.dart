import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/services/http_requests.dart';

class OrderModel {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderModel({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });

  static String toJson({double amount, List<CartItem> cartItems}) {
    final timeStamp = DateTime.now();

    return json.encode({
      'id:': '${timeStamp.toIso8601String().toString()}',
      'amount': amount,
      'dateTime': '${timeStamp.toIso8601String.toString()}',
      'products': cartItems
          .map((cartItem) => {
                "id": cartItem.id,
                'title': cartItem.title,
                'quantity': cartItem.quantity,
                'price': cartItem.price
              })
          .toList(),
    });
  }

  static List<OrderModel> fromJson(String body) {
    //orderId & orderData
    var extractedData = json.decode(body) as Map<String, dynamic>;

    List<OrderModel> loadedOrders = [];
    if (extractedData == null) return null;
    extractedData.forEach((orderId, orderData) {
      var products = (orderData['products'] as List<dynamic>)
          .map((product) => CartItem(
              id: product['id'],
              title: product['title'],
              quantity: product['quantity'],
              price: product['price'],
              image: product['image'],
              description: product['description']))
          .toList();

      print('dateTime: ${orderData['dateTime']}');
      loadedOrders.add(
        OrderModel(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: products,
        ),
      );
    });
    return loadedOrders;
  }
}

class OrdersProvider with ChangeNotifier {
  List<OrderModel> orders = [];
  final authToken;
  final userId;

  List<OrderModel> get allOrders {
    return [...orders];
  }

  OrdersProvider(this.authToken, {this.userId, this.orders});

  //To fetch products from server
  ///Then add it to provider list
  Future<RequestStatus> get fetchOrdersFromServer async {
    return await ApiManager.fetchOrders(userId: userId,tokenId: authToken).then((response) {
      final int statusCode = response.statusCode;
      switch (statusCode) {
        case 200:
          var receivedList = OrderModel.fromJson(response.body);
          if (receivedList != null) {
            orders.clear();
            orders.addAll(OrderModel.fromJson(response.body));
            orders = orders.reversed.toList();
            return Future<RequestStatus>.value(RequestStatus.success);
          }
          notifyListeners();
          return Future<RequestStatus>.value(RequestStatus.successButEmpty);
        case 401:
          return Future<RequestStatus>.value(RequestStatus.unauthorized);

        default:
          return Future<RequestStatus>.value(RequestStatus.failed);
      }
    });
  }

  void addOrder({List<CartItem> products, double total}) {
    OrderModel orderModel = OrderModel(
      id: DateTime.now().toString(),
      amount: total,
      products: products,
      dateTime: DateTime.now(),
    );
    orders.insert(0, orderModel);
    ApiManager.addOrder(
      userId: userId,
      tokenId: authToken,
      cartItems: products,
      amount: total,
    );
    notifyListeners();
  }
}
