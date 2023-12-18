import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nextcloud_chat_app/repositories/authentication_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationRepository _authenticationRepository;
  LoginBloc({required authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(LoginInitial()) {
    on<LoginEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<SubmitLogin>((event, emit) {
      try {
        print('Submit');
        _authenticationRepository.logIn(
            server: event.server,
            username: event.username,
            password: event.password);
      } catch (e) {
        print(e);
      }
    });
  }
}
