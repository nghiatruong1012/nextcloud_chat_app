import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? server;
  final String? username;
  final String? password;

  const User(this.server, this.username, this.password);

  @override
  // TODO: implement props
  List<Object?> get props => [this.server, this.username, this.password];
  static const empty = User(null, null, null);
}
