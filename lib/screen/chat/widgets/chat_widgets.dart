import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:nextcloud_chat_app/screen/chat/widgets/voice_message_player.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/encrypt.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';
import 'package:voice_message_package/voice_message_package.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

Widget MessageWidget(
  Chat chat,
  User user,
  BuildContext context,
  String token,
  int index,
  Map<String, String> requestHeaders,
  int type,
  bool isFirstMess,
  bool isLastMess,
  void pickChat(Chat chat),
) {
  return Builder(
    builder: (context) {
      if (chat.systemMessage == '') {
        return Column(
          children: [
            ChatMessageWidget(chat, user, context, token, index, requestHeaders,
                type, isFirstMess, isLastMess, pickChat),
          ],
        );
      } else {
        return SystemMessageWiget(chat);
      }
    },
  );
}

Widget SystemMessageWiget(Chat chat) {
  final String systemMess = chat.systemMessage!;

  if (systemMess == 'reaction') {
    return Container();
  } else {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text('${chat.message}'),
    );
  }
}

Widget ChatMessageWidget(
    Chat chat,
    User user,
    BuildContext context,
    String token,
    int index,
    Map<String, String> requestHeaders,
    int type,
    bool isFirstMess,
    bool isLastMess,
    void pickChat(Chat chat)) {
  return Builder(
    builder: (context) {
      if (chat.messageParameters is Map &&
          chat.messageParameters.containsKey('file')) {
        return FileChatWidget(chat, user, context, token, index, requestHeaders,
            type, isFirstMess, isLastMess, pickChat);
      } else if (chat.messageParameters is Map &&
          chat.messageParameters.containsKey('object')) {
        return ObjectChatWidget(chat, user, context, token, index,
            requestHeaders, type, isFirstMess, isLastMess, pickChat);
      } else {
        return TextChatWidget(chat, user, context, token, index, requestHeaders,
            type, isFirstMess, isLastMess, pickChat);
      }
    },
  );
}

Widget FileChatWidget(
    Chat chat,
    User user,
    BuildContext context,
    String token,
    int index,
    Map<String, String> requestHeaders,
    int type,
    bool isFirstMess,
    bool isLastMess,
    void pickChat(Chat chat)) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorDisplayName.toString(),
                style: TextStyle(fontSize: 12),
              ))
          : Container(),
      Row(
        mainAxisAlignment: (chat.actorId == user.username)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (chat.actorId != user.username && isFirstMess)
              ? Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child:
                        // Builder(builder: (context) {
                        //   return CachedNetworkImage(
                        //     imageUrl:
                        //         'http://${host}:8080/ocs/v2.php/apps/spreed/api/v1/room/${token!}/avatar',
                        //     placeholder: (context, url) =>
                        //         CircularProgressIndicator(),
                        //     errorWidget: (context, url, error) {
                        //       return Icon(Icons.person);
                        //     },
                        //     httpHeaders: requestHeaders,
                        //   );
                        // }),
                        Builder(builder: (context) {
                      if (type == 4) {
                        return SvgPicture.network(
                          'http://${host}:8080//ocs/v2.php/apps/spreed/api/v1/room/${token!}/avatar',
                          headers: requestHeaders,
                        );
                      } else if (type == 6) {
                        return Container(
                            color: Color(0xFF0082c9),
                            child: Center(child: Text('📝')));
                      } else {
                        return CachedNetworkImage(
                          imageUrl:
                              'http://${host}:8080/avatar/${chat.actorId!}/64?v=0',
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            return Container();
                          },
                          httpHeaders: requestHeaders,
                        );
                      }
                    }),
                    // FutureBuilder(
                    //     future: ConversationService().getConversationAvatar(
                    //         token, chat.actorId!, '', 64),
                    //     builder: (context, snapshot) {
                    //       if (snapshot.hasData) {
                    //         return snapshot.data ?? Container();
                    //       } else {
                    //         return CircularProgressIndicator();
                    //       }
                    //     }),
                  ),
                )
              : Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 5),
                ),
          Container(
            alignment: (chat.actorId == user.username)
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                ChatService().downloadAndOpenFile(
                    user.username!,
                    chat.messageParameters['file']['link'],
                    chat.messageParameters['file']['path'],
                    chat.messageParameters['file']['name']);
              },
              onLongPress: () {
                bool _emojiReactOpen = false;
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         GestureDetector(
                      //           onTap: () {
                      //             ChatService().reactMessage(
                      //                 token,
                      //                 chat.id.toString(),
                      //                 {"reaction": '\u2764\ufe0f'});
                      //           },
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             child: Text(
                      //               '\u2764\ufe0f',
                      //               style: TextStyle(fontSize: 24),
                      //             ),
                      //           ),
                      //         ),
                      //         GestureDetector(
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             child: Text(
                      //               '\ud83d\udc4d',
                      //               style: TextStyle(fontSize: 24),
                      //             ),
                      //           ),
                      //         ),
                      //         GestureDetector(
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             child: Text(
                      //               '\ud83d\udc4e',
                      //               style: TextStyle(
                      //                 fontSize: 24,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         GestureDetector(
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             child: Text(
                      //               '\ud83d\ude03',
                      //               style: TextStyle(fontSize: 24),
                      //             ),
                      //           ),
                      //         ),
                      //         GestureDetector(
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             child: Text(
                      //               '\ud83d\ude22',
                      //               style: TextStyle(fontSize: 24),
                      //             ),
                      //           ),
                      //         ),
                      //         GestureDetector(
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             child: Text(
                      //               '\ud83d\ude2f',
                      //               style: TextStyle(fontSize: 24),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     IconButton(
                      //         alignment: Alignment.centerRight,
                      //         onPressed: () {
                      //           _emojiReactOpen = !_emojiReactOpen;
                      //         },
                      //         icon: Icon(Icons.more_horiz))
                      //   ],
                      // ),
                      // Offstage(
                      //   offstage: !_emojiReactOpen,
                      //   child: SizedBox(
                      //     height: 300,
                      //     child: EmojiPicker(
                      //         textEditingController: messController,
                      //         config: Config(
                      //           columns: 7,
                      //           emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      //         )),
                      //   ),
                      // ),
                      ListTile(
                        leading: Icon(Icons.reply),
                        title: Text('Trả lời'),
                        onTap: () {
                          pickChat(chat);
                          Navigator.pop(context);
                        },
                      ),
                      // ListTile(
                      //   leading: Icon(Icons.forward),
                      //   title: Text('Chuyển tiếp'),
                      // ),
                      (!chat.timestamp!.isBefore(DateTime.now()
                                  .subtract(Duration(hours: 5))) &&
                              chat.actorId == user.username)
                          ? ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete message'),
                              onTap: () async {
                                final newChat = await ChatService()
                                    .deleteMessage(token, chat.id.toString());
                                chat = newChat;
                              },
                            )
                          : Container()
                    ],
                  ),
                );
              },
              child:
                  // Stack(
                  //   children: [
                  Row(
                children: [
                  (chat.actorId == user.username)
                      ? Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            DateFormat('HH:mm').format(chat.timestamp!),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                        )
                      : Container(),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    margin: (index == 0)
                        ? EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 10)
                        : EdgeInsets.symmetric(vertical: 2),
                    // padding: EdgeInsets.symmetric(
                    //     horizontal: 20, vertical: 10),
                    decoration: (chat.actorId == user.username)
                        ? BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: isLastMess
                                  ? Radius.circular(20)
                                  : Radius.circular(5),
                              topLeft: Radius.circular(20),
                              topRight: isFirstMess
                                  ? Radius.circular(20)
                                  : Radius.circular(5),
                            ),
                          )
                        : BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              bottomLeft: isLastMess
                                  ? Radius.circular(20)
                                  : Radius.circular(2),
                              bottomRight: Radius.circular(20),
                              topRight: Radius.circular(20),
                              topLeft: isFirstMess
                                  ? Radius.circular(20)
                                  : Radius.circular(2),
                            )),
                    child: (chat.messageParameters['file']
                                    ['preview-available'] ==
                                'yes' &&
                            (chat.messageParameters['file']['mimetype']
                                .toString()
                                .contains('image')))
                        ? Builder(
                            builder: (context) {
                              return FullScreenWidget(
                                disposeLevel: DisposeLevel.High,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'http://${host}:8080/core/preview?x=-1&y=480&a=1&fileId=${chat.messageParameters['file']['id']}',
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) {
                                    return Icon(Icons.error);
                                  },
                                  httpHeaders: requestHeaders,
                                ),
                              );
                            },
                          )
                        : Builder(builder: (context) {
                            if (chat.messageParameters['file']['mimetype']
                                .toString()
                                .contains('audio')) {
                              return AudioPlayerWidget(
                                audioUrl:
                                    'http://$host:8080/remote.php/dav/files/${user.username}/${chat.messageParameters['file']['path']}',
                                header: requestHeaders,
                              );
                            } else
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  child: Builder(
                                    builder: (context) {
                                      String filePath = chat.message.toString();
                                      List<String> parts = filePath.split('.');
                                      if (parts.length > 1) {
                                        switch (parts.last) {
                                          case 'pdf':
                                            return Image.asset(
                                                'assets/pdf.png');
                                            break;

                                          case 'docx':
                                            return Image.asset(
                                                'assets/doc.png');
                                            break;

                                          case 'ppt':
                                            return Image.asset(
                                                'assets/ppt.png');
                                            break;

                                          case 'txt':
                                            return Image.asset(
                                                'assets/txt.png');
                                            break;

                                          case 'zip':
                                            return Image.asset(
                                                'assets/zip.png');

                                            break;
                                          case 'mp4':
                                            return Image.asset(
                                                'assets/mp4.png');

                                            break;
                                          default:
                                            return Image.asset(
                                                'assets/file.png');
                                        }
                                      } else {
                                        return Image.asset('assets/file.png');
                                        // Không có đuôi file
                                      }
                                    },
                                  ),
                                ),
                                title: Text(
                                  chat.message.toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                ),
                                subtitle: Text(formatFileSize(
                                    chat.messageParameters["file"]["size"])),
                              );
                          }),
                  ),
                  (chat.actorId != user.username)
                      ? Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            DateFormat('HH:mm').format(chat.timestamp!),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget TextChatWidget(
    Chat chat,
    User user,
    BuildContext context,
    String token,
    int index,
    Map<String, String> requestHeaders,
    int type,
    bool isFirstMess,
    bool isLastMess,
    void pickChat(Chat chat)) {
  print(isFirstMess);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorDisplayName.toString(),
                style: TextStyle(fontSize: 12),
              ))
          : Container(),
      Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: (chat.actorId == user.username)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (chat.actorId != user.username && isFirstMess)
              ? Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child:
                        // Builder(builder: (context) {
                        //   return CachedNetworkImage(
                        //     imageUrl:
                        //         'http://${host}:8080/ocs/v2.php/apps/spreed/api/v1/room/${token!}/avatar',
                        //     placeholder: (context, url) =>
                        //         CircularProgressIndicator(),
                        //     errorWidget: (context, url, error) {
                        //       return Icon(Icons.person);
                        //     },
                        //     httpHeaders: requestHeaders,
                        //   );
                        // }),
                        Builder(builder: (context) {
                      if (type == 4) {
                        return SvgPicture.network(
                          'http://${host}:8080//ocs/v2.php/apps/spreed/api/v1/room/${token!}/avatar',
                          headers: requestHeaders,
                        );
                      } else if (type == 6) {
                        return Container(
                            color: Color(0xFF0082c9),
                            child: Center(child: Text('📝')));
                      } else {
                        return CachedNetworkImage(
                          imageUrl:
                              'http://${host}:8080/avatar/${chat.actorId!}/64?v=0',
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            return Container();
                          },
                          httpHeaders: requestHeaders,
                        );
                      }
                    }),
                    // FutureBuilder(
                    //     future: ConversationService().getConversationAvatar(
                    //         token, chat.actorId!, '', 64),
                    //     builder: (context, snapshot) {
                    //       if (snapshot.hasData) {
                    //         return snapshot.data ?? Container();
                    //       } else {
                    //         return CircularProgressIndicator();
                    //       }
                    //     }),
                  ),
                )
              : Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 5),
                ),
          Column(
            crossAxisAlignment: (chat.actorId == user.username)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.reply),
                          title: Text('Trả lời'),
                          onTap: () {
                            pickChat(chat);
                            Navigator.pop(context);
                          },
                        ),
                        // ListTile(
                        //   leading: Icon(Icons.forward),
                        //   title: Text('Chuyển tiếp'),
                        // ),
                        ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Sao chép'),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: chat.message!));
                          },
                        ),
                        // (!chat.timestamp!.isBefore(
                        //             DateTime.now().subtract(Duration(hours: 5))) &&
                        //         chat.actorId == user.username)
                        //     ? ListTile(
                        //         leading: Icon(Icons.edit),
                        //         title: Text('Edit message'),
                        //       )
                        //     : Container(),
                        (!chat.timestamp!.isBefore(DateTime.now()
                                    .subtract(Duration(hours: 5))) &&
                                chat.actorId == user.username)
                            ? ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete message'),
                                onTap: () async {
                                  final newChat = await ChatService()
                                      .deleteMessage(token, chat.id.toString());
                                  chat = newChat;
                                },
                              )
                            : Container()
                      ],
                    ),
                  );
                },
                child: Row(
                  children: [
                    (chat.actorId == user.username)
                        ? Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              DateFormat('HH:mm').format(chat.timestamp!),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.7)),
                            ),
                          )
                        : Container(),
                    Builder(
                      builder: (context) {
                        if (containsOnlyEmojis(chat.message.toString())) {
                          return Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            margin: (index == 0)
                                ? EdgeInsets.only(
                                    left: 2, right: 2, top: 2, bottom: 10)
                                : EdgeInsets.symmetric(vertical: 2),
                            // padding:
                            //     EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            child: Column(
                              crossAxisAlignment:
                                  (chat.actorId == user.username)
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                (chat.parent != null)
                                    ? Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                                color: Colors.blue
                                                    .withOpacity(0.5),
                                                width: 2),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: 5, bottom: 3, top: 1),
                                                child: Text(
                                                  chat.parent!.actorDisplayName
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6)),
                                                )),
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: 5, top: 3, bottom: 1),
                                                child: Text(
                                                  chat.parent!.message
                                                      .toString(),
                                                  maxLines: 5,
                                                )),
                                          ],
                                        ))
                                    : Container(
                                        width: 0,
                                      ),
                                Text(
                                  chat.message.toString(),
                                  style: TextStyle(fontSize: 30),
                                ),
                              ],
                            ),
                          );
                        } else if (isUrl(chat.message.toString())) {
                          return Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            margin: (index == 0)
                                ? EdgeInsets.only(
                                    left: 2, right: 2, top: 2, bottom: 10)
                                : EdgeInsets.symmetric(vertical: 2),
                            // padding:
                            //     EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            child: Column(
                              crossAxisAlignment:
                                  (chat.actorId == user.username)
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                (chat.parent != null)
                                    ? Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                                color: Colors.blue
                                                    .withOpacity(0.5),
                                                width: 2),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: 5, bottom: 3, top: 1),
                                                child: Text(
                                                  chat.parent!.actorDisplayName
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6)),
                                                )),
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: 5, top: 3, bottom: 1),
                                                child: Text(
                                                  chat.parent!.message
                                                      .toString(),
                                                  maxLines: 5,
                                                )),
                                          ],
                                        ))
                                    : Container(
                                        width: 0,
                                      ),
                                AnyLinkPreview(link: chat.message.toString())
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            // alignment: (chat.actorId == user.username)
                            //     ? Alignment.centerRight
                            //     : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 300),
                              margin: (index == 0)
                                  ? EdgeInsets.only(
                                      left: 2, right: 2, top: 2, bottom: 10)
                                  : EdgeInsets.symmetric(vertical: 2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: (chat.actorId == user.username)
                                  ? BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: isLastMess
                                            ? Radius.circular(20)
                                            : Radius.circular(5),
                                        topLeft: Radius.circular(20),
                                        topRight: isFirstMess
                                            ? Radius.circular(20)
                                            : Radius.circular(5),
                                      ),
                                    )
                                  : BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: isLastMess
                                            ? Radius.circular(20)
                                            : Radius.circular(2),
                                        bottomRight: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        topLeft: isFirstMess
                                            ? Radius.circular(20)
                                            : Radius.circular(2),
                                      ),
                                    ),
                              child:
                                  // Column(
                                  //   children: [
                                  Column(
                                crossAxisAlignment:
                                    (chat.actorId == user.username)
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  (chat.parent != null)
                                      ? Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.blue
                                                      .withOpacity(0.5),
                                                  width: 2),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(
                                                      left: 5,
                                                      bottom: 3,
                                                      top: 1),
                                                  child: Text(
                                                    chat.parent!
                                                        .actorDisplayName
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black
                                                            .withOpacity(0.6)),
                                                  )),
                                              Container(
                                                  padding: EdgeInsets.only(
                                                      left: 5,
                                                      top: 3,
                                                      bottom: 1),
                                                  child: Text(
                                                    chat.parent!.message
                                                        .toString(),
                                                    maxLines: 5,
                                                  )),
                                            ],
                                          ))
                                      : Container(
                                          width: 0,
                                        ),
                                  Text(
                                    // EncryptionDecryption.decryptMessage(
                                    //     encrypt.Encrypted.fromBase64(
                                    //         chat.message.toString())),
                                    // EncryptionDecryption().decryptMessage(token, chat.message.toString()),
                                    chat.message.toString(),
                                    style: TextStyle(fontSize: 18),
                                    maxLines: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    (chat.actorId != user.username)
                        ? Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              DateFormat('HH:mm').format(chat.timestamp!),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.7)),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              // (chat.reactions != {})
              //     ? Row(
              //         children: chat.reactions!.keys.map((key) {
              //           final value = chat.reactions![
              //               key]; // Accessing value corresponding to the key
              //           return Container(
              //             padding:
              //                 EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              //             margin: EdgeInsets.symmetric(horizontal: 2),
              //             decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(30),
              //               color: Colors.grey.withOpacity(0.2),
              //             ),
              //             child: Text('$key $value'),
              //           );
              //         }).toList(),
              //       )
              //     : Container(),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget ObjectChatWidget(
    Chat chat,
    User user,
    BuildContext context,
    String token,
    int index,
    Map<String, String> requestHeaders,
    int type,
    bool isFirstMess,
    bool isLastMess,
    void pickChat(Chat chat)) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorDisplayName.toString(),
                style: TextStyle(fontSize: 12),
              ))
          : Container(),
      Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: (chat.actorId == user.username)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (chat.actorId != user.username && isFirstMess)
              ? Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child:
                        // Builder(builder: (context) {
                        //   return CachedNetworkImage(
                        //     imageUrl:
                        //         'http://${host}:8080/ocs/v2.php/apps/spreed/api/v1/room/${token!}/avatar',
                        //     placeholder: (context, url) =>
                        //         CircularProgressIndicator(),
                        //     errorWidget: (context, url, error) {
                        //       return Icon(Icons.person);
                        //     },
                        //     httpHeaders: requestHeaders,
                        //   );
                        // }),
                        Builder(builder: (context) {
                      if (type == 4) {
                        return SvgPicture.network(
                          'http://${host}:8080//ocs/v2.php/apps/spreed/api/v1/room/${token!}/avatar',
                          headers: requestHeaders,
                        );
                      } else if (type == 6) {
                        return Container(
                            color: Color(0xFF0082c9),
                            child: Center(child: Text('📝')));
                      } else {
                        return CachedNetworkImage(
                          imageUrl:
                              'http://${host}:8080/avatar/${chat.actorId!}/64?v=0',
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            return Container();
                          },
                          httpHeaders: requestHeaders,
                        );
                      }
                    }),
                    // FutureBuilder(
                    //     future: ConversationService().getConversationAvatar(
                    //         token, chat.actorId!, '', 64),
                    //     builder: (context, snapshot) {
                    //       if (snapshot.hasData) {
                    //         return snapshot.data ?? Container();
                    //       } else {
                    //         return CircularProgressIndicator();
                    //       }
                    //     }),
                  ),
                )
              : Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 5),
                ),
          GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.reply),
                      title: Text('Trả lời'),
                      onTap: () {
                        pickChat(chat);
                        Navigator.pop(context);
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(Icons.forward),
                    //   title: Text('Chuyển tiếp'),
                    // ),
                    ListTile(
                      leading: Icon(Icons.copy),
                      title: Text('Sao chép'),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              children: [
                (chat.actorId == user.username)
                    ? Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Text(
                          DateFormat('HH:mm').format(chat.timestamp!),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      )
                    : Container(),
                (containsOnlyEmojis(chat.message.toString()))
                    ? Container(
                        constraints: BoxConstraints(maxWidth: 300),
                        margin: (index == 0)
                            ? EdgeInsets.only(
                                left: 2, right: 2, top: 2, bottom: 10)
                            : EdgeInsets.symmetric(vertical: 2),
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        child: Column(
                          crossAxisAlignment: (chat.actorId == user.username)
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            (chat.parent != null)
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                            color: Colors.blue.withOpacity(0.5),
                                            width: 2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 5, bottom: 3, top: 1),
                                            child: Text(
                                              chat.parent!.actorDisplayName
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            )),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 5, top: 3, bottom: 1),
                                            child: Text(
                                              chat.parent!.message.toString(),
                                              maxLines: 5,
                                            )),
                                      ],
                                    ))
                                : Container(
                                    width: 0,
                                  ),
                            Text(
                              chat.message.toString(),
                              style: TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        // alignment: (chat.actorId == user.username)
                        //     ? Alignment.centerRight
                        //     : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 300),
                          margin: (index == 0)
                              ? EdgeInsets.only(
                                  left: 2, right: 2, top: 2, bottom: 10)
                              : EdgeInsets.symmetric(vertical: 2),
                          // padding:
                          //     EdgeInsets.symmetric(horizontal: 15, vertical: 8),

                          child:
                              // Column(
                              //   children: [
                              Column(
                            crossAxisAlignment: (chat.actorId == user.username)
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              (chat.parent != null)
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                              color:
                                                  Colors.blue.withOpacity(0.5),
                                              width: 2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 5, bottom: 3, top: 1),
                                              child: Text(
                                                chat.parent!.actorDisplayName
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.6)),
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 5, top: 3, bottom: 1),
                                              child: Text(
                                                chat.parent!.message.toString(),
                                                maxLines: 5,
                                              )),
                                        ],
                                      ))
                                  : Container(
                                      width: 0,
                                    ),
                              AnyLinkPreview(
                                link:
                                    // 'https://maps.google.com?z=19&q=51.03841,-114.01679',
                                    "https://www.google.com/maps/search/?api=1&query=${chat.messageParameters["object"]["latitude"]},${chat.messageParameters["object"]["longitude"]}",
                                // "https://www.openstreetmap.org/?mlat=${chat.messageParameters["object"]["latitude"]}&mlon=${chat.messageParameters["object"]["longitude"]}#map=18/${chat.messageParameters["object"]["latitude"]}/${chat.messageParameters["object"]["longitude"]}",
                                displayDirection:
                                    UIDirection.uiDirectionVertical,
                                showMultimedia: true,
                                errorTitle: chat.message.toString(),
                                errorBody: chat.message.toString(),
                                cache: Duration(hours: 1),
                                backgroundColor: Colors.grey[200],
                                errorWidget: Container(
                                  color: Colors.grey[300],
                                  child: Text('Oops!'),
                                ),
                              ),
                              // Text(
                              //   chat.message.toString(),
                              //   style: TextStyle(fontSize: 18),
                              // ),
                            ],
                          ),
                        ),
                      ),
                (chat.actorId != user.username)
                    ? Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          DateFormat('HH:mm').format(chat.timestamp!),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
