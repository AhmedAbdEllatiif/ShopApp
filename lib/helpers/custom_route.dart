import 'package:flutter/material.dart';



///This class for single transition (on the fly transition)
///You can add more than one with different transition
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder widgetBuilder, RouteSettings routeSettings})
      : super(
    builder: widgetBuilder,
    settings: routeSettings,
  );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == '/') {
      return child;
    }
    return FadeTransition(opacity: animation, child: child,);
  }
}


///This class the change the whole transition of the app
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(PageRoute<T> route,BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (route.settings.name == '/') {
      return child;
    }
    return FadeTransition(opacity: animation, child: child,);
    // return super
    // .buildTransitions(context, animation, secondaryAnimation, child);
  }
}
