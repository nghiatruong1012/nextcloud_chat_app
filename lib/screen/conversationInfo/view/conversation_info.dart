import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nextcloud_chat_app/models/conversations.dart';
import 'package:nextcloud_chat_app/models/participants.dart';
import 'package:nextcloud_chat_app/screen/addParticipants/view/add_participants.dart';
import 'package:nextcloud_chat_app/screen/sharedItem/view/shared_item.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/participants_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';

const participantType = [
  'Owner',
  'Moderator',
  'User',
  'Guest',
  'User following a public link',
  'Guest with moderator permissions',
];

class ConversationInfo extends StatefulWidget {
  const ConversationInfo(
      {super.key, required this.conversations, required this.listParticipant});
  final Conversations conversations;
  final List<Participant> listParticipant;
  @override
  State<ConversationInfo> createState() => _ConversationInfoState(
      conversations: conversations, listParticipant: listParticipant);
}

class _ConversationInfoState extends State<ConversationInfo> {
  Conversations conversations;
  Future<Map<String, String>> futureRequestHeaders =
      HTTPService().authImgHeader();
  final List<Participant> listParticipant;

  _ConversationInfoState(
      {required this.conversations, required this.listParticipant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          'Conversation info',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 50,
          ),
          Center(
            child: Container(
              width: 150,
              height: 150,
              padding: EdgeInsets.all(0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: FutureBuilder(
                    future: futureRequestHeaders,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (conversations.type == 1) {
                          return CachedNetworkImage(
                            imageUrl:
                                'http://${host}:8080/ocs/v2.php/apps/spreed/api/v1/room/${conversations.token!}/avatar',
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              return Container();
                            },
                            httpHeaders: snapshot.data,
                          );
                        } else if (conversations.type == 6) {
                          return Container(
                              color: Color(0xFF0082c9),
                              child: Center(child: Text('📝')));
                        } else {
                          return SvgPicture.network(
                            'http://${host}:8080//ocs/v2.php/apps/spreed/api/v1/room/${conversations.token!}/avatar',
                            headers: snapshot.data,
                          );
                        }
                      } else {
                        return Container();
                      }
                    },
                  )

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
              // ClipRRect(
              //     borderRadius: BorderRadius.circular(100),
              //     child: FutureBuilder(
              //         future: ConversationService().getConversationAvatar(
              //             conversations.token!,
              //             conversations!.name!,
              //             conversations!.lastMessage!.actorType!,
              //             128),
              //         builder: (context, snapshot) {
              //           if (snapshot.hasData) {
              //             return snapshot.data ?? Container();
              //           } else {
              //             return Container();
              //           }
              //         })),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                conversations.displayName!,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              'Cài đặt thông báo',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0082c9)),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: DropdownButtonFormField2(
              value: conversations.notificationLevel,
              items: [
                DropdownMenuItem(
                  child: Text('Always notify'),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text('Notify on mention'),
                  value: 2,
                ),
                DropdownMenuItem(
                  child: Text('Never notify'),
                  value: 3,
                ),
              ],
              onChanged: (value) {
                ConversationService().setNotificationLevel(
                    conversations.token!, {'level': value.toString()});
                setState(() async {
                  conversations = await ParticipantsService()
                      .joinConversation(conversations.token!);
                });
              },
              decoration: InputDecoration(
                labelText: 'Thông điệp',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
          ),
          SwitchListTile(
            title: Text('Call notifications'),
            value: conversations.notificationCalls == 1,
            onChanged: (value) {
              ConversationService().setCallNotificationLevel(
                  conversations.token!, {'level': value ? '1' : '0'});
              setState(() async {
                conversations = await ParticipantsService()
                    .joinConversation(conversations.token!);
              });
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              'Shared items',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0082c9)),
            ),
          ),
          ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SharedItem(
                        token: conversations.token!,
                        name: conversations.displayName!,
                      ),
                    ));
              },
              title: Text('Images, files, voice messages ...'),
              leading: Icon(
                Icons.folder_copy_outlined,
              )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              'Người tham gia',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0082c9)),
            ),
          ),
          (conversations.type == 2 && conversations.participantType! <= 2)
              ? ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddParticipant(token: conversations.token!),
                        ));
                  },
                  title: Text('Add participant'),
                  leading: Icon(
                    Icons.person_add_alt_outlined,
                  ))
              : Container(),
          Column(
            children: listParticipant
                .map((e) => ListTile(
                      onTap: () {
                        if (conversations.type == 2 &&
                            conversations.participantType! <= 2) {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    e.displayName.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (e.participantType == 3 ||
                                        e.participantType == 4) {
                                      return ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Promote to moderator'),
                                        onTap: () {
                                          ParticipantsService()
                                              .promoteModerator(
                                                  conversations.token!,
                                                  {"attendeeId": e.actorId});
                                        },
                                      );
                                    } else if (e.participantType == 1) {
                                      return ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Demote to moderator'),
                                        onTap: () {
                                          ParticipantsService().deleteModerator(
                                              conversations.token!,
                                              {"attendeeId": e.actorId});
                                        },
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Remove participant'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      leading: Container(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.all(0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: FutureBuilder(
                                future: ConversationService()
                                    .getConversationAvatar(
                                        conversations.token!,
                                        e.actorId!,
                                        conversations!.lastMessage!.actorType!,
                                        64),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data ?? Container();
                                  } else {
                                    return Container();
                                  }
                                })),
                      ),
                      title: Text(e.displayName.toString() +
                          " (${participantType[e.participantType!]})"),
                    ))
                .toList(),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              'Danger Zone',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 178, 39, 29)),
            ),
          ),
          conversations.canLeaveConversation!
              ? ListTile(
                  onTap: () {
                    ParticipantsService()
                        .deleteConversation(conversations.token!);
                  },
                  title: Text(
                    'Rời khỏi cuộc đàm thoại',
                    style: TextStyle(color: Color.fromARGB(255, 178, 39, 29)),
                  ),
                  leading: Icon(
                    Icons.logout,
                    color: Color.fromARGB(255, 178, 39, 29),
                  ))
              : Container(),
          conversations.canDeleteConversation!
              ? ListTile(
                  title: Text(
                    'Xóa đàm thoại',
                    style: TextStyle(color: Color.fromARGB(255, 178, 39, 29)),
                  ),
                  leading: Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 178, 39, 29),
                  ))
              : Container(),
        ]),
      ),
    );
  }
}
