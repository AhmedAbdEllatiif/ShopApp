import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/product_model.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/services/http_requests.dart';
import 'package:shop_app/widgets/loading_view_with_text.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/EditProductScreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  TextEditingController _imageUrlController = TextEditingController();
  bool isEditScreen = false;
  bool _isLoading = false;

  ProductModel productModel = ProductModel(
      id: 'id123', title: '', description: '', price: 0.0, imageUrl: '');

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  var isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) {
      if (ModalRoute.of(context).settings.arguments != null) {
        isEditScreen = true;
        final productId = ModalRoute.of(context).settings.arguments as String;
        ProductModel product =
            Provider.of<ProductsProvider>(context, listen: false)
                .productById(productId);
        _imageUrlController = TextEditingController(text: product.imageUrl);
        productModel = ProductModel(
          id: product.id,
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          isAddedToCart: product.isAddedToCart,
          isFavorite: product.isFavorite,
        );
      }
    }
    isInit = false;

    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,

      ///AppBar
      appBar: AppBar(
        title: Text(
          isEditScreen ? 'Edit Product' : 'Add Product',
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  saveOrEditProduct(context);
                },
              );
            },
          ),
        ],
      ),

      ///Body
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading ? loadingWidget : mainWidget,
      ),
    );
  }

  ///                                                       ////
  ///                                                       ////
  ///                           (Widgets)                   ////
  ///                                                       ////
  ///                                                       ////

  ///To return loading widget
  Widget get loadingWidget {

    return LoadingViewWithText(
      loadingText: isEditScreen? 'Updating Product ....' :  'Add a New Product ....',
    );
  }

  ///To return main widget after loading
  Widget get mainWidget {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          ///Title
          TextFormField(
            initialValue: productModel.title,
            decoration: InputDecoration(labelText: 'Title'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_priceFocusNode);
              //_priceFocusNode.requestFocus();
            },
            onSaved: (titleValue) {
              productModel = ProductModel(
                id: productModel.id,
                title: titleValue,
                description: productModel.description,
                imageUrl: productModel.imageUrl,
                price: productModel.price,
                isFavorite: productModel.isFavorite,
                isAddedToCart: productModel.isAddedToCart,
              );
            },
            validator: (titleValue) {
              return titleValue.isEmpty ? 'Enter title' : null;
            },
          ),

          ///Price
          TextFormField(
            // autovalidate: true,

            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(labelText: 'Price'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            initialValue:
                productModel.price == 0.0 ? '' : productModel.price.toString(),
            focusNode: _priceFocusNode,
            onFieldSubmitted: (priceValue) {
              FocusScope.of(context).requestFocus(_descFocusNode);
            },
            onSaved: (priceValue) {
              productModel = ProductModel(
                id: productModel.id,
                title: productModel.title,
                description: productModel.description,
                imageUrl: productModel.imageUrl,
                price: double.parse(priceValue),
                isFavorite: productModel.isFavorite,
                isAddedToCart: productModel.isAddedToCart,
              );
            },
            validator: (priceValue) {
              if (priceValue.isEmpty) {
                return 'Enter Price';
              } else if (double.tryParse(priceValue) == null) {
                return 'Enter Valid Price';
              } else if (double.parse(priceValue) <= 0) {
                return 'Enter Valid Price';
              }
              return null;
            },
          ),

          ///Description
          TextFormField(
            initialValue: productModel.description,
            decoration: InputDecoration(labelText: 'Description'),
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            focusNode: _descFocusNode,
            onSaved: (descValue) {
              productModel = ProductModel(
                id: productModel.id,
                title: productModel.title,
                description: descValue,
                imageUrl: productModel.imageUrl,
                price: productModel.price,
                isFavorite: productModel.isFavorite,
                isAddedToCart: productModel.isAddedToCart,
              );
            },
            validator: (descValue) {
              return descValue.isEmpty ? 'Enter Description' : null;
            },
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ///ImagePreview
              Container(
                width: 100.0,
                height: 100.0,
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 8.0, right: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.grey),
                ),
                child: imageWidget,
              ),

              ///ImageUrl
              Expanded(
                child: TextFormField(
                  //initialValue: productModel.imageUrl == ''? '' : productModel.imageUrl,
                  decoration: InputDecoration(labelText: 'Image URL'),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  controller: _imageUrlController,
                  focusNode: _imageUrlFocusNode,
                  onEditingComplete: () {
                    setState(() {});
                  },
                  onSaved: (urlValue) {
                    productModel = ProductModel(
                      id: productModel.id,
                      title: productModel.title,
                      description: productModel.description,
                      imageUrl: urlValue.trim(),
                      price: productModel.price,
                      isFavorite: productModel.isFavorite,
                      isAddedToCart: productModel.isAddedToCart,
                    );
                  },
                  validator: (urlValue) {
                    return urlValue.isEmpty ? 'Enter URL' : null;
                  },
                  onFieldSubmitted: (_) {
                    saveOrEditProduct(context);
                  },
                  // onFieldSubmitted: ,
                ),
              ),
            ],
          ),

          ///Add Product Button
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text(
                isEditScreen ? 'Edit Product' : 'Add Product',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                saveOrEditProduct(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  ///To return widget for the image
  Widget get imageWidget {
    if (productModel.imageUrl == '') {
      return _imageUrlController.text.isEmpty
          ? Text(
              'Enter a URL',
              textAlign: TextAlign.center,
            )
          : SizedBox(
              child: Image.network(
                _imageUrlController.text.trim(),
                fit: BoxFit.cover,
              ),
            );
    } else {
      return SizedBox(
        width: 100.0,
        height: 100.0,
        child: Image.network(
          productModel.imageUrl,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  ///                                                       ////
  ///                                                       ////
  ///                             (Logic)                   ////
  ///                                                       ////
  ///                                                       ////

  ///To validate forms
  bool get _validateForms {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return true;
    }
    return false;
  }

  ///To add a new product
  Future<bool> _addProduct() async {
    if (_validateForms) {
      setState(() {
        _isLoading = true;
      });
      return await Provider.of<ProductsProvider>(context, listen: false)
          .addProduct(productModel)
          .then((RequestStatus status) {
        switch (status) {
          case RequestStatus.success:
            return Future.value(true);
          case RequestStatus.failed:
            return Future.value(false);
          case RequestStatus.unauthorized:
            print("EditProductScreen ==> _addProduct ==>  RequestStatus.unauthorized");
            return Future.value(false);
          default:
            {
              return Future.value(false);
            }
        }
      }).catchError((error){
        showDialog(context: context,
        builder: (context) {
          return  AlertDialog(
            title: Text('An Error occurred'),
          );
        },);
      });
    } else {
      return Future.value(false);
    }
  }

  ///To update current product
  void _updateProductWithForms(context) async {
    if (_validateForms) {
      setState(() {
        _isLoading = true;
      });
      RequestStatus status = await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(productModel);
      switch(status){
        case RequestStatus.success:
          Navigator.of(context).pop();
          break;
        case RequestStatus.failed:
        case RequestStatus.unauthorized:
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Something gone wrong"),
            backgroundColor: Theme.of(context).errorColor,
            duration: Duration(milliseconds: 2000),
          ),
        );
          break;
      }


    }
  }

  ///To check is the screen isEditScreen or no
  ///Then do the right action save or edit
  void saveOrEditProduct(context) async {
    if (isEditScreen) {
      _updateProductWithForms(context);
    } else {
      await _addProduct().then((savedStatus) {
        if (savedStatus) {
          setState(() {
            Navigator.of(context).pop();
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("Something gone wrong"),
              backgroundColor: Theme.of(context).errorColor,
              duration: Duration(milliseconds: 2000),
            ),
          );
        }
      });
    }
  }

  ///                                                       ////
  ///                                                       ////
  ///                           (LifeCycle)                 ////
  ///                                                       ////
  ///                                                       ////
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }
}
