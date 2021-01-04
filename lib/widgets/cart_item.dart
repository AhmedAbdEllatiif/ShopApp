import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/inner_cart_item.dart';

class CartItemWidget extends StatelessWidget {

  final CartItem cartItem;

  CartItemWidget({this.cartItem});


  @override
  Widget build(BuildContext context) {
    String id = cartItem.id;


    return Dismissible(

      direction: DismissDirection.endToStart ,

      ///Requires a unique key
      key: ValueKey(id),

      ///Confirm Dismiss
      confirmDismiss: (_){
      return  showDialog(
            context: context,
          builder: (context) {
              return AlertDialog(
                title: Text('Are you sure?'),
                content: Text('Do you want to remove this item from cart?'),
                actions: [
                  FlatButton(onPressed: (){
                    //Return false with pop
                   Navigator.of(context).pop(false);
                  }, child: Text('No')),
                  FlatButton(onPressed: (){
                    Navigator.of(context).pop(true);
                  }, child: Text('Yes')),
                ],
              );
          },
        );
      },

      ///OnDismissed
      onDismissed: (direction){
        if (direction == DismissDirection.endToStart ){
          Provider.of<CartProvider>(context,listen: false).deleteItem(id);
          Provider.of<ProductsProvider>(context,listen: false).removeSingleItemFromCart(id);
        }
      },

      ///secondaryBackground
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 4.0,
        ),
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.white),
              Text('Delete Item', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),

      ///background if slide from the other side From(startToEnd)
      background: Container(color: Colors.blue,),


      ///Child of Dismissible
      child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 4.0,
          ),
          child: InnerCartItem(cartItem: cartItem,)),
    );
  }
}
