import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/user_product_model.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/services/http_requests.dart';

class UserItemProduct extends StatelessWidget {
  final UserProductModel userProductModel;
 final GlobalKey<ScaffoldState> scaffoldKey;
  UserItemProduct({this.userProductModel,this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final scaffold =  Scaffold.of(context);
    final theme =  Theme.of(context);
    return Builder(
        builder: (mContext) {
          return Column(
            children: [
              ListTile(

                ///Title
                title: Text(
                  userProductModel.title,
                ),

                ///Leading (Product Image)
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userProductModel.imageUrl,
                  ),
                ),


                ///Trailing (edit & delete buttons)
                trailing: SizedBox(
                  width: 100.0,
                  child: Row(
                    children: [

                      ///EditIcon
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            var productId = userProductModel.id;
                            Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: productId);
                          }),

                      ///DeleteIcon
                      IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).errorColor,
                          ),
                          onPressed: () {
                            deleteProduct(scaffold,theme,context);
                          }),
                    ],
                  ),
                ),
              ),

              ///Divider
              Divider(),
            ],
          );
        },);
  }
  
  
  void deleteProduct(scaffold,theme,context) async {
    RequestStatus status = await Provider.of<ProductsProvider>(context,listen: false)
        .deleteProduct(userProductModel.id);
    
    switch(status){
      
      case RequestStatus.success:
      scaffold.showSnackBar(
            SnackBar(content: Text( 'Product Deleted'),behavior: SnackBarBehavior.floating,duration: Duration(seconds: 1),)
        );
        break;
      case RequestStatus.failed:
      case RequestStatus.unauthorized:
      scaffold.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Something gone wrong"),
            backgroundColor: theme.errorColor,
            duration: Duration(milliseconds: 2000),
          ),
      );
      
        break;
    }
  }
  
}
