import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = '/ProductDetailsScreen';

  @override
  Widget build(BuildContext context) {
    String _productId = ModalRoute.of(context).settings.arguments as String;
    //Listen to (false) to not listen to updates once it loaded
    var _product = Provider.of<ProductsProvider>(context, listen: false)
        .productById(_productId);
    return Scaffold(
/*      appBar: AppBar(
        title: Text(_product.title),
      ),*/
      body: CustomScrollView(
        slivers: <Widget>[


          SliverAppBar(
            expandedHeight: 300,
            pinned: true, //To stick on the top
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_product.title),
              background: Container(
                height: 300.0,
                width: double.infinity,
                child: Hero(
                  tag: _productId,
                  child: Image.network(
                    _product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),


          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),

                  ///Title
                  Text(
                    '\$${_product.price}',
                    style: TextStyle(color: Colors.grey, fontSize: 20.0),
                  ),

                  SizedBox(
                    height: 10.0,
                  ),

                  ///Description
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      '${_product.description}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),

                  SizedBox(
                    height: 800.0,
                  ),

                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
