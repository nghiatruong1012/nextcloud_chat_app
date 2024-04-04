import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:diffie_hellman/diffie_hellman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:nextcloud_chat_app/screen/chat/view/chat.dart';
import 'package:nextcloud_chat_app/screen/createConversation/view/create_conversation.dart';
import 'package:nextcloud_chat_app/screen/home/bloc/home_bloc.dart';
import 'package:nextcloud_chat_app/screen/setting/view/setting.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/firebase_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';

import 'package:nextcloud_chat_app/widgets/loading_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  Timer? _debounceTimer;
  final _focusNode = FocusNode();
  Future<Map<String, String>> futureRequestHeaders =
      HTTPService().authImgHeader();
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   context.read<HomeBloc>().add(LoadConversationEvent());
  // }
  @override
  void initState() {
    // final user = context.select((AuthenticationBloc bloc) => bloc.state.user);

    // print(user);
    // _imageHeader();
    // TODO: implement initState
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      context.read<HomeBloc>().add(LoadConversationEvent());
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    _debounceTimer?.cancel(); // Cancel the debounce timer
    super.dispose();
  }

  // _imageHeader() async {
  //   requestHeaders = await HTTPService().authImgHeader();
  // }
  Future<void> setUpE2E(User user) async {
    print(user.toString());
    SharedPreferences sharedKey = await SharedPreferences.getInstance();
    String privateKey = sharedKey.getString(user.username.toString()) ?? '';
    if (privateKey.isNotEmpty) {
      print("prvkey" + privateKey);
    } else {
      print('crtkey');
      DhPkcs3Engine dhEngine = DhPkcs3Engine.fromGroup(DhGroup.g5);
      DhKeyPair keyPair = dhEngine.generateKeyPair();
      privateKey = keyPair.privateKey.toPem();
      String publicKey = keyPair.publicKey.toPem();
      sharedKey.setString(user.username.toString(), privateKey);
      FirebaseService()
          .createPublicKey(username: user.username.toString(), key: publicKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    setUpE2E(user);
    return Scaffold(
      // appBar: AppBar(title: Text("Home")),
      body: SafeArea(
          child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: FutureBuilder(
          future: futureRequestHeaders,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Stack(alignment: FractionalOffset.centerRight, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextField(
                        focusNode: _focusNode,
                        onChanged: (value) {
                          // if (_debounceTimer!.isActive) {
                          //   _debounceTimer!.cancel();
                          // }
                          _debounceTimer?.cancel();
                          _debounceTimer =
                              Timer(const Duration(milliseconds: 500), () {
                            context
                                .read<HomeBloc>()
                                .add(SearchConversationEvent(value));
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          hintText: 'Tìm kiếm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingScreen(),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(4),
                          backgroundColor: Colors.blue.shade300,
                          foregroundColor: Colors.blue.shade700,
                        ),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: FutureBuilder(
                                future: ConversationService()
                                    .getConversationAvatar(
                                        '', user.username.toString(), '', 64),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data ?? Container();
                                  } else {
                                    return snapshot.data ?? Container();
                                  }
                                }),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.searchList != current.searchList,
                    builder: (context, state) {
                      if (state.searchList != null &&
                          state.searchList!.isNotEmpty &&
                          snapshot.data != null) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: state.searchList!.length,
                            itemBuilder: (context, index) => ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    ChatProvider.route(
                                        state.searchList![index].token!,
                                        state.searchList![index].lastMessage!
                                            .id!,
                                        state.searchList![index]!,
                                        user));
                              },
                              leading: SizedBox(
                                width: 40,
                                height: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Builder(builder: (context) {
                                    if (state.searchList![index].type == 1) {
                                      return CachedNetworkImage(
                                        imageUrl:
                                            'http://$host:8080/ocs/v2.php/apps/spreed/api/v1/room/${state.searchList![index].token!}/avatar',
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) {
                                          return Container();
                                        },
                                        httpHeaders: snapshot.data,
                                      );
                                    } else if (state.searchList![index].type ==
                                        6) {
                                      return Container(
                                          color: const Color(0xFF0082c9),
                                          child:
                                              const Center(child: Text('📝')));
                                    } else {
                                      return SvgPicture.network(
                                        'http://$host:8080//ocs/v2.php/apps/spreed/api/v1/room/${state.searchList![index].token!}/avatar',
                                        headers: snapshot.data,
                                      );
                                    }
                                  }),
                                  // FutureBuilder(
                                  //     future: ConversationService()
                                  //         .getConversationAvatar(
                                  //             state.searchList![index].token!,
                                  //             state.searchList![index].name!,
                                  //             state.searchList![index]
                                  //                 .lastMessage!.actorType!),
                                  //     builder: (context, snapshot) {
                                  //       if (snapshot.hasData) {
                                  //         return snapshot.data ?? Container();
                                  //       } else {
                                  //         return CircularProgressIndicator();
                                  //       }
                                  //     }),
                                ),
                              ),
                              title: Text(state.searchList![index].displayName
                                  .toString()),
                              trailing: Builder(
                                builder: (context) {
                                  if (state.searchList![index].lastMessage!
                                          .timestamp!
                                          .toLocal()
                                          .day ==
                                      DateTime.now().day) {
                                    return Text(
                                      DateFormat('HH:mm').format(state
                                          .searchList![index]
                                          .lastMessage!
                                          .timestamp!),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.7)),
                                    );
                                  } else if (state.searchList![index]
                                          .lastMessage!.timestamp!
                                          .toLocal()
                                          .day ==
                                      DateTime.now()
                                          .subtract(const Duration(days: 1))) {
                                    return Text(
                                      'Hôm qua',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.7)),
                                    );
                                  } else if (state.searchList![index]
                                          .lastMessage!.timestamp!
                                          .toLocal()
                                          .year ==
                                      DateTime.now().year) {
                                    return Text(
                                      '${state.searchList![index].lastMessage!.timestamp!.day} tháng ${state.searchList![index].lastMessage!.timestamp!.month}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.7)),
                                    );
                                  } else {
                                    return Text(
                                      '${state.searchList![index].lastMessage!.timestamp!.day} tháng ${state.searchList![index].lastMessage!.timestamp!.month}, ${state.searchList![index].lastMessage!.timestamp!.year}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.7)),
                                    );
                                  }
                                },
                              ),
                              subtitle: (state.searchList![index].lastMessage!
                                          .actorId ==
                                      user.username)
                                  ? Text(
                                      "Bạn: ${state.searchList![index].lastMessage!.message}",
                                      maxLines: 1,
                                    )
                                  : Text(
                                      state.searchList![index].lastMessage!
                                          .message
                                          .toString(),
                                      maxLines: 1,
                                    ),
                            ),
                          ),
                        );
                      } else {
                        return ListLoading();
                      }
                    },
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0082c9),
        onPressed: () {
          // Utils().showToast('message');

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateConversation(),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
