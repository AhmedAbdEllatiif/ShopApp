import 'dart:convert';

import 'package:flutter/material.dart';

class ProductModel with ChangeNotifier {
 final  String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  bool isAddedToCart;

  ProductModel(
      {
      @required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false,
      this.isAddedToCart = false,
      });



  void toggleFavorite(){
    isFavorite = !isFavorite;
    notifyListeners();
  }

 void toggleIsAddedToCart(){
   isAddedToCart = !isAddedToCart;
   notifyListeners();
 }


 static List<ProductModel> fromJson(String body,favoriteData){
    var extractedData = json.decode(body) as Map<String,dynamic>;
    //Key ==> ProductId
    //Value ==> ProductData as Map
    List<ProductModel> loadedProducts = [];
    extractedData.forEach((productId, productData) {
      loadedProducts.add(ProductModel(
        id: productId,
        title: productData['title'],
        description: productData['description'],
        price: productData['price'],
        imageUrl: productData['imageUrl'],
        isAddedToCart: productData['isAddToCart'] == 'true' ? true : false,
        isFavorite: favoriteData == null? false:
        favoriteData[productId] ?? false,
      ),
      );
    });
//String a = b ?? 'hello';
// This means a equals b, but if b is null then a equals 'hello'.
//
// Another related operator is ??=. For example:
//
// b ??= 'hello';
// This means if b is null then set it equal to hello. Otherwise, don't change it.
    return loadedProducts;

 }

}
