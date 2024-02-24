import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/screen/chat/view/chat.dart';
import 'package:nextcloud_chat_app/screen/createConversation/bloc/create_conversation_bloc.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';

class CreateConversation extends StatefulWidget {
  const CreateConversation({Key? key}) : super(key: key);

  @override
  State<CreateConversation> createState() => _CreateConversationState();
}

class _CreateConversationState extends State<CreateConversation> {
  Map<String, String> requestHeaders = {};

  bool isSearching = false;

  @override
  void initState() {
    _imageHeader();
    // TODO: implement initState
    context.read<CreateConversationBloc>().add(ChangedQueryEvent(''));
  }

  _imageHeader() async {
    requestHeaders = await HTTPService().authImgHeader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!isSearching)
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Nextcloud Talk',
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    context
                        .read<CreateConversationBloc>()
                        .add(ChangedQueryEvent(''));
                  });
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              title: TextField(
                decoration: new InputDecoration.collapsed(hintText: 'Tìm kiếm'),
                onChanged: (value) {
                  setState(() {
                    context
                        .read<CreateConversationBloc>()
                        .add(ChangedQueryEvent(value));
                  });
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      context
                          .read<CreateConversationBloc>()
                          .add(ChangedQueryEvent(''));
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
      body: BlocBuilder<CreateConversationBloc, CreateConversationState>(
        builder: (context, state) {
          if (state.users != null && requestHeaders != {}) {
            return Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.users!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl:
                                'http://${host}:8080/avatar/${state.users![index].userConversation.id}/64',
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              return Icon(Icons.error);
                            },
                            httpHeaders: requestHeaders,
                          ),
                        ),
                      ),
                      title: Text(state.users![index].userConversation.label
                          .toString()),
                      subtitle: Text(state.users![index].userConversation
                          .shareWithDisplayNameUnique!),
                      trailing: (state.users![index].isSelected)
                          ? Icon(Icons.check)
                          : null,
                      onTap: () async {
                        final conversation =
                            await ConversationService().creatConversation({
                          'invite': state.users![index].userConversation.id,
                          'roomType': '1',
                        });

                        if (conversation.token != null &&
                            conversation.lastMessage != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatProvider(
                                    token: conversation.token!,
                                    messageId: conversation.lastMessage!.id!)),
                          );
                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ChatProvider(
                          //             token: conversation.token!,
                          //             messageId:
                          //                 conversation.lastMessage!.id!)),
                          //     (route) => true);
                        }
                        // setState(() {
                        //   BlocProvider.of<CreateConversationBloc>(context)
                        //       .add(SelectUserEvent(index));
                        // });
                      },
                    );
                  },
                ),
              ),
              // (isSearching)
              //     ? Container(
              //         child: Center(
              //           child: CircularProgressIndicator(),
              //         ),
              //       )
              //     : Container(),
            ]);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
