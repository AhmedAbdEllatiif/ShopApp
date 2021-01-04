import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:shop_app/services/http_requests.dart';
import 'package:shop_app/widgets/loading_view_with_text.dart';
import 'package:shop_app/widgets/main_app_drawer.dart';
import 'package:shop_app/widgets/orders_item_widget.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/OrdersScreen';

 /* @override
  void initState() {
    //This trick only if you don't set listen to ==> false
    //Future.delayed(Duration.zero).then((_) => fetchData());

   // _isLoading = true;
   // fetchData();
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),

      ///body
      body:FutureBuilder(
        future: (Provider.of<OrdersProvider>(context, listen: false)
            .fetchOrdersFromServer),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return LoadingViewWithText(loadingText: "Loading Orders ....",);
          }else{
            if(snapshot.error != null){
              ///...
              ///Show the error message
              return Center(
                child: Text('There\'s an error'),
              );
            }
            if(snapshot.data != null){
              return mainWidget;
            }
            return emptyListWidget(context);
          }

        },
      ) ,
        // _isLoading
        //   ? LoadingViewWithText(loadingText: 'Getting Orders ....')
        //   : mainWidget,

      drawer: MainAppDrawer(),
    );
  }

 /* void fetchData() async {
    RequestStatus status =
        await Provider.of<OrdersProvider>(context, listen: false)
            .fetchOrdersFromServer;
    switch (status) {
      case RequestStatus.success:
        _isLoading = false;
        break;
      case RequestStatus.successButEmpty:
        _isLoading = false;
        _isEmpty = true;
        break;
      case RequestStatus.failed:
      case RequestStatus.unauthorized:
      default:
        _isLoading = false;
        break;
    }

    setState(() {});
  }*/

 Widget emptyListWidget(BuildContext context){
   return Center(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Image.asset('assets/images/img_no_orders.png'),
         Container(
           margin: EdgeInsets.only(top: 10.0),
           child: Text("No Orders yet"),
         ),
         RaisedButton(
           onPressed: () => Navigator.pop(context),
           child: Text('Continue Shopping...'),
           textColor: Colors.white,
           color: Theme.of(context).primaryColor,
         ),
       ],
     ),
   );
 }

  Widget get mainWidget {
    print("MainWidget");
    return Container(
            padding: EdgeInsets.only(bottom: 10.00),
            child: Consumer<OrdersProvider>(
              builder: (_, ordersProvider, builderChild) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    return OrdersItem(
                      orderModel: ordersProvider.allOrders[index],
                    );
                  },
                  itemCount: ordersProvider.allOrders.length,
                );
              },
            ),
          );
  }
}
