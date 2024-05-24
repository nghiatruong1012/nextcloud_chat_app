import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:nextcloud_chat_app/models/user_data.dart';
import 'package:nextcloud_chat_app/screen/userInfo/view/user_info.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/user_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

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
    Future<UserStatus> futureUserStatus = UserService().getUserStatus();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Setting',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User info
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
                        ),
                      );
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
                                        .getConversationAvatar('',
                                            user.username.toString(), '', 128),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return snapshot.data ??
                                            const Icon(Icons.person);
                                      } else {
                                        return const Icon(Icons.person);
                                      }
                                    },
                                  );
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
            // Set status
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Trạng thái trực tiếp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            FutureBuilder(
              future: futureUserStatus,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data!.userId);
                  return Container(
                      height: 150,
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: OutlinedButton.icon(
                              style: (snapshot.data!.status == 'online')
                                  ? ButtonStyle(
                                      side: MaterialStatePropertyAll(
                                        BorderSide(
                                            color: Colors.black, width: 2),
                                      ),
                                    )
                                  : null,
                              onPressed: () {
                                setState(() {
                                  futureUserStatus = UserService()
                                      .updateUserStatus(
                                          {"statusType": "online"});
                                });
                              },
                              icon: Icon(
                                Icons.circle,
                                color: Colors.green,
                              ),
                              label: Text('Online'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: OutlinedButton.icon(
                              style: (snapshot.data!.status == 'away')
                                  ? ButtonStyle(
                                      side: MaterialStatePropertyAll(
                                        BorderSide(
                                            color: Colors.black, width: 2),
                                      ),
                                    )
                                  : null,
                              onPressed: () {
                                setState(() {
                                  futureUserStatus = UserService()
                                      .updateUserStatus({"statusType": "away"});
                                });
                              },
                              icon: Icon(
                                Icons.nightlight_round,
                                color: Colors.yellow.shade800,
                              ),
                              label: Text('Away'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: OutlinedButton.icon(
                              style: (snapshot.data!.status == 'dnd')
                                  ? ButtonStyle(
                                      side: MaterialStatePropertyAll(
                                        BorderSide(
                                            color: Colors.black, width: 2),
                                      ),
                                    )
                                  : null,
                              onPressed: () {
                                setState(() {
                                  futureUserStatus = UserService()
                                      .updateUserStatus({"statusType": "dnd"});
                                });
                              },
                              icon: Icon(
                                Icons.do_not_disturb_on_rounded,
                                color: Colors.red.shade800,
                              ),
                              label: Text('Do not disturb'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: OutlinedButton.icon(
                              style: (snapshot.data!.status == 'invisible')
                                  ? ButtonStyle(
                                      side: MaterialStatePropertyAll(
                                        BorderSide(
                                            color: Colors.black, width: 2),
                                      ),
                                    )
                                  : null,
                              onPressed: () {
                                setState(() {
                                  futureUserStatus = UserService()
                                      .updateUserStatus(
                                          {"statusType": "invisible"});
                                });
                              },
                              icon: Icon(Icons.circle_outlined),
                              label: Text('Invisible'),
                            ),
                          ),
                        ],
                      ));
                } else if (snapshot.hasError) {
                  return Text('Error');
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),

            // Log out button
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
        ),
      ),
    );
  }
}
