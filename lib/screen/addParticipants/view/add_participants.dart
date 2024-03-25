import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/models/list_user.dart';
import 'package:nextcloud_chat_app/screen/addParticipants/bloc/add_participants_bloc.dart';
import 'package:nextcloud_chat_app/screen/chat/view/chat.dart';

import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/participants_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';

class AddParticipant extends StatefulWidget {
  const AddParticipant({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  State<AddParticipant> createState() => _AddParticipantState(token: token);
}

class _AddParticipantState extends State<AddParticipant> {
  Map<String, String> requestHeaders = {};
  final String token;

  bool isSearching = false;

  List<UserConversation> selectedUser = [];

  _AddParticipantState({required this.token});

  @override
  void initState() {
    _imageHeader();
    // TODO: implement initState
    context.read<AddParticipantsBloc>().add(ChangedQueryEvent('', token));
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
                (selectedUser.length > 0)
                    ? IconButton(
                        onPressed: () async {
                          for (var e in selectedUser) {
                            ParticipantsService().postListParticipants(token,
                                {"newParticipant": e.id, "source": "users"});
                          }
                          Navigator.pop(context);
                          // if (selectedUser.length == 1) {
                          //   final conversation =
                          //       await ConversationService().creatConversation({
                          //     'invite': selectedUser[0].id,
                          //     'roomType': '1',
                          //   });
                          //   if (conversation.token != null &&
                          //       conversation.lastMessage != null) {
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => ChatProvider(
                          //               token: conversation.token!,
                          //               messageId:
                          //                   conversation.lastMessage!.id!)),
                          //     );
                          //   }
                          // } else {
                          //   TextEditingController controller =
                          //       TextEditingController();
                          //   showDialog(
                          //     context: context,
                          //     builder: (context) => AlertDialog(
                          //       title: Text('Create conversation'),
                          //       content: TextField(
                          //         controller: controller,
                          //         decoration: InputDecoration(
                          //           hintText: 'Conversation name',
                          //           border: OutlineInputBorder(),
                          //         ),
                          //       ),
                          //       actions: [
                          //         TextButton(
                          //           child: const Text('Cancel'),
                          //           onPressed: () {
                          //             Navigator.of(context).pop();
                          //           },
                          //         ),
                          //         TextButton(
                          //           child: const Text('Create'),
                          //           onPressed: () async {
                          //             final conversation =
                          //                 await ConversationService()
                          //                     .creatConversation({
                          //               // 'invite': selectedUser
                          //               //     .map((e) => e.id)
                          //               //     .toList(),
                          //               'roomName': controller.text,
                          //               'roomType': '2',
                          //             });
                          //             print(conversation.token.toString());
                          //             if (conversation.token != null) {
                          //               print("add user");

                          //               for (var e in selectedUser) {
                          //                 ParticipantsService()
                          //                     .postListParticipants(
                          //                         conversation.token!, {
                          //                   "newParticipant": e.id,
                          //                   "source": "users"
                          //                 });
                          //               }
                          //               // Navigator.pushReplacement(
                          //               //   context,
                          //               //   MaterialPageRoute(
                          //               //       builder: (context) =>
                          //               //           ChatProvider(
                          //               //               token:
                          //               //                   conversation.token!,
                          //               //               messageId: conversation
                          //               //                   .lastMessage!.id!)),
                          //               // );
                          //             }
                          //             Navigator.pop(context);
                          //           },
                          //         ),
                          //       ],
                          //     ),
                          //   );
                          // }
                        },
                        icon: Icon(
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
                        .read<AddParticipantsBloc>()
                        .add(ChangedQueryEvent('', token));
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
                        .read<AddParticipantsBloc>()
                        .add(ChangedQueryEvent(value, token));
                  });
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      context
                          .read<AddParticipantsBloc>()
                          .add(ChangedQueryEvent('', token));
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                ),
                (selectedUser.length > 0)
                    ? IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.check,
                          color: Colors.black,
                        ))
                    : Container(),
              ],
            ),
      body: BlocBuilder<AddParticipantsBloc, AddParticipantsState>(
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
                                'http://${host}:8080/avatar/${state.users![index].id}/64',
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              return Icon(Icons.error);
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
                          ? Icon(Icons.check)
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
                        //   BlocProvider.of<AddParticipantBloc>(context)
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
