import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/HttpException.dart';
import 'package:shop_app/model/auth_data.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      //(.. operator) to ignore return type of translate function
                      // and return the type of rotationZ function
                      //you can use this ==> final rotationZ =  Matrix4.rotationZ(-8 * pi / 180);
                      //rotationZ.translate(-10.0);
                      //and then  transform: rotationZ
                      //This is the same concept
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  ///GlobalKeys
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormFieldState> _emailTextKey = GlobalKey();
  final GlobalKey<FormFieldState> _passwordTextKey = GlobalKey();

  ///AuthModes
  AuthMode _authMode = AuthMode.Login;
  AuthData _authData = AuthData(email: '', password: '');

  ///Local variables
  var _isLoading = false;
  final _passwordController = TextEditingController();
  var _isEmailAlreadyExists = false;
  var _isEmailNotFound = false;
  var _isWrongPassword = false;

  ///Animation
  AnimationController _animationController;
  Animation<Offset>
      _slideAnimation; //Animation is a generic type<offset>,<double>,<size>
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    ///You need to listener if you don't use animationBuilder or animationContainer
    // _heightAnimation.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
        //BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            // BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: _emailTextKey,
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (_isEmailAlreadyExists) {
                      return 'Email Already exists!';
                    }
                    if (_isEmailNotFound) {
                      return 'Email Not Found!';
                    }
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData.email = value;
                  },
                ),
                TextFormField(
                  key: _passwordTextKey,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (_isWrongPassword) {
                      return 'Invalid Password!';
                    } else if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData.password = value;
                  },
                ),

                ///To animate confirm password textField
                AnimatedContainer(
                  curve: Curves.easeIn,
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                return value != _passwordController.text
                                    ? 'Passwords do not match!'
                                    : null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),

                ///To make space between textFields and button
                SizedBox(
                  height: 20,
                ),

                ///Check the loading state to show progressIndicator
                if (_isLoading)
                  CircularProgressIndicator()
                else

                  ///Login or signUp button
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),

                ///Button to switch between login mode and signUp mode
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  ///To submit data
  void _submit() async {
    _isEmailAlreadyExists = false;
    _isWrongPassword = false;
    _isEmailNotFound = false;
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    await signInOrUp();

    if (this.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ///To switch between signUp mode and login mode
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      //To forward the animation controller
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      //To reverse the animation controller
      _animationController.reverse();
    }
  }

  ///To make login or signUp
  Future<void> signInOrUp() async {
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthProvider>(context, listen: false)
            .logIn(_authData)
            .then((_) => Navigator.pushReplacementNamed(
                context, ProductsOverviewScreen.routeName));
      } else {
        await Provider.of<AuthProvider>(context, listen: false)
            .signUp(_authData)
            .then((_) {});
      }
    } on HttpException catch (error) {
      var errorMessage = error.toString();
      if (errorMessage.contains('INVALID_PASSWORD')) {
        _isWrongPassword = true;
        _passwordTextKey.currentState.validate();
      }
      if (errorMessage.contains('EMAIL_EXISTS')) {
        _isEmailAlreadyExists = true;
        _emailTextKey.currentState.validate();
      }
      if (errorMessage.contains('EMAIL_NOT_FOUND')) {
        _isEmailNotFound = true;
        _emailTextKey.currentState.validate();
      }
    } catch (error) {
      _showErrorDialog('Something wrong,try again..');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (builderCtx) {
        return AlertDialog(
          title: Text('An Error Occurred'),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(builderCtx).pop();
              },
            )
          ],
        );
      },
    );
  }
}
