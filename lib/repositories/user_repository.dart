
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  User? _user;

  Future<User?> getUser() async {
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    String server = sharedUser.getString("server") ?? '';
    String username = sharedUser.getString("username") ?? '';
    String password = sharedUser.getString("password") ?? '';

    // Map<String, dynamic> userMap =
    //     jsonDecode(shared_User.getString("user") ?? "{}");
    if (server.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      _user = User(server, username, password);
      if (_user != null) return _user;
    }
    return User.empty;
  }
}
