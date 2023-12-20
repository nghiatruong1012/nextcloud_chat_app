import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(Duration(seconds: 1));
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    String server = sharedUser.getString("server") ?? '';
    String username = sharedUser.getString("username") ?? '';
    String password = sharedUser.getString("password") ?? '';
    // Map<String, dynamic> usermap =
    //     jsonDecode(sharedUser.getString("user") ?? "{}");
    if (server.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      print(server + " - " + username + " - " + password);
      yield AuthenticationStatus.authenticated;
    } else {
      yield AuthenticationStatus.unauthenticated;
    }
    yield* _controller.stream;
  }

  void logIn(
      {required String server,
      required String username,
      required String password}) async {
    try {
      SharedPreferences shared_User = await SharedPreferences.getInstance();
      // String userDataJson = jsonEncode();
      shared_User.setString('server', server);
      shared_User.setString('username', username);
      shared_User.setString('password', password);
      _controller.add(AuthenticationStatus.authenticated);
      print(" authen ");
    } catch (e) {
      _controller.add(AuthenticationStatus.unauthenticated);
      print(e);
      // Utils().showToast(msg: "Error");
    }
  }

  Future<void> logOut() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    shared_User.remove('server');
    shared_User.remove('username');
    shared_User.remove('password');
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
