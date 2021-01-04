import 'package:flutter/foundation.dart';
import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/providers/products_provider.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String image;
  final String description;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
    @required this.image,
    @required this.description,
  });
}

class CartProvider with ChangeNotifier {
  List<ProductModel> allProducts;

  void update(myProducts) {
    this.allProducts = myProducts;
    addItemsFromServer();
    //return this;
  }

  Map<String, CartItem> items = Map();

  Map<String, CartItem> get getItems {
    return {...items};
  }

  String get cartItemsCount {
    return items == null ? "" : items.length.toString();
  }

  double get totalAmount {
    var total = 0.0;
    items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void deleteItem(String id) {
    items.removeWhere((key, cartItem) => cartItem.id == id);
    notifyListeners();
  }

  bool decreaseItems(String id) {
    int updateQuantity;
    bool isItemFullyRemoved = false;
    if (items.containsKey(id)) {
      items.update(
        id,
        (existingCartItem) {
          updateQuantity = existingCartItem.quantity - 1;
          return CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              quantity: updateQuantity,
              price: existingCartItem.price,
              image: existingCartItem.image,
              description: existingCartItem.description);
        },
      );
    }
    if (updateQuantity <= 0) {
      items.removeWhere((key, cartItem) => cartItem.id == id);
      isItemFullyRemoved = true;
    }
    notifyListeners();
    return isItemFullyRemoved;
  }

  void addItemsFromServer() {
    allProducts.forEach((product) {
      if (product.isAddedToCart) {
        addItem(
            productId: product.id,
            title: product.title,
            description: product.description,
            price: product.price,
            image: product.imageUrl,
            isLoadingFromServer: true);
      }
    });
  }

  void addItem(
      {String productId,
      double price,
      String title,
      String image,
      String description,
      bool isLoadingFromServer = false}) {
    if (items.containsKey(productId)) {
      // Change quantity
      items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: isLoadingFromServer
                ? existingCartItem.quantity
                : existingCartItem.quantity + 1,
            price: existingCartItem.price,
            image: existingCartItem.image,
            description: existingCartItem.description),
      );
    } else {
      items.putIfAbsent(
          productId,
          () => CartItem(
              id: '$productId',
              title: title,
              quantity: 1,
              price: price,
              image: image,
              description: description));
    }
    notifyListeners();
  }

  void deleteAllProducts() {
    items.clear();
    notifyListeners();
  }
}
