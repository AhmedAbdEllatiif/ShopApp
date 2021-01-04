import 'dart:convert';

class AuthData {
  String email;
  String password;

  String idToken;
  String refreshToken;
  String expiresIn;
  String localId;

  AuthData(
      {this.email,
      this.password,
      this.expiresIn,
      this.idToken,
      this.localId,
      this.refreshToken});

  String get toJson {
    return json.encode(
        {'email': email, 'password': password, 'returnSecureToken': true});
  }

  static AuthData fromJson(responseData) {
    return AuthData(
      expiresIn: responseData['expiresIn'],
      idToken: responseData['idToken'],
      email: responseData['email'],
      refreshToken: responseData['refreshToken'],
      localId: responseData['localId'],
    );
  }
}
