import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/roundend_button.dart';

class CustomStepper extends StatelessWidget {


  final int lowerLimit;
  final int stepValue;
  final double iconSize;
  final CartItem cartItem;


  CustomStepper({@required this.lowerLimit,
    @required this.stepValue,
    @required this.iconSize,
    @required this.cartItem
  });


  @override
  Widget build(BuildContext context) {

    var cartProvider = Provider.of<CartProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        ///Decrease button
        RoundedIconButton(
          icon: Icons.remove,
          iconSize: iconSize,
          onPress: () {
           bool isItemFullyRemoved = cartProvider.decreaseItems(cartItem.id);
           if(isItemFullyRemoved){
             Provider.of<ProductsProvider>(context,listen: false).removeSingleItemFromCart(cartItem.id);
           }
          },
        ),

        ///Text (count)
        Container(
          width: iconSize,
          child: Text(
            '${cartItem.quantity}',
            style: TextStyle(
              fontSize: iconSize * 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        ///increase button
        RoundedIconButton(
          icon: Icons.add,
          iconSize: iconSize,
          onPress: () {
            cartProvider.addItem(
                productId: cartItem.id,
                title: cartItem.title,
                price: cartItem.price,
                image: cartItem.image,
                description: cartItem.description
            );
          },
        ),


      ],
    );
  }

}

