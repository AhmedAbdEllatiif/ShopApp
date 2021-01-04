import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/widgets/stepper_widget.dart';

class InnerCartItem extends StatelessWidget {
  final CartItem cartItem;

  InnerCartItem({this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ///Image & Price per unit
            Column(
              children: [
                SizedBox(
                  width: 100,
                    height: 100,
                    child: Image.network(cartItem.image)),
                Text(
                  '\$${cartItem.price}',
                  style: TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),

            ///Item details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Title
                Center(
                  child: FittedBox(
                    child: Text(
                      '${cartItem.title}',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),

                    ),
                  ),
                ),

                ///Description
                Container(
                  width: MediaQuery.of(context).size.width - 200,
                  child: Text(
                    "${cartItem.description}",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),



                ///Quantity
                Row(
                  children: [
                    Text('Qty:'),
                    CustomStepper(
                      iconSize: 20,
                      lowerLimit: 0,
                      stepValue: 1,
                      cartItem: cartItem,
                    ),
                  ],
                ),

                ///Total
                Text(
                  "Total: ${(cartItem.price * cartItem.quantity)}",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
