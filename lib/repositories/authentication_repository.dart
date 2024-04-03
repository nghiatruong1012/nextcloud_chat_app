import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    String server = sharedUser.getString("server") ?? '';
    String username = sharedUser.getString("username") ?? '';
    String password = sharedUser.getString("password") ?? '';
    // Map<String, dynamic> usermap =
    //     jsonDecode(sharedUser.getString("user") ?? "{}");
    if (server.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
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
      SharedPreferences sharedUser = await SharedPreferences.getInstance();
      // String userDataJson = jsonEncode();
      sharedUser.setString('server', server);
      sharedUser.setString('username', username);
      sharedUser.setString('password', password);
      _controller.add(AuthenticationStatus.authenticated);
    } catch (e) {
      _controller.add(AuthenticationStatus.unauthenticated);
      print(e);
      // Utils().showToast(msg: "Error");
    }
  }

  Future<void> logOut() async {
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.remove('server');
    sharedUser.remove('username');
    sharedUser.remove('password');
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
