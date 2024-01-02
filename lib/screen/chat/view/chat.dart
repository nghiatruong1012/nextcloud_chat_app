import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/screen/chat/bloc/chat_bloc.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';

class ChatProvider extends StatelessWidget {
  const ChatProvider({super.key, required this.token, required this.messageId});
  static Route route(String token, int messageId) {
    return MaterialPageRoute<void>(
        builder: (_) => ChatProvider(
              token: token,
              messageId: messageId,
            ));
  }

  final String token;
  final int messageId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(),
      child: ChatPage(
        token: token,
        messageId: messageId,
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  ChatPage({super.key, required this.token, required this.messageId});

  final String token;
  final int messageId;

  @override
  State<ChatPage> createState() =>
      _ChatPageState(token: token, messageId: messageId);
}

class _ChatPageState extends State<ChatPage> {
  final String token;
  final int messageId;
  late Timer _timer;

  _ChatPageState({required this.token, required this.messageId});
  TextEditingController messController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    context.read<ChatBloc>().add(LoadInitialChat(token, messageId));
    context.read<ChatBloc>().add(ReceiveMessage());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.conversations != null && state.listChat != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              bottomOpacity: 0.0,
              elevation: 0.0,
              leading: Container(
                margin: EdgeInsets.all(0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: FutureBuilder(
                            future: ConversationService().getConversationAvatar(
                                token,
                                state.conversations!.name!,
                                state.conversations!.lastMessage!.actorType!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data ?? Container();
                              } else {
                                return Container();
                              }
                            })),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    state.conversations!.displayName.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.normal),
                  )
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.phone,
                      color: Colors.black,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.videocam,
                      color: Colors.black,
                    )),
                PopupMenuButton(
                  color: Colors.black,
                  itemBuilder: (context) => [],
                ),
              ],
            ),
            body: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                      reverse: true,
                      itemCount: state.listChat!.length,
                      itemBuilder: (context, index) {
                        int itemCount = state?.listChat?.length ?? 0;
                        int reversedIndex = itemCount - 1 - index;
                        return (state.listChat![reversedIndex].systemMessage !=
                                "")
                            ? Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                    '${state.listChat![reversedIndex].message} '),
                              )
                            : Container(
                                alignment:
                                    (state.listChat![reversedIndex].actorId ==
                                            user.username)
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: 300),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: (state.listChat![reversedIndex]
                                              .actorId ==
                                          user.username)
                                      ? BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                            topLeft: Radius.circular(15),
                                          ),
                                        )
                                      : BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          )),
                                  child: Text(
                                    state.listChat![reversedIndex].message
                                        .toString(),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                      }),
                ),
                Container(
                  // height: 50,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border(
                    //     top: BorderSide(
                    //         color: Colors.black.withOpacity(0.2), width: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.attach_file)),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.emoji_emotions_outlined)),
                      Flexible(
                        child: Container(
                          child: TextFormField(
                            enabled:
                                (state.conversations!.lastMessage!.actorType !=
                                    "bots"),
                            controller: messController,
                            maxLines: 5,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                hintText: "Enter a message ...",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            print('object');
                            if (messController.text.isNotEmpty) {
                              context.read<ChatBloc>().add(SendMessage(
                                  messController.text,
                                  user.username.toString()));
                            }
                            messController.clear();

                            // Unfocus the current focus node to close the keyboard
                            FocusScope.of(context).unfocus();
                          },
                          icon: Icon(Icons.send)),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return Scaffold();
        }
      },
    );
  }
}
