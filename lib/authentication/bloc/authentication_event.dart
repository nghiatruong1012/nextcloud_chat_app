part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AuthenticationStatusChanged extends AuthenticationEvent {
  final AuthenticationStatus status;

  const AuthenticationStatusChanged(this.status);

  @override
  // TODO: implement props
  List<Object?> get props => [status];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}
