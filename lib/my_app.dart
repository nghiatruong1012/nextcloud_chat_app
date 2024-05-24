import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/repositories/authentication_repository.dart';
import 'package:nextcloud_chat_app/repositories/user_repository.dart';
import 'package:nextcloud_chat_app/screen/addParticipants/bloc/add_participants_bloc.dart';
import 'package:nextcloud_chat_app/screen/createConversation/bloc/create_conversation_bloc.dart';
import 'package:nextcloud_chat_app/screen/home/bloc/home_bloc.dart';
import 'package:nextcloud_chat_app/screen/home/view/home.dart';
import 'package:nextcloud_chat_app/screen/login/view/connect_page.dart';
import 'package:nextcloud_chat_app/screen/login/view/login.dart';
import 'package:nextcloud_chat_app/screen/splash/view/splash.dart';

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
      required this.authenticationRepository,
      required this.userRepository});
  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthenticationBloc(
                authenticationRepository: authenticationRepository,
                userRepository: userRepository),
          ),
          BlocProvider(
            create: (context) => HomeBloc()..add(LoadConversationEvent()),
          ),
          BlocProvider(
            create: (context) => CreateConversationBloc(),
          ),
          BlocProvider(
            create: (context) => AddParticipantsBloc(),
          ),
          // BlocProvider(
          //   create: (context) => ChatBloc(),
          // ),
        ],
        child: const MainApp(),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(
      //   fontFamily: GoogleFonts.notoColorEmoji().fontFamily,
      // ),
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil(
                    HomePage.route(), (route) => false);
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil(
                    LoginPage.route(), (route) => false);
                break;
              default:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
