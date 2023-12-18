import 'package:flutter/material.dart';
import 'package:nextcloud_chat_app/my_app.dart';
import 'package:nextcloud_chat_app/repositories/authentication_repository.dart';
import 'package:nextcloud_chat_app/repositories/user_repository.dart';
import 'package:nextcloud_chat_app/screen/login/view/login.dart';

void main() {
  runApp(
    // MaterialApp(),
    MyApp(
      authenticationRepository: AuthenticationRepository(),
      userRepository: UserRepository(),
    ),
  );
}
