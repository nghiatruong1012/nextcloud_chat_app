import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:nextcloud_chat_app/models/user_data.dart';
import 'package:nextcloud_chat_app/screen/userInfo/view/user_info.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/user_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final User user =
        context.select((AuthenticationBloc bloc) => bloc.state.user);
    final Future<UserData> futureUserData =
        UserService().getUserData(user.username.toString());
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          bottomOpacity: 0.0,
          elevation: 0.0,
          leading: Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_outlined, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: const Text(
            'Setting',
            style: TextStyle(color: Colors.black),
          )),
      body: SingleChildScrollView(
        child: Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: futureUserData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserInfo(userData: snapshot.data!),
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Builder(builder: (context) {
                                  return FutureBuilder(
                                      future: ConversationService()
                                          .getConversationAvatar(
                                              '',
                                              user.username.toString(),
                                              '',
                                              128),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return snapshot.data ??
                                              const Icon(Icons.person);
                                        } else {
                                          return const Icon(Icons.person);
                                        }
                                      });
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            snapshot.data!.displayname.toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('error'),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            ListTile(
              onTap: () {
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationLogoutRequested());
              },
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
            ),
          ],
        )),
      ),
    );
  }
}
