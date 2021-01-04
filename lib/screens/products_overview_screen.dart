import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/services/http_requests.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/loading_view_with_text.dart';
import 'package:shop_app/widgets/main_app_drawer.dart';
import 'package:shop_app/widgets/products_grid_widget.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const String routeName = '/ProductsOverviewScreen';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavorites = false;
  bool _isLoading = true;
  bool initData = true;

  @override
  void didChangeDependencies() {
    if(initData){
      fetchDataFromServer();
    }
    initData = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      ///Appbar
      appBar: AppBar(
        title: Text(
          'MyShop',
        ),

        ///Appbar actions
        actions: [
          ///CartBadge
          Consumer<CartProvider>(
            builder: (context, cart, builderChild) {
              return Badge(
                child: builderChild,
                value: cart.cartItemsCount,
              );
            },
            child: Badge(
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  //print("Cart Clicked");
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
              value: '',
            ),
          ),

          ///PopMenu
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Only Favorites'),
                  value: FilterOptions.Favorites,
                ),
                PopupMenuItem(
                  child: Text('All Products'),
                  value: FilterOptions.All,
                ),
              ];
            },
            icon: Icon(Icons.menu),
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                switch (selectedValue) {
                  case FilterOptions.Favorites:
                    _showOnlyFavorites = true;
                    break;
                  case FilterOptions.All:
                    _showOnlyFavorites = false;
                    break;
                }
              });
            },
          ),
        ],
      ),

      ///Body
      body: _isLoading
          ? LoadingViewWithText(
              loadingText: 'Getting Products ...',
            )
          : ProductsGridWidget(
              isShowOnlyFavorites: _showOnlyFavorites,
            ),

      drawer: MainAppDrawer(),
    );
  }


  void addItemsToCart(List<ProductModel> products) async{
    print("ProductsIverView adding to cart");
    products.forEach((product) {
      if(product.isAddedToCart){
        Provider.of<CartProvider>(context)
            .addItem(
            productId: product.id,
            title: product.title,
            description: product.description,
            price: product.price,
            image: product.imageUrl,
            isLoadingFromServer: true
        );
        print('product Added ${product.title}');
      }

    });
  }

  void fetchDataFromServer() async{
    var productsData =  Provider.of<ProductsProvider>(context,listen: true);
    //await productsData.fetchProductsFromServer();

    RequestStatus requestStatus =  await productsData.fetchProductsFromServer;
    switch(requestStatus){
      case RequestStatus.success:
       if(this.mounted){


          setState(() {
           // addItemsToCart(productsData);
            _isLoading = false;
          });


       }
        break;
      case RequestStatus.failed:
        setState(() {
          _isLoading = false;
        });

        break;
      case RequestStatus.unauthorized:
        setState(() {
          _isLoading = false;
        });
        break;
      default:
        setState(() {
          _isLoading = false;
        });
    }
  }

}
