import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_details.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),

        ///Products with proxy
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (BuildContext context) => ProductsProvider(
              Provider.of<AuthProvider>(context, listen: false)),
          //create: (ctx) =>  ProductsProvider(Provider.of<AuthProvider>(ctx,listen:false)),
          // builder: (context, child) {} ,
          update:
              (BuildContext ctx, AuthProvider auth, ProductsProvider previous) {
            print('MainDart: MultiProvider ==> Main Token ${auth.token}');
            return ProductsProvider(auth.token,
                userId: auth.userId,
                productsList:
                    previous.productsList == null ? [] : previous.productsList);
          },
        ),

        ///OrdersProvider depend on AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (context) =>
              OrdersProvider(Provider.of<AuthProvider>(context, listen: false)),
          update:
              (BuildContext ctx, AuthProvider auth, OrdersProvider previous) {
            return OrdersProvider(auth.token,
                userId: auth.userId,
                orders: previous.orders == null ? [] : previous.orders);
          },
        ),

        ///CartProvider depend on ProductsProvider
        ///ProductsProvider depend on AuthProvider
        ChangeNotifierProxyProvider2<AuthProvider, ProductsProvider, CartProvider>(
            create: (BuildContext context) => CartProvider(),
            //create: (ctx) =>  ProductsProvider(Provider.of<AuthProvider>(ctx,listen:false)),
            // builder: (context, child) {} ,
            update: (BuildContext ctx, AuthProvider auth,
                ProductsProvider previous, CartProvider cart) {
              return cart..update(previous.productsList);
            }),

      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, authData, builderChild) {
          print("MainDart isAuth: ${authData.isAuth}");
          return MaterialApp(
            title: 'Shop App',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              disabledColor: Colors.grey,

              primaryTextTheme:
                  TextTheme(headline6: TextStyle(color: Colors.white)),

              fontFamily: 'Lato',
              // This makes the visual density adapt to the platform that you run
              // the app on. For desktop platforms, the controls will be smaller and
              // closer together (more dense) than on mobile platforms.
              visualDensity: VisualDensity.adaptivePlatformDensity,

              ///To change the transition animation
              // pageTransitionsTheme: PageTransitionsTheme(
              //   builders: {
              //     TargetPlatform.android: CustomPageTransitionBuilder(),
              //     TargetPlatform.iOS: CustomPageTransitionBuilder(),
              //   },
              // ),
            ),

            home: authData.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: authData.tryAutoLogin(),
                    builder: (context, authSnapShot) {
                      switch (authSnapShot.connectionState) {
                        case ConnectionState.waiting:
                          return SplashScreen();
                        case ConnectionState.done:
                          return authSnapShot.data == false
                              ? AuthScreen()
                              : ProductsOverviewScreen();
                        default:
                          return AuthScreen();
                      }
                    },
                  ),
            routes: {
              ProductsOverviewScreen.routeName: (context) =>
                  ProductsOverviewScreen(),
              ProductDetailsScreen.routeName: (context) =>
                  ProductDetailsScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductScreen.routeName: (context) => UserProductScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
              AuthScreen.routeName: (context) => AuthScreen(),
              //'/' : (context) => ProductsOverviewScreen()
            },
            // initialRoute: AuthScreen.routeName,
            // home: authData.isAuth
            //     ? ProductsOverviewScreen()
            //     : AuthScreen(), //We can replace home with '/' in the routes
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final auth = Provider.of<AuthProvider>(context);
    // return auth.isAuth ? ProductsOverviewScreen() : AuthScreen();

    return Scaffold(
      body: Center(
        child: Text("This is Splash Screen ...!!.."),
      ),
    );
  }
}
