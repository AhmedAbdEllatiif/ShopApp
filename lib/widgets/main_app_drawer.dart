import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

class MainAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello Friend'),
            automaticallyImplyLeading: false, //To hide back button
          ),
          Divider(),

          ///Home Page
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),

          Divider(),

          ///Home Page
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: (){
              openRoutes(context, OrdersScreen.routeName,screen: OrdersScreen());
            },
          ),

          Divider(),

          ///Cart Page
          Consumer<CartProvider>(
              builder: (context, cartProvider, builderChild) => ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Cart'),
                trailing: ClipRRect(
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    color: Theme.of(context).accentColor,
                      child: Text(cartProvider.cartItemsCount,
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                onTap: (){
                  openRoutes(context, CartScreen.routeName,screen: CartScreen());
                },
              ),
          ),

          Divider(),

          ///MyProducts Page
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: (){
              openRoutes(context, UserProductScreen.routeName,screen: UserProductScreen());
            },
          ),

          Divider(),


          ///Logout
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: (){
              //openRoutes(context, OrdersScreen.routeName);

              Provider.of<AuthProvider>(context,listen: false).logout();
            },
          ),

          Divider(),
        ],
      ),
    );
  }

  void openRoutes(BuildContext context , routeName,{screen}){
    bool isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == routeName) {
        isNewRouteSameAsCurrent = true;

        //Add This to close the drawer
        Navigator.pop(context);
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {
      ///To use default animation transition between different routes
      //Navigator.pushNamed(context, routeName);

      ///To use (Custom) animation transition between different routes
      Navigator.pushReplacement(context, CustomRoute(widgetBuilder: (context) => screen,));

      ///To close the drawer
      Scaffold.of(context).openEndDrawer();


      ///To add custom transition to whole app you can customize it
      ///By Create Your CustomTransitionPageBuilder and use it
      /// 1:Create CustomTransitionPageBuilder (In this project CustomTransitionPageBuilder is in custom_route.dart file)
      /// 2:In the main.dart file add :
                      // PageTransitionsTheme(
                      //                 builders: {
                      //                   TargetPlatform.android: CustomPageTransitionBuilder(),
                      //                   TargetPlatform.iOS: CustomPageTransitionBuilder(),
                      //                 },
                      //               ),
      /// 3: use the default navigation
      //Navigator.pushNamed(context, routeName);
    }
  }
}




