import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/screen/chat/view/chat.dart';
import 'package:nextcloud_chat_app/screen/createConversation/view/create_conversation.dart';
import 'package:nextcloud_chat_app/screen/home/bloc/home_bloc.dart';
import 'package:nextcloud_chat_app/screen/setting/view/setting.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';

import 'package:nextcloud_chat_app/utils.dart';
import 'package:nextcloud_chat_app/widgets/loading_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  late Map<String, String> requestHeaders;
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   context.read<HomeBloc>().add(LoadConversationEvent());
  // }
  @override
  void initState() {
    _imageHeader();
    // TODO: implement initState
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      context.read<HomeBloc>().add(LoadConversationEvent());
    });
  }

  _imageHeader() async {
    requestHeaders = await HTTPService().authImgHeader();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    return Scaffold(
      // appBar: AppBar(title: Text("Home")),
      body: SafeArea(
        child: Column(
          children: [
            Stack(alignment: FractionalOffset.centerRight, children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  onChanged: (value) {
                    context
                        .read<HomeBloc>()
                        .add(SearchConversationEvent(value));
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingScreen(),
                      ));
                  // showDialog(
                  //   context: context,
                  //   builder: (context) {
                  //     return Dialog(
                  //         child: Container(
                  //       height: 250,
                  //       padding: EdgeInsets.all(20),
                  //       child: Expanded(
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             ListTile(
                  //               leading: SizedBox(
                  //                 height: 40,
                  //                 width: 40,
                  //                 child: ClipRRect(
                  //                   borderRadius: BorderRadius.circular(100),
                  //                   child: Builder(builder: (context) {
                  //                     return FutureBuilder(
                  //                         future: ConversationService()
                  //                             .getConversationAvatar(
                  //                                 '',
                  //                                 user.username.toString(),
                  //                                 '',
                  //                                 64),
                  //                         builder: (context, snapshot) {
                  //                           if (snapshot.hasData) {
                  //                             return snapshot.data ??
                  //                                 Icon(Icons.person);
                  //                           } else {
                  //                             return Icon(Icons.person);
                  //                           }
                  //                         });
                  //                   }),
                  //                 ),
                  //               ),
                  //               title: Text(user.username.toString()),
                  //             ),
                  //             ListTile(
                  //               leading: Icon(Icons.settings),
                  //               title: Text('Cài đặt'),
                  //             ),
                  //             ListTile(
                  //               onTap: () {
                  //                 context
                  //                     .read<AuthenticationBloc>()
                  //                     .add(AuthenticationLogoutRequested());
                  //               },
                  //               leading: Icon(Icons.logout),
                  //               title: Text('Đăng xuất'),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ));
                  //   },
                  // );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 30),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: FutureBuilder(
                        future: ConversationService().getConversationAvatar(
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
            ]),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.searchList != current.searchList,
              builder: (context, state) {
                if (state.searchList != null &&
                    state.searchList!.isNotEmpty &&
                    requestHeaders != null) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.searchList!.length,
                      itemBuilder: (context, index) => ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              ChatProvider.route(
                                  state.searchList![index].token!,
                                  state.searchList![index].lastMessage!.id!));
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Builder(builder: (context) {
                              if (state.searchList![index].type == 2) {
                                return Container(
                                    color: const Color.fromARGB(
                                        255, 236, 236, 236),
                                    child: Icon(Icons.group));
                              } else {
                                return CachedNetworkImage(
                                  imageUrl:
                                      'http://${host}:8080/ocs/v2.php/apps/spreed/api/v1/room/${state.searchList![index].token!}/avatar',
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) {
                                    return FutureBuilder(
                                        future: ConversationService()
                                            .getConversationAvatar(
                                                state.searchList![index].token!,
                                                state.searchList![index].name!,
                                                state.searchList![index]
                                                    .lastMessage!.actorType!,
                                                64),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return snapshot.data ??
                                                Icon(Icons.person);
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        });
                                  },
                                  httpHeaders: requestHeaders,
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
                        title: Text(
                            state.searchList![index].displayName.toString()),
                        trailing: Builder(
                          builder: (context) {
                            if (state.searchList![index].lastMessage!.timestamp!
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
                            } else if (state
                                    .searchList![index].lastMessage!.timestamp!
                                    .toLocal()
                                    .day ==
                                DateTime.now().subtract(Duration(days: 1))) {
                              return Text(
                                'Hôm qua',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(0.7)),
                              );
                            } else if (state
                                    .searchList![index].lastMessage!.timestamp!
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
                        subtitle: (state
                                    .searchList![index].lastMessage!.actorId ==
                                user.username)
                            ? Text(
                                "Bạn: " +
                                    state
                                        .searchList![index].lastMessage!.message
                                        .toString(),
                                maxLines: 1,
                              )
                            : Text(
                                state.searchList![index].lastMessage!.message
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Utils().showToast('message');

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateConversation(),
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
