import 'package:flutter/material.dart';

class LoadingViewWithText extends StatelessWidget {

  final String loadingText;


  LoadingViewWithText({this.loadingText = 'Loading ....'});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Container(
        width: double.infinity,
        height: 150.0,
        child: Column(
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(loadingText),
              ),
            )
          ],
        ),
      ),
    );;
  }
}
