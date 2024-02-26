import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:nextcloud_chat_app/screen/chat/widgets/voice_message_player.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';
import 'package:voice_message_package/voice_message_package.dart';

Widget MessageWidget(
    Chat chat,
    User user,
    BuildContext context,
    String token,
    int index,
    Map<String, String> requestHeaders,
    int type,
    bool isFirstMess,
    bool isLastMess) {
  return Builder(
    builder: (context) {
      if (chat.systemMessage == '') {
        return ChatMessageWidget(chat, user, context, token, index,
            requestHeaders, type, isFirstMess, isLastMess);
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
    bool isLastMess) {
  return Builder(
    builder: (context) {
      if (chat.messageParameters is Map &&
          chat.messageParameters.containsKey('file')) {
        return FileChatWidget(chat, user, context, token, index, requestHeaders,
            type, isFirstMess, isLastMess);
      } else {
        return TextChatWidget(chat, user, context, token, index, requestHeaders,
            type, isFirstMess, isLastMess);
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
    bool isLastMess) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorId.toString(),
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
                        FutureBuilder(
                            future: ConversationService().getConversationAvatar(
                                token, chat.actorId!, '', 64),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data ?? Container();
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ChatService().reactMessage(
                                      token,
                                      chat.id.toString(),
                                      {"reaction": '\u2764\ufe0f'});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '\u2764\ufe0f',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '\ud83d\udc4d',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '\ud83d\udc4e',
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '\ud83d\ude03',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '\ud83d\ude22',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '\ud83d\ude2f',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () {
                                _emojiReactOpen = !_emojiReactOpen;
                              },
                              icon: Icon(Icons.more_horiz))
                        ],
                      ),
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
                      ),
                      ListTile(
                        leading: Icon(Icons.forward),
                        title: Text('Chuyển tiếp'),
                      ),
                      ListTile(
                        leading: Icon(Icons.copy),
                        title: Text('Sao chép'),
                      ),
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
                            color: Colors.green.withOpacity(0.2),
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
                              return CachedNetworkImage(
                                imageUrl:
                                    'http://${host}:8080/core/preview?x=-1&y=480&a=1&fileId=${chat.messageParameters['file']['id']}',
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) {
                                  return Icon(Icons.error);
                                },
                                httpHeaders: requestHeaders,
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
              //     (chat
              //                     .reactions !=
              //                 {} &&
              //             state
              //                 .listChat![
              //                     reversedIndex]
              //                 .reactions!
              //                 .isNotEmpty)
              //         ? Positioned(
              //             bottom: 0,
              //             left: 20,
              //             child: Container(
              //               decoration: BoxDecoration(
              //                   color:
              //                       (Color.fromARGB(
              //                           90,
              //                           162,
              //                           155,
              //                           155)),
              //                   borderRadius:
              //                       BorderRadius
              //                           .circular(
              //                               20)),
              //               padding:
              //                   EdgeInsets.symmetric(
              //                       horizontal: 3,
              //                       vertical: 2),
              //               child: Row(
              //                 mainAxisAlignment:
              //                     MainAxisAlignment
              //                         .start,
              //                 mainAxisSize:
              //                     MainAxisSize.min,
              //                 children: state
              //                     .listChat![
              //                         reversedIndex]
              //                     .reactions!
              //                     .entries
              //                     .map((entries) {
              //                   return Container(
              //                     margin:
              //                         EdgeInsets.only(
              //                             right: 5),
              //                     padding: EdgeInsets
              //                         .symmetric(
              //                             horizontal:
              //                                 3,
              //                             vertical:
              //                                 2),
              //                     // decoration: BoxDecoration(
              //                     //     color: Colors
              //                     //         .amber,
              //                     //     borderRadius:
              //                     //         BorderRadius
              //                     //             .circular(
              //                     //                 20)),
              //                     child: Row(
              //                         mainAxisSize:
              //                             MainAxisSize
              //                                 .min,
              //                         children: [
              //                           Text(entries
              //                                   .key +
              //                               " "),
              //                           Text(entries
              //                               .value
              //                               .toString())
              //                         ]),
              //                   );
              //                 }).toList(),
              //               ),
              //             ),
              //           )
              //         : Container(),
              //   ],
              // ),
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
    bool isLastMess) {
  print(isFirstMess);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorId.toString(),
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
                        FutureBuilder(
                            future: ConversationService().getConversationAvatar(
                                token, chat.actorId!, '', 64),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data ?? Container();
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
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
                  children: [
                    ListTile(
                      leading: Icon(Icons.reply),
                      title: Text('Trả lời'),
                    ),
                    ListTile(
                      leading: Icon(Icons.forward),
                      title: Text('Chuyển tiếp'),
                    ),
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
                        child: Text(
                          chat.message.toString(),
                          style: TextStyle(fontSize: 30),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: (chat.actorId == user.username)
                              ? BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
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
                              Text(
                            chat.message.toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                          //     (chat
                          //                 .reactions !=
                          //             {})
                          //         ? Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment
                          //                     .start,
                          //             mainAxisSize:
                          //                 MainAxisSize.min,
                          //             children: state
                          //                 .listChat![
                          //                     reversedIndex]
                          //                 .reactions!
                          //                 .entries
                          //                 .map((entries) {
                          //               return Container(
                          //                 // decoration: BoxDecoration(
                          //                 //     color:
                          //                 //         Colors.amber,
                          //                 //     borderRadius:
                          //                 //         BorderRadius
                          //                 //             .circular(
                          //                 //                 20)),
                          //                 child: Row(
                          //                     mainAxisSize:
                          //                         MainAxisSize
                          //                             .min,
                          //                     children: [
                          //                       Text(entries
                          //                           .key),
                          //                       Text(entries
                          //                           .value
                          //                           .toString())
                          //                     ]),
                          //               );
                          //             }).toList(),
                          //           )
                          //         : Container(),
                          //   ],
                          // ),
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
