import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/models/list_user.dart';
import 'package:nextcloud_chat_app/screen/chat/view/chat.dart';
import 'package:nextcloud_chat_app/screen/createConversation/bloc/create_conversation_bloc.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/participants_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';

class CreateConversation extends StatefulWidget {
  const CreateConversation({Key? key}) : super(key: key);

  @override
  State<CreateConversation> createState() => _CreateConversationState();
}

class _CreateConversationState extends State<CreateConversation> {
  Map<String, String> requestHeaders = {};

  bool isSearching = false;

  List<UserConversation> selectedUser = [];

  @override
  void initState() {
    _imageHeader();
    // TODO: implement initState
    context.read<CreateConversationBloc>().add(const ChangedQueryEvent(''));
  }

  _imageHeader() async {
    requestHeaders = await HTTPService().authImgHeader();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);

    return Scaffold(
      appBar: (!isSearching)
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              title: const Text(
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
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
                (selectedUser.isNotEmpty)
                    ? IconButton(
                        onPressed: () async {
                          if (selectedUser.length == 1) {
                            final conversation =
                                await ConversationService().creatConversation({
                              'invite': selectedUser[0].id,
                              'roomType': '1',
                            });
                            if (conversation.token != null &&
                                conversation.lastMessage != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatProvider(
                                        token: conversation.token!,
                                        messageId:
                                            conversation.lastMessage!.id!, conversations: conversation, user: user,)),
                              );
                            }
                          } else {
                            TextEditingController controller =
                                TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Create conversation'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    hintText: 'Conversation name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Create'),
                                    onPressed: () async {
                                      final conversation =
                                          await ConversationService()
                                              .creatConversation({
                                        // 'invite': selectedUser
                                        //     .map((e) => e.id)
                                        //     .toList(),
                                        'roomName': controller.text,
                                        'roomType': '2',
                                      });
                                      print(conversation.token.toString());
                                      if (conversation.token != null) {
                                        print("add user");

                                        for (var e in selectedUser) {
                                          ParticipantsService()
                                              .postListParticipants(
                                                  conversation.token!, {
                                            "newParticipant": e.id,
                                            "source": "users"
                                          });
                                        }
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //       builder: (context) =>
                                        //           ChatProvider(
                                        //               token:
                                        //                   conversation.token!,
                                        //               messageId: conversation
                                        //                   .lastMessage!.id!)),
                                        // );
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.check,
                          color: Colors.black,
                        ))
                    : Container(),
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
                        .add(const ChangedQueryEvent(''));
                  });
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              title: TextField(
                decoration: const InputDecoration.collapsed(hintText: 'Tìm kiếm'),
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
                          .add(const ChangedQueryEvent(''));
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                ),
                (selectedUser.isNotEmpty)
                    ? IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.check,
                          color: Colors.black,
                        ))
                    : Container(),
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
                      leading: SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl:
                                'http://$host:8080/avatar/${state.users![index].id}/64',
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              return const Icon(Icons.error);
                            },
                            httpHeaders: requestHeaders,
                          ),
                        ),
                      ),
                      title: Text(state.users![index].label.toString()),
                      subtitle:
                          Text(state.users![index].shareWithDisplayNameUnique!),
                      trailing: (selectedUser
                              .map((e) => e.id)
                              .toList()
                              .contains(state.users![index].id))
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () async {
                        setState(() {
                          if (selectedUser
                              .map((e) => e.id)
                              .toList()
                              .contains(state.users![index].id)) {
                            selectedUser.removeWhere((element) =>
                                element.id == state.users![index].id);
                          } else {
                            selectedUser.add(state.users![index]);
                          }
                        });

                        // final conversation =
                        //     await ConversationService().creatConversation({
                        //   'invite': state.users![index].userConversation.id,
                        //   'roomType': '1',
                        // });

                        // if (conversation.token != null &&
                        //     conversation.lastMessage != null) {
                        //   Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => ChatProvider(
                        //             token: conversation.token!,
                        //             messageId: conversation.lastMessage!.id!)),
                        //   );
                        //   // Navigator.pushAndRemoveUntil(
                        //   //     context,
                        //   //     MaterialPageRoute(
                        //   //         builder: (context) => ChatProvider(
                        //   //             token: conversation.token!,
                        //   //             messageId:
                        //   //                 conversation.lastMessage!.id!)),
                        //   //     (route) => true);
                        // }
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
