import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/helpers/PreferencesHelper.dart';
import 'package:shop_app/model/auth_data.dart';
import 'package:shop_app/services/http_requests.dart';

class AuthProvider with ChangeNotifier {
  static const String tokenKey = 'tokenKey';

  String _token;
  DateTime _expiryTokenDate;
  String _userId;

  Future<void> signUp(AuthData data) async {
    try {
      AuthData authData = await ApiManager.signUp(data);
      _token = authData.idToken;
      int expiresAfterInSec = int.parse(authData.expiresIn);
      _expiryTokenDate = DateTime.now().add(
        Duration(
          seconds: expiresAfterInSec,
        ),
      );
      _userId = authData.localId;
      notifyListeners();
      _autoLogout();
    } catch (error) {
      print('AuthProvider: signUp ==> error ==> ${error.toString()}');
      throw (error);
    }
  }

  Future<void> logIn(AuthData data) async {
    try {
      AuthData authData = await ApiManager.logIn(data);
      int expiresAfterInSec = int.parse(authData.expiresIn);
      _token = authData.idToken;
      _expiryTokenDate = DateTime.now().add(
        Duration(
          seconds: expiresAfterInSec,
        ),
      );
      _userId = authData.localId;
      notifyListeners();
      _autoLogout();
      //final preferences = await SharedPreferences.getInstance();
      //preferences.setString(tokenKey,_token);
      ///We want to add all userData in the preferences
      final userData = json.encode({
        PreferencesHelper.tokenKey: _token,
        PreferencesHelper.userIdKey: _userId,
        PreferencesHelper.expiryDateKey: _expiryTokenDate.toIso8601String()
      });
      PreferencesHelper.addToPreferences(
        PreferencesHelper.userDataKey,
        userData,
      );
    } catch (error) {
      print('AuthProvider: logIn ==> error ==> ${error.toString()}');
      throw (error);
    }
  }

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  Future<bool> tryAutoLogin() async {
    final data = await PreferencesHelper.tryAutoLogin;

    if (data == null){
      print("AuthProvider tryAutoLogin data ==> null");
      return false;
    }

    final userData = json.decode(data);
    _expiryTokenDate =
        DateTime.parse(userData[PreferencesHelper.expiryDateKey]);


    if (!_expiryTokenDate.isAfter(DateTime.now())) {
      return false;
    }
    _token = userData[PreferencesHelper.tokenKey];
    _userId = userData[PreferencesHelper.userIdKey];
    return true;
  }

  String get token {
    if (_expiryTokenDate != null &&
        _expiryTokenDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryTokenDate = null;
    await PreferencesHelper.clearAutoLogin();
    notifyListeners();
  }

  void _autoLogout() {
    final durationToExpiry =
        _expiryTokenDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: durationToExpiry), () {
      logout();
    });
  }
}
