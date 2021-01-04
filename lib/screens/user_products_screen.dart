import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/user_product_model.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/item_product.dart';
import 'package:shop_app/widgets/item_user_product.dart';
import 'package:shop_app/widgets/main_app_drawer.dart';

class UserProductScreen extends StatefulWidget {

  static const String routeName = '/UserProductScreen';

  @override
  _UserProductScreenState createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {

  ProductsProvider productsProvider;
  Future<void> _refreshProducts(BuildContext context) async{
    await Provider.of<ProductsProvider>(context,listen: false).fetchProductsFromServer;
  }

  bool init = true;

  @override
  void initState() {

    super.initState();
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();




  @override
  Widget build(BuildContext context) {
    productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MainAppDrawer(),

      appBar: AppBar(
        title: const Text(
          'My Products',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh:()=> _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: productsProvider.productsList.length,
              itemBuilder: (_, index){
                //Recommended to use is value with list item to avoid providers from use the same widget with different data
                return  ChangeNotifierProvider.value(
                  value: productsProvider.productsList[index],
                  child: UserItemProduct(
                    userProductModel: UserProductModel(
                      id: productsProvider.productsList[index].id,
                      title: productsProvider.productsList[index].title,
                      imageUrl: productsProvider.productsList[index].imageUrl,
                    ),
                    scaffoldKey: _scaffoldKey,
                  ),
                );
              },
          ),
        ),
      ),

    );
  }
}
