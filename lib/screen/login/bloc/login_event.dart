part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class SubmitLogin extends LoginEvent {
  String server;
  String username;
  String password;
  SubmitLogin(this.server, this.username, this.password);
}
