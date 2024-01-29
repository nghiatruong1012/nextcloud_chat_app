import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as category;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/screen/call/view/call.dart';
import 'package:nextcloud_chat_app/screen/chat/bloc/chat_bloc.dart';
import 'package:nextcloud_chat_app/screen/conversationInfo/view/conversation_info.dart';
import 'package:nextcloud_chat_app/screen/searchChat/view/search_chat.dart';
import 'package:nextcloud_chat_app/screen/sharedItem/view/shared_item.dart';
import 'package:nextcloud_chat_app/service/call_service.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';

const _platform = MethodChannel('emoji_picker_flutter');

Future<CategoryEmoji> getCategoryEmojis(
    {required CategoryEmoji category}) async {
  var available = (await _platform.invokeListMethod('getSupportedEmojis',
      {'source': category.emoji.map((e) => e.emoji).toList(growable: false)}));
  return category.copyWith(emoji: [
    for (int i = 0; i < available!.length; i++)
      if (available[i]) category.emoji[i]
  ]);
}

// Future<List<CategoryEmoji>> filterUnsupported(
//     {required List<CategoryEmoji> data}) async {
//   if (kIsWeb || Platform.isAndroid) {
//     return data;
//   }
//   final futures = [for (final cat in data) getCategoryEmojis(category: cat)];
// }

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
  bool _emojiOpen = false;
  _ChatPageState({required this.token, required this.messageId});
  TextEditingController messController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  late Map<String, String> requestHeaders;
  _imageHeader() async {
    requestHeaders = await HTTPService().authImgHeader();
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageHeader();
    context.read<ChatBloc>().add(LoadInitialChat(token, messageId));
    context.read<ChatBloc>().add(ReceiveMessage());
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          context.read<ChatBloc>().add(LoadOlderMessage());
        });
      }
    });
  }

  Future<void> toogleEmoji() async {
    setState(() {
      _emojiOpen = !_emojiOpen;
    });
    if (_emojiOpen) {
      await Future.delayed(const Duration(milliseconds: 200))
          .then((value) async {
        await SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 200))
          .then((value) async {
        await SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  void addEmojiToTextController({required Emoji emoji}) {
    messController.text = messController.text + emoji.emoji;
    messController.selection = TextSelection.fromPosition(
        TextPosition(offset: messController.text.length));
    setState(() {});
  }

  @override
  void dispose() {
    // messController.dispose();
    // scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.conversations != null && state.listChat != null) {
          print(state.listChat!.length);
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
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.all(0),
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
                    width: 10,
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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallPage(token: token),
                          ));
                    },
                    icon: Icon(
                      Icons.videocam,
                      color: Colors.black,
                    )),
                PopupMenuButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  color: Colors.white,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Tìm kiếm'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchChat(),
                            ));
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Conversation info'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationInfo(),
                            ));
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Shared items'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SharedItem(),
                            ));
                      },
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                (state.isLoading!) ? CircularProgressIndicator() : Container(),
                Flexible(
                  child: ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      itemCount: state.listChat!.length,
                      itemBuilder: (context, index) {
                        int itemCount = state?.listChat?.length ?? 0;
                        int reversedIndex = itemCount - 1 - index;
                        final message = state.listChat![reversedIndex];
                        final previousMessage = reversedIndex > 0
                            ? state.listChat![reversedIndex - 1]
                            : null;

                        // Check if the date has changed
                        final bool showDate = previousMessage == null ||
                            message.timestamp!.day !=
                                previousMessage.timestamp!.day;
                        return Column(
                          children: [
                            showDate
                                ? TimestampChat(message: message)
                                : Container(),
                            Builder(
                              builder: (context) {
                                if (state.listChat![reversedIndex]
                                        .systemMessage ==
                                    "") {
                                  if (state.listChat![reversedIndex]
                                          .messageParameters is Map &&
                                      state.listChat![reversedIndex]
                                          .messageParameters
                                          .containsKey('file')) {
                                    return Container(
                                      alignment: (state.listChat![reversedIndex]
                                                  .actorId ==
                                              user.username)
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () {
                                          ChatService().downloadAndOpenFile(
                                              user.username!,
                                              state.listChat![reversedIndex]
                                                      .messageParameters['file']
                                                  ['link'],
                                              state.listChat![reversedIndex]
                                                      .messageParameters['file']
                                                  ['path'],
                                              state.listChat![reversedIndex]
                                                      .messageParameters['file']
                                                  ['name']);
                                        },
                                        onLongPress: () {
                                          bool _emojiReactOpen = false;
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) => Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            ChatService().reactMessage(
                                                                token,
                                                                state
                                                                    .listChat![
                                                                        reversedIndex]
                                                                    .id
                                                                    .toString(),
                                                                {
                                                                  "reaction":
                                                                      '\u2764\ufe0f'
                                                                });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                              '\u2764\ufe0f',
                                                              style: TextStyle(
                                                                  fontSize: 24),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                              '\ud83d\udc4d',
                                                              style: TextStyle(
                                                                  fontSize: 24),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
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
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                              '\ud83d\ude03',
                                                              style: TextStyle(
                                                                  fontSize: 24),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                              '\ud83d\ude22',
                                                              style: TextStyle(
                                                                  fontSize: 24),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                              '\ud83d\ude2f',
                                                              style: TextStyle(
                                                                  fontSize: 24),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        onPressed: () {
                                                          _emojiReactOpen =
                                                              !_emojiReactOpen;
                                                        },
                                                        icon: Icon(
                                                            Icons.more_horiz))
                                                  ],
                                                ),
                                                Offstage(
                                                  offstage: !_emojiReactOpen,
                                                  child: SizedBox(
                                                    height: 300,
                                                    child: EmojiPicker(
                                                        textEditingController:
                                                            messController,
                                                        config: Config(
                                                          columns: 7,
                                                          emojiSizeMax: 32 *
                                                              (Platform.isIOS
                                                                  ? 1.30
                                                                  : 1.0),
                                                        )),
                                                  ),
                                                ),
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
                                        child: Container(
                                          constraints:
                                              BoxConstraints(maxWidth: 300),
                                          margin: (index == 0)
                                              ? EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 2,
                                                  bottom: 10)
                                              : EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 2),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: (state
                                                      .listChat![reversedIndex]
                                                      .actorId ==
                                                  user.username)
                                              ? BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                    topLeft:
                                                        Radius.circular(15),
                                                  ),
                                                )
                                              : BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  )),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              (state.listChat![reversedIndex]
                                                                      .messageParameters[
                                                                  'file'][
                                                              'preview-available'] ==
                                                          'yes' &&
                                                      state
                                                          .listChat![
                                                              reversedIndex]
                                                          .messageParameters[
                                                              'file']
                                                              ['mimetype']
                                                          .toString()
                                                          .contains('image'))
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          'http://${host}:8080/core/preview?x=-1&y=480&a=1&fileId=${state.listChat![reversedIndex].messageParameters['file']['id']}',
                                                      placeholder: (context,
                                                              url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return Icon(
                                                            Icons.error);
                                                      },
                                                      httpHeaders:
                                                          requestHeaders,
                                                    )
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          child: Builder(
                                                            builder: (context) {
                                                              String filePath = state
                                                                  .listChat![
                                                                      reversedIndex]
                                                                  .message
                                                                  .toString();
                                                              List<String>
                                                                  parts =
                                                                  filePath
                                                                      .split(
                                                                          '.');
                                                              if (parts.length >
                                                                  1) {
                                                                switch (parts
                                                                    .last) {
                                                                  case 'pdf':
                                                                    return Image
                                                                        .asset(
                                                                            'assets/pdf.png');
                                                                    break;

                                                                  case 'docx':
                                                                    return Image
                                                                        .asset(
                                                                            'assets/doc.png');
                                                                    break;

                                                                  case 'ppt':
                                                                    return Image
                                                                        .asset(
                                                                            'assets/ppt.png');
                                                                    break;

                                                                  case 'txt':
                                                                    return Image
                                                                        .asset(
                                                                            'assets/txt.png');
                                                                    break;

                                                                  case 'zip':
                                                                    return Image
                                                                        .asset(
                                                                            'assets/zip.png');

                                                                    break;
                                                                  default:
                                                                    return Image
                                                                        .asset(
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
                                                        Text(
                                                            state
                                                                .listChat![
                                                                    reversedIndex]
                                                                .message
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                      ],
                                                    ),
                                              (state.listChat![reversedIndex]
                                                          .reactions !=
                                                      {})
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                          top: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: state
                                                            .listChat![
                                                                reversedIndex]
                                                            .reactions!
                                                            .entries
                                                            .map((entries) {
                                                          return Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 5),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        3,
                                                                    vertical:
                                                                        2),
                                                            // decoration: BoxDecoration(
                                                            //     color: Colors
                                                            //         .amber,
                                                            //     borderRadius:
                                                            //         BorderRadius
                                                            //             .circular(
                                                            //                 20)),
                                                            child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(entries
                                                                          .key +
                                                                      " "),
                                                                  Text(entries
                                                                      .value
                                                                      .toString())
                                                                ]),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else
                                    return GestureDetector(
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
                                      child: Container(
                                        alignment: (state
                                                    .listChat![reversedIndex]
                                                    .actorId ==
                                                user.username)
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          constraints:
                                              BoxConstraints(maxWidth: 300),
                                          margin: (index == 0)
                                              ? EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 2,
                                                  bottom: 10)
                                              : EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 2),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: (state
                                                      .listChat![reversedIndex]
                                                      .actorId ==
                                                  user.username)
                                              ? BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                    topLeft:
                                                        Radius.circular(15),
                                                  ),
                                                )
                                              : BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  )),
                                          child: Column(
                                            children: [
                                              Text(
                                                state.listChat![reversedIndex]
                                                    .message
                                                    .toString(),
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              (state.listChat![reversedIndex]
                                                          .reactions !=
                                                      {})
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: state
                                                          .listChat![
                                                              reversedIndex]
                                                          .reactions!
                                                          .entries
                                                          .map((entries) {
                                                        return Container(
                                                          // decoration: BoxDecoration(
                                                          //     color:
                                                          //         Colors.amber,
                                                          //     borderRadius:
                                                          //         BorderRadius
                                                          //             .circular(
                                                          //                 20)),
                                                          child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(entries
                                                                    .key),
                                                                Text(entries
                                                                    .value
                                                                    .toString())
                                                              ]),
                                                        );
                                                      }).toList(),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                } else if (state.listChat![reversedIndex]
                                        .systemMessage ==
                                    "reaction") {
                                  return Container();
                                } else {
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                        '${state.listChat![reversedIndex].message}'),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      }),
                ),
                Column(
                  children: [
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
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  PlatformFile file = result.files.first;
                                  File _file = File(result.files.single.path!);
                                  ChatService().uploadAndSharedFile(
                                      user.username.toString(),
                                      file.path.toString(),
                                      file.name,
                                      _file,
                                      token);
                                  print('file shared' + file.path.toString());
                                } else {
                                  print('error');
                                }
                              },
                              icon: Icon(Icons.attach_file)),
                          IconButton(
                              onPressed: () {
                                toogleEmoji();
                              },
                              icon: Icon(_emojiOpen
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined)),
                          Flexible(
                            child: Container(
                              child: TextFormField(
                                enabled: (state.conversations!.lastMessage!
                                        .actorType !=
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
                                        borderRadius:
                                            BorderRadius.circular(20))),
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
                    ),
                    Offstage(
                      offstage: !_emojiOpen,
                      child: SizedBox(
                        height: 300,
                        child: EmojiPicker(
                            textEditingController: messController,
                            config: Config(
                              columns: 7,
                              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                            )),
                      ),
                    )
                  ],
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

class TimestampChat extends StatelessWidget {
  const TimestampChat({
    super.key,
    required this.message,
  });

  final Chat message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Builder(builder: (context) {
        if (message.timestamp!.toLocal().day == DateTime.now().day) {
          return Text(
            "Hôm nay",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          );
        } else if (message.timestamp!.toLocal().day == DateTime.now().day - 1) {
          return Text(
            "Hôm qua",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          );
        } else {
          return Text(
            "${message.timestamp!.toLocal().day} tháng ${message.timestamp!.toLocal().month} năm ${message.timestamp!.toLocal().year}",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          );
        }
      }),
    );
  }
}
