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
  const ChatPage({super.key, required this.token, required this.messageId});

  final String token;
  final int messageId;

  @override
  State<ChatPage> createState() =>
      _ChatPageState(token: token, messageId: messageId);
}

class _ChatPageState extends State<ChatPage> {
  final String token;
  final int messageId;

  _ChatPageState({required this.token, required this.messageId});

  @override
  void initState() {
    // TODO: implement initState
    context.read<ChatBloc>().add(LoadInitialChat(token, messageId));
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
            body: Container(
              child: ListView.builder(
                  itemCount: state.listChat!.length,
                  itemBuilder: (context, index) => (state
                              .listChat![index].systemMessage ==
                          "conversation_created")
                      ? Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                              '${state.listChat![index].actorId} đã tạo đàm thoại'),
                        )
                      : Container(
                          alignment:
                              (state.listChat![index].actorId == user.username)
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                color: (state.listChat![index].actorId ==
                                        user.username)
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(100)),
                            child: Text(
                              state.listChat![index].message.toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        )),
            ),
          );
        } else {
          return Scaffold();
        }
      },
    );
  }
}
