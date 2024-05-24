import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:nextcloud_chat_app/screen/chat/widgets/voice_message_player.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/encrypt.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';

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
    void Function(Chat chat) pickChat,
    String? secretKey,
    int lastReadMessage) {
  return Builder(
    builder: (context) {
      if (chat.systemMessage == '') {
        return Column(
          children: [
            ChatMessageWidget(
                chat,
                user,
                context,
                token,
                index,
                requestHeaders,
                type,
                isFirstMess,
                isLastMess,
                pickChat,
                secretKey,
                lastReadMessage),
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

  if (systemMess == 'reaction' ||
      systemMess == 'reaction_revoked' ||
      systemMess == 'reaction_deleted') {
    return Container();
  } else {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
  void Function(Chat chat) pickChat,
  String? secretKey,
  int lastReadMessage,
) {
  return Builder(
    builder: (context) {
      if (chat.messageParameters is Map &&
          chat.messageParameters.containsKey('file')) {
        return FileChatWidget(chat, user, context, token, index, requestHeaders,
            type, isFirstMess, isLastMess, pickChat, lastReadMessage);
      } else if (chat.messageParameters is Map &&
          chat.messageParameters.containsKey('object')) {
        return ObjectChatWidget(
            chat,
            user,
            context,
            token,
            index,
            requestHeaders,
            type,
            isFirstMess,
            isLastMess,
            pickChat,
            lastReadMessage);
      } else {
        Chat newChat = Chat(
            chat.id,
            chat.actorId,
            chat.actorDisplayName,
            (secretKey != null && secretKey.isNotEmpty)
                ? EncryptionDecryption()
                    .decryptString(chat.message.toString(), secretKey)
                : chat.message.toString(),
            chat.systemMessage,
            chat.timestamp,
            chat.messageParameters,
            chat.reactions,
            chat.parent);

        return TextChatWidget(
            newChat,
            user,
            context,
            token,
            index,
            requestHeaders,
            type,
            isFirstMess,
            isLastMess,
            pickChat,
            secretKey,
            lastReadMessage);
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
  void Function(Chat chat) pickChat,
  int lastReadMessage,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorDisplayName.toString(),
                style: const TextStyle(fontSize: 12),
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
                  margin: const EdgeInsets.only(right: 5),
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
                          'http://$host:8080//ocs/v2.php/apps/spreed/api/v1/room/$token/avatar',
                          headers: requestHeaders,
                        );
                      } else if (type == 6) {
                        return Container(
                            color: const Color(0xFF0082c9),
                            child: const Center(child: Text('📝')));
                      } else {
                        return CachedNetworkImage(
                          imageUrl:
                              'http://$host:8080/avatar/${chat.actorId!}/64?v=0',
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
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
                  margin: const EdgeInsets.only(right: 5),
                ),
          Column(
            crossAxisAlignment: (chat.actorId == user.username)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
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
                    bool emojiReactOpen = false;
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  TextButton(
                                    // padding: EdgeInsets.all(8),

                                    onPressed: () {
                                      ChatService().reactMessage(
                                          token,
                                          chat.id.toString(),
                                          {"reaction": '\u2764\ufe0f'});
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '\u2764\ufe0f',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  TextButton(
                                    // padding: EdgeInsets.all(8),

                                    onPressed: () {
                                      ChatService().reactMessage(
                                          token,
                                          chat.id.toString(),
                                          {"reaction": '\ud83d\udc4d'});
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '\ud83d\udc4d',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  TextButton(
                                    // padding: EdgeInsets.all(8),

                                    onPressed: () {
                                      ChatService().reactMessage(
                                          token,
                                          chat.id.toString(),
                                          {"reaction": '\ud83d\udc4e'});
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '\ud83d\udc4e',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  TextButton(
                                    // padding: EdgeInsets.all(8),

                                    onPressed: () {
                                      ChatService().reactMessage(
                                          token,
                                          chat.id.toString(),
                                          {"reaction": '\ud83d\ude06'});
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '\ud83d\ude06',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  TextButton(
                                    // padding: EdgeInsets.all(8),

                                    onPressed: () {
                                      ChatService().reactMessage(
                                          token,
                                          chat.id.toString(),
                                          {"reaction": '\ud83d\ude22'});
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '\ud83d\ude22',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  TextButton(
                                    // padding: EdgeInsets.all(8),

                                    onPressed: () {
                                      ChatService().reactMessage(
                                          token,
                                          chat.id.toString(),
                                          {"reaction": '\ud83d\ude2f'});
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '\ud83d\ude2f',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),

                                  // GestureDetector(
                                  //   child: Container(
                                  //     padding: EdgeInsets.all(8),
                                  //     child: Text(
                                  //       '\ud83d\udc4d',
                                  //       style: TextStyle(fontSize: 24),
                                  //     ),
                                  //   ),
                                  // ),
                                  // GestureDetector(
                                  //   child: Container(
                                  //     padding: EdgeInsets.all(8),
                                  //     child: Text(
                                  //       '\ud83d\udc4e',
                                  //       style: TextStyle(
                                  //         fontSize: 24,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // GestureDetector(
                                  //   child: Container(
                                  //     padding: EdgeInsets.all(8),
                                  //     child: Text(
                                  //       '\ud83d\ude03',
                                  //       style: TextStyle(fontSize: 24),
                                  //     ),
                                  //   ),
                                  // ),
                                  // GestureDetector(
                                  //   child: Container(
                                  //     padding: EdgeInsets.all(8),
                                  //     child: Text(
                                  //       '\ud83d\ude22',
                                  //       style: TextStyle(fontSize: 24),
                                  //     ),
                                  //   ),
                                  // ),
                                  // GestureDetector(
                                  //   child: Container(
                                  //     padding: EdgeInsets.all(8),
                                  //     child: Text(
                                  //       '\ud83d\ude2f',
                                  //       style: TextStyle(fontSize: 24),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              // IconButton(
                              //     alignment: Alignment.centerRight,
                              //     onPressed: () {
                              //       _emojiReactOpen = !_emojiReactOpen;
                              //     },
                              //     icon: Icon(Icons.more_horiz))
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
                          //           emojiSizeMax:
                          //               32 * (Platform.isIOS ? 1.30 : 1.0),
                          //         )),
                          //   ),
                          // ),
                          ListTile(
                            leading: const Icon(Icons.reply),
                            title: const Text('Trả lời'),
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
                                      .subtract(const Duration(hours: 5))) &&
                                  chat.actorId == user.username)
                              ? ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Delete message'),
                                  onTap: () async {
                                    final newChat = await ChatService()
                                        .deleteMessage(
                                            token, chat.id.toString());
                                    chat = newChat;
                                    Navigator.pop(context);
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
                              margin: const EdgeInsets.only(right: 2),
                              child: Text(
                                DateFormat('HH:mm').format(chat.timestamp!),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(0.7)),
                              ),
                            )
                          : Container(),
                      (chat.actorId == user.username)
                          ? Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Icon(
                                (chat.id! <= lastReadMessage)
                                    ? Icons.done_all
                                    : Icons.done,
                                size: 16,
                              ),
                            )
                          : Container(),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        margin: (index == 0)
                            ? const EdgeInsets.only(
                                left: 2, right: 2, top: 2, bottom: 10)
                            : const EdgeInsets.symmetric(vertical: 2),
                        // padding: EdgeInsets.symmetric(
                        //     horizontal: 20, vertical: 10),
                        decoration: (chat.actorId == user.username)
                            ? BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: const Radius.circular(20),
                                  bottomRight: isLastMess
                                      ? const Radius.circular(20)
                                      : const Radius.circular(5),
                                  topLeft: const Radius.circular(20),
                                  topRight: isFirstMess
                                      ? const Radius.circular(20)
                                      : const Radius.circular(5),
                                ),
                              )
                            : BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: isLastMess
                                      ? const Radius.circular(20)
                                      : const Radius.circular(2),
                                  bottomRight: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  topLeft: isFirstMess
                                      ? const Radius.circular(20)
                                      : const Radius.circular(2),
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
                                          'http://$host:8080/core/preview?x=-1&y=480&a=1&fileId=${chat.messageParameters['file']['id']}',
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) {
                                        return const Icon(Icons.error);
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
                                } else {
                                  return ListTile(
                                    leading: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Builder(
                                        builder: (context) {
                                          String filePath =
                                              chat.message.toString();
                                          List<String> parts =
                                              filePath.split('.');
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
                                            return Image.asset(
                                                'assets/file.png');
                                            // Không có đuôi file
                                          }
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      chat.message.toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                    ),
                                    subtitle: Text(formatFileSize(chat
                                        .messageParameters["file"]["size"])),
                                  );
                                }
                              }),
                      ),
                      (chat.actorId != user.username)
                          ? Container(
                              margin: const EdgeInsets.only(left: 10),
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
              (chat.reactions!.isNotEmpty)
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: chat.reactions!.entries.take(5).map((entry) {
                          String reaction =
                              entry.key; // Lấy key của cặp khóa và giá trị
                          int count =
                              entry.value; // Lấy giá trị tương ứng với key
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2, vertical: 3),
                            // Xây dựng Container dựa trên reaction và count
                            // Ví dụ:
                            child: Text('$reaction $count'),
                            // Hoặc bạn có thể sử dụng các widget khác tùy thuộc vào yêu cầu của bạn
                          );
                        }).toList(),
                      ),
                    )
                  : Container(
                      width: 0,
                    ),
            ],
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
  void Function(Chat chat) pickChat,
  String? secretKey,
  int lastReadMessage,
) {
  print(isFirstMess);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorDisplayName.toString(),
                style: const TextStyle(fontSize: 12),
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
                  margin: const EdgeInsets.only(right: 5),
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
                          'http://$host:8080//ocs/v2.php/apps/spreed/api/v1/room/$token/avatar',
                          headers: requestHeaders,
                        );
                      } else if (type == 6) {
                        return Container(
                            color: const Color(0xFF0082c9),
                            child: const Center(child: Text('📝')));
                      } else {
                        return CachedNetworkImage(
                          imageUrl:
                              'http://$host:8080/avatar/${chat.actorId!}/64?v=0',
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
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
                  margin: const EdgeInsets.only(right: 5),
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
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                TextButton(
                                  // padding: EdgeInsets.all(8),

                                  onPressed: () {
                                    ChatService().reactMessage(
                                        token,
                                        chat.id.toString(),
                                        {"reaction": '\u2764\ufe0f'});
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '\u2764\ufe0f',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                TextButton(
                                  // padding: EdgeInsets.all(8),

                                  onPressed: () {
                                    ChatService().reactMessage(
                                        token,
                                        chat.id.toString(),
                                        {"reaction": '\ud83d\udc4d'});
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '\ud83d\udc4d',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                TextButton(
                                  // padding: EdgeInsets.all(8),

                                  onPressed: () {
                                    ChatService().reactMessage(
                                        token,
                                        chat.id.toString(),
                                        {"reaction": '\ud83d\udc4e'});
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '\ud83d\udc4e',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                TextButton(
                                  // padding: EdgeInsets.all(8),

                                  onPressed: () {
                                    ChatService().reactMessage(
                                        token,
                                        chat.id.toString(),
                                        {"reaction": '\ud83d\ude06'});
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '\ud83d\ude06',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                TextButton(
                                  // padding: EdgeInsets.all(8),

                                  onPressed: () {
                                    ChatService().reactMessage(
                                        token,
                                        chat.id.toString(),
                                        {"reaction": '\ud83d\ude22'});
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '\ud83d\ude22',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                TextButton(
                                  // padding: EdgeInsets.all(8),

                                  onPressed: () {
                                    ChatService().reactMessage(
                                        token,
                                        chat.id.toString(),
                                        {"reaction": '\ud83d\ude2f'});
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '\ud83d\ude2f',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),

                                // GestureDetector(
                                //   child: Container(
                                //     padding: EdgeInsets.all(8),
                                //     child: Text(
                                //       '\ud83d\udc4d',
                                //       style: TextStyle(fontSize: 24),
                                //     ),
                                //   ),
                                // ),
                                // GestureDetector(
                                //   child: Container(
                                //     padding: EdgeInsets.all(8),
                                //     child: Text(
                                //       '\ud83d\udc4e',
                                //       style: TextStyle(
                                //         fontSize: 24,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // GestureDetector(
                                //   child: Container(
                                //     padding: EdgeInsets.all(8),
                                //     child: Text(
                                //       '\ud83d\ude03',
                                //       style: TextStyle(fontSize: 24),
                                //     ),
                                //   ),
                                // ),
                                // GestureDetector(
                                //   child: Container(
                                //     padding: EdgeInsets.all(8),
                                //     child: Text(
                                //       '\ud83d\ude22',
                                //       style: TextStyle(fontSize: 24),
                                //     ),
                                //   ),
                                // ),
                                // GestureDetector(
                                //   child: Container(
                                //     padding: EdgeInsets.all(8),
                                //     child: Text(
                                //       '\ud83d\ude2f',
                                //       style: TextStyle(fontSize: 24),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            // IconButton(
                            //     alignment: Alignment.centerRight,
                            //     onPressed: () {
                            //       _emojiReactOpen = !_emojiReactOpen;
                            //     },
                            //     icon: Icon(Icons.more_horiz))
                          ],
                        ),

                        ListTile(
                          leading: const Icon(Icons.reply),
                          title: const Text('Trả lời'),
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
                          leading: const Icon(Icons.copy),
                          title: const Text('Sao chép'),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: chat.message!));
                            Navigator.pop(context);
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
                                    .subtract(const Duration(hours: 5))) &&
                                chat.actorId == user.username)
                            ? ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete message'),
                                onTap: () async {
                                  final newChat = await ChatService()
                                      .deleteMessage(token, chat.id.toString());
                                  chat = newChat;
                                  Navigator.pop(context);
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
                            margin: const EdgeInsets.only(right: 2),
                            child: Text(
                              DateFormat('HH:mm').format(chat.timestamp!),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.7)),
                            ),
                          )
                        : Container(),
                    (chat.actorId == user.username)
                        ? Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Icon(
                              (chat.id! <= lastReadMessage)
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 16,
                            ),
                          )
                        : Container(),
                    Builder(
                      builder: (context) {
                        if (containsOnlyEmojis(chat.message.toString())) {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 280),
                            margin: (index == 0)
                                ? const EdgeInsets.only(
                                    left: 2, right: 2, top: 2, bottom: 10)
                                : const EdgeInsets.symmetric(vertical: 2),
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
                                                padding: const EdgeInsets.only(
                                                    left: 5, bottom: 3, top: 1),
                                                child: Text(
                                                  chat.parent!.actorDisplayName
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6)),
                                                )),
                                            Container(
                                                padding: const EdgeInsets.only(
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
                                  style: const TextStyle(fontSize: 30),
                                ),
                                (chat.reactions!.isNotEmpty)
                                    ? Container(
                                        margin: EdgeInsets.only(top: 3),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: chat.reactions!.entries
                                              .take(5)
                                              .map((entry) {
                                            String reaction = entry
                                                .key; // Lấy key của cặp khóa và giá trị
                                            int count = entry
                                                .value; // Lấy giá trị tương ứng với key
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 2, vertical: 3),
                                              // Xây dựng Container dựa trên reaction và count
                                              // Ví dụ:
                                              child: Text('$reaction $count'),
                                              // Hoặc bạn có thể sử dụng các widget khác tùy thuộc vào yêu cầu của bạn
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : Container(
                                        width: 0,
                                      ),
                              ],
                            ),
                          );
                        } else if (isUrl(chat.message.toString())) {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 280),
                            margin: (index == 0)
                                ? const EdgeInsets.only(
                                    left: 2, right: 2, top: 2, bottom: 10)
                                : const EdgeInsets.symmetric(vertical: 2),
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
                                                padding: const EdgeInsets.only(
                                                    left: 5, bottom: 3, top: 1),
                                                child: Text(
                                                  chat.parent!.actorDisplayName
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6)),
                                                )),
                                            Container(
                                                padding: const EdgeInsets.only(
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
                                AnyLinkPreview(
                                  link: chat.message.toString(),
                                  // backgroundColor: Colors.g,
                                  boxShadow: [],
                                ),
                                (chat.reactions!.isNotEmpty)
                                    ? Container(
                                        margin: EdgeInsets.only(top: 3),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: chat.reactions!.entries
                                              .take(5)
                                              .map((entry) {
                                            String reaction = entry
                                                .key; // Lấy key của cặp khóa và giá trị
                                            int count = entry
                                                .value; // Lấy giá trị tương ứng với key
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 2, vertical: 3),
                                              // Xây dựng Container dựa trên reaction và count
                                              // Ví dụ:
                                              child: Text('$reaction $count'),
                                              // Hoặc bạn có thể sử dụng các widget khác tùy thuộc vào yêu cầu của bạn
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : Container(
                                        width: 0,
                                      ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            // alignment: (chat.actorId == user.username)
                            //     ? Alignment.centerRight
                            //     : Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 280),
                              margin: (index == 0)
                                  ? const EdgeInsets.only(
                                      left: 2, right: 2, top: 2, bottom: 10)
                                  : const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: (chat.actorId == user.username)
                                  ? BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: const Radius.circular(20),
                                        bottomRight: isLastMess
                                            ? const Radius.circular(20)
                                            : const Radius.circular(5),
                                        topLeft: const Radius.circular(20),
                                        topRight: isFirstMess
                                            ? const Radius.circular(20)
                                            : const Radius.circular(5),
                                      ),
                                    )
                                  : BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: isLastMess
                                            ? const Radius.circular(20)
                                            : const Radius.circular(2),
                                        bottomRight: const Radius.circular(20),
                                        topRight: const Radius.circular(20),
                                        topLeft: isFirstMess
                                            ? const Radius.circular(20)
                                            : const Radius.circular(2),
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                    // chat.message.toString(),
                                    (secretKey != null && secretKey.isNotEmpty)
                                        ? EncryptionDecryption().decryptString(
                                            chat.message.toString(), secretKey)
                                        : chat.message.toString(),
                                    style: const TextStyle(fontSize: 18),
                                    maxLines: 10,
                                  ),
                                  (chat.reactions!.isNotEmpty)
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: chat.reactions!.entries
                                                .take(5)
                                                .map((entry) {
                                              String reaction = entry
                                                  .key; // Lấy key của cặp khóa và giá trị
                                              int count = entry
                                                  .value; // Lấy giá trị tương ứng với key
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2, vertical: 3),
                                                // Xây dựng Container dựa trên reaction và count
                                                // Ví dụ:
                                                child: Text('$reaction $count'),
                                                // Hoặc bạn có thể sử dụng các widget khác tùy thuộc vào yêu cầu của bạn
                                              );
                                            }).toList(),
                                          ),
                                        )
                                      : Container(
                                          width: 0,
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
                            margin: const EdgeInsets.only(left: 10),
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
  void Function(Chat chat) pickChat,
  int lastReadMessage,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      (chat.actorId != user.username && isFirstMess)
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                chat.actorDisplayName.toString(),
                style: const TextStyle(fontSize: 12),
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
                  margin: const EdgeInsets.only(right: 5),
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
                          'http://$host:8080//ocs/v2.php/apps/spreed/api/v1/room/$token/avatar',
                          headers: requestHeaders,
                        );
                      } else if (type == 6) {
                        return Container(
                            color: const Color(0xFF0082c9),
                            child: const Center(child: Text('📝')));
                      } else {
                        return CachedNetworkImage(
                          imageUrl:
                              'http://$host:8080/avatar/${chat.actorId!}/64?v=0',
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
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
                  margin: const EdgeInsets.only(right: 5),
                ),
          GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TextButton(
                              // padding: EdgeInsets.all(8),

                              onPressed: () {
                                ChatService().reactMessage(
                                    token,
                                    chat.id.toString(),
                                    {"reaction": '\u2764\ufe0f'});
                                Navigator.pop(context);
                              },
                              child: Text(
                                '\u2764\ufe0f',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            TextButton(
                              // padding: EdgeInsets.all(8),

                              onPressed: () {
                                ChatService().reactMessage(
                                    token,
                                    chat.id.toString(),
                                    {"reaction": '\ud83d\udc4d'});
                                Navigator.pop(context);
                              },
                              child: Text(
                                '\ud83d\udc4d',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            TextButton(
                              // padding: EdgeInsets.all(8),

                              onPressed: () {
                                ChatService().reactMessage(
                                    token,
                                    chat.id.toString(),
                                    {"reaction": '\ud83d\udc4e'});
                                Navigator.pop(context);
                              },
                              child: Text(
                                '\ud83d\udc4e',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            TextButton(
                              // padding: EdgeInsets.all(8),

                              onPressed: () {
                                ChatService().reactMessage(
                                    token,
                                    chat.id.toString(),
                                    {"reaction": '\ud83d\ude06'});
                                Navigator.pop(context);
                              },
                              child: Text(
                                '\ud83d\ude06',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            TextButton(
                              // padding: EdgeInsets.all(8),

                              onPressed: () {
                                ChatService().reactMessage(
                                    token,
                                    chat.id.toString(),
                                    {"reaction": '\ud83d\ude22'});
                                Navigator.pop(context);
                              },
                              child: Text(
                                '\ud83d\ude22',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            TextButton(
                              // padding: EdgeInsets.all(8),

                              onPressed: () {
                                ChatService().reactMessage(
                                    token,
                                    chat.id.toString(),
                                    {"reaction": '\ud83d\ude2f'});
                                Navigator.pop(context);
                              },
                              child: Text(
                                '\ud83d\ude2f',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),

                            // GestureDetector(
                            //   child: Container(
                            //     padding: EdgeInsets.all(8),
                            //     child: Text(
                            //       '\ud83d\udc4d',
                            //       style: TextStyle(fontSize: 24),
                            //     ),
                            //   ),
                            // ),
                            // GestureDetector(
                            //   child: Container(
                            //     padding: EdgeInsets.all(8),
                            //     child: Text(
                            //       '\ud83d\udc4e',
                            //       style: TextStyle(
                            //         fontSize: 24,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // GestureDetector(
                            //   child: Container(
                            //     padding: EdgeInsets.all(8),
                            //     child: Text(
                            //       '\ud83d\ude03',
                            //       style: TextStyle(fontSize: 24),
                            //     ),
                            //   ),
                            // ),
                            // GestureDetector(
                            //   child: Container(
                            //     padding: EdgeInsets.all(8),
                            //     child: Text(
                            //       '\ud83d\ude22',
                            //       style: TextStyle(fontSize: 24),
                            //     ),
                            //   ),
                            // ),
                            // GestureDetector(
                            //   child: Container(
                            //     padding: EdgeInsets.all(8),
                            //     child: Text(
                            //       '\ud83d\ude2f',
                            //       style: TextStyle(fontSize: 24),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        // IconButton(
                        //     alignment: Alignment.centerRight,
                        //     onPressed: () {
                        //       _emojiReactOpen = !_emojiReactOpen;
                        //     },
                        //     icon: Icon(Icons.more_horiz))
                      ],
                    ),

                    ListTile(
                      leading: const Icon(Icons.reply),
                      title: const Text('Trả lời'),
                      onTap: () {
                        pickChat(chat);
                        Navigator.pop(context);
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(Icons.forward),
                    //   title: Text('Chuyển tiếp'),
                    // ),
                    // const ListTile(
                    //   leading: Icon(Icons.copy),
                    //   title: Text('Sao chép'),

                    // ),
                  ],
                ),
              );
            },
            child: Row(
              children: [
                (chat.actorId == user.username)
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Text(
                          DateFormat('HH:mm').format(chat.timestamp!),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      )
                    : Container(),
                (chat.actorId == user.username)
                    ? Container(
                        margin: const EdgeInsets.only(right: 2),
                        child: Icon(
                          (chat.id! <= lastReadMessage)
                              ? Icons.done_all
                              : Icons.done,
                          size: 16,
                        ),
                      )
                    : Container(),
                (containsOnlyEmojis(chat.message.toString()))
                    ? Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        margin: (index == 0)
                            ? const EdgeInsets.only(
                                left: 2, right: 2, top: 2, bottom: 10)
                            : const EdgeInsets.symmetric(vertical: 2),
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
                                            padding: const EdgeInsets.only(
                                                left: 5, bottom: 3, top: 1),
                                            child: Text(
                                              chat.parent!.actorDisplayName
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            )),
                                        Container(
                                            padding: const EdgeInsets.only(
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
                              style: const TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        // alignment: (chat.actorId == user.username)
                        //     ? Alignment.centerRight
                        //     : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          margin: (index == 0)
                              ? const EdgeInsets.only(
                                  left: 2, right: 2, top: 2, bottom: 10)
                              : const EdgeInsets.symmetric(vertical: 2),
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
                                              padding: const EdgeInsets.only(
                                                  left: 5, bottom: 3, top: 1),
                                              child: Text(
                                                chat.parent!.actorDisplayName
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.6)),
                                              )),
                                          Container(
                                              padding: const EdgeInsets.only(
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
                                cache: const Duration(hours: 1),
                                backgroundColor: Colors.grey[200],
                                errorWidget: Container(
                                  color: Colors.grey[300],
                                  child: const Text('Oops!'),
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
                        margin: const EdgeInsets.only(left: 10),
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
