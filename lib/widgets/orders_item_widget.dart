import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders_provider.dart';

class OrdersItem extends StatefulWidget {
  final OrderModel orderModel;

  OrdersItem({this.orderModel});

  @override
  _OrdersItemState createState() => _OrdersItemState();
}

class _OrdersItemState extends State<OrdersItem> with SingleTickerProviderStateMixin {
  bool _expanded = false;


  AnimationController _animationController;
  Animation<Size> _heightAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 600),
    );

    _heightAnimation = Tween<Size>(
      begin: Size(double.infinity,0.0),
      end:  Size(double.infinity,min(widget.orderModel.products.length * 20.0 + 80.0, 180)),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: (){
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Column(
          children: [
            ListTile(
              title: Text("\$${widget.orderModel.amount}",style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),),
              subtitle: Text(
                "${DateFormat('dd - MM - yyyy   hh:mm a').format(widget.orderModel.dateTime)}",
              ),
              trailing: IconButton(
                icon:
                    _expanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
                onPressed: () {
                  setState(() {
                    if(!_expanded){
                      _animationController.forward();
                    }else{
                      _animationController.reverse();
                    }
                    _expanded = !_expanded;
                  });
                },
              ),
            ),

            ///Expanded Items
             AnimatedBuilder(
                 builder: (context, builderChild) => Container(
                   height: _heightAnimation.value.height,
                   child: builderChild,
                 ),
                 animation: _heightAnimation,
                   child: Scrollbar(
                     child: ListView.builder(
                       itemBuilder: (context, index) {
                         CartItem item = widget.orderModel.products[index];
                         return ListTile(

                           ///Leading (ItemImage)
                           leading: SizedBox(
                             width: 50.0,
                             height: 50.0,
                             child: Image.network(item.image),
                           ),

                           ///Title (Column==> ItemTitle,ItemPrice)
                           title: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 "${item.title}",
                               ),
                               Text(
                                 "\$${item.price}",
                                 style: TextStyle(
                                   fontSize: 12.0,
                                   color: Colors.grey,
                                 ),
                               ),
                             ],
                           ),

                           ///Trailing (Quantity)
                           trailing: Text("Qty: ${item.quantity}x",style: TextStyle(
                             fontWeight: FontWeight.bold,
                           ),),
                         );
                       },
                       itemCount: widget.orderModel.products.length,
                     ),
                   ),

             ),

            // AnimatedContainer(
            //   duration: Duration(milliseconds: 300),
            //   width: double.infinity,
            //   height: _expanded? min(widget.orderModel.products.length * 20.0 + 80.0, 180): 0.0,
            //   curve: Curves.linear,
            //   // constraints: BoxConstraints(
            //   //   minHeight: _expanded? 0.0: 0.0,
            //   //   maxHeight:  min(widget.orderModel.products.length * 20.0 + 80.0, 180),
            //   // ),
            //   child:  Scrollbar(
            //     child: ListView.builder(
            //       itemBuilder: (context, index) {
            //         CartItem item = widget.orderModel.products[index];
            //         return ListTile(
            //
            //           ///Leading (ItemImage)
            //           leading: SizedBox(
            //             width: 50.0,
            //             height: 50.0,
            //             child: Image.network(item.image),
            //           ),
            //
            //           ///Title (Column==> ItemTitle,ItemPrice)
            //           title: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 "${item.title}",
            //               ),
            //               Text(
            //                 "\$${item.price}",
            //                 style: TextStyle(
            //                   fontSize: 12.0,
            //                   color: Colors.grey,
            //                 ),
            //               ),
            //             ],
            //           ),
            //
            //           ///Trailing (Quantity)
            //           trailing: Text("Qty: ${item.quantity}x",style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //           ),),
            //         );
            //       },
            //       itemCount: widget.orderModel.products.length,
            //     ),
            //   ),
            // )

          ],
        ),
      ),
    );
  }
}
// Container(
// height:
// min(widget.orderModel.products.length * 20.0 + 80.0, 180),
// )
// ,