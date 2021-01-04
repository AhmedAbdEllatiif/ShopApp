import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/widgets/cart_item.dart';
import 'package:shop_app/widgets/main_app_drawer.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = "/CartScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cart"),
        ),

        ///Body
        body: Consumer<CartProvider>(
          builder: (_, cartProvider, builderChild) {
            return Column(
              children: [
                Card(
                  margin: EdgeInsets.all(15.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ///Total
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),

                        ///SizedBox
                        SizedBox(width: 10),
                        Spacer(), //Spacer==> to take all available space

                        ///Chip (Price)
                        Chip(
                          label: Text(
                            '\$ ${cartProvider.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .headline6
                                  .color,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),

                        ///Button OrderNow
                        Container(
                          margin: EdgeInsets.only(left: 5.0),
                          child: FlatButton(
                            child: Text(
                              'Order Now',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Provider.of<ProductsProvider>(context,listen: false).removeCartFromAll();
                              Provider.of<OrdersProvider>(context,listen: false).addOrder(
                                products: cartProvider.getItems.values.toList(),
                                total: cartProvider.totalAmount,
                              );
                              cartProvider.deleteAllProducts();
                              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                ///rest of column children
                SizedBox(height: 10),

                ///ListView with cart items
                Expanded(
                    child: ListView.builder(
                  itemCount: cartProvider.getItems.length,
                  itemBuilder: (context, index) {
                    CartItem cartItem =
                        cartProvider.getItems.values.toList()[index];
                    return CartItemWidget(
                      cartItem: cartItem,
                    );
                  },
                ))
              ],
            );
          },
        ),

      drawer: MainAppDrawer(),
    );
  }
}
