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
import 'package:nextcloud_chat_app/models/user.dart';
import 'package:nextcloud_chat_app/screen/call/view/call.dart';
import 'package:nextcloud_chat_app/screen/chat/bloc/chat_bloc.dart';
import 'package:nextcloud_chat_app/screen/chat/widgets/chat_widgets.dart';
import 'package:nextcloud_chat_app/screen/conversationInfo/view/conversation_info.dart';
import 'package:nextcloud_chat_app/screen/searchChat/view/search_chat.dart';
import 'package:nextcloud_chat_app/screen/sharedItem/view/shared_item.dart';
import 'package:nextcloud_chat_app/service/call_service.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/participants_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';
import 'package:voice_message_package/voice_message_package.dart';

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
          return Scaffold(
            appBar: chatAppBar(context, state, user),
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
                        final nextMessage =
                            reversedIndex < state.listChat!.length - 1
                                ? state.listChat![reversedIndex + 1]
                                : null;
                        // Check if the date has changed
                        final bool showDate = previousMessage == null ||
                            message.timestamp!.day !=
                                previousMessage.timestamp!.day;
                        final isFirstMess = (previousMessage == null ||
                            message.actorId != previousMessage.actorId ||
                            previousMessage.systemMessage != '' ||
                            message.timestamp!.day !=
                                previousMessage.timestamp!.day);
                        final isLastMess = (nextMessage == null ||
                            message.actorId != nextMessage.actorId ||
                            nextMessage.systemMessage != '' ||
                            message.timestamp!.day !=
                                nextMessage.timestamp!.day);
                        return Column(
                          children: [
                            showDate
                                ? TimestampChat(message: message)
                                : Container(),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: MessageWidget(
                                state.listChat![reversedIndex],
                                user,
                                context,
                                token,
                                index,
                                requestHeaders,
                                state.conversations!.type!,
                                isFirstMess,
                                isLastMess,
                              ),
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

  AppBar chatAppBar(BuildContext context, ChatState state, User user) {
    return AppBar(
      backgroundColor: Colors.white,
      bottomOpacity: 0.0,
      elevation: 0.0,
      leading: Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
          onPressed: () {
            ParticipantsService().leaveConversation(token);
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
              child: (state.conversations!.type! == 2)
                  ? Container(
                      color: const Color.fromARGB(255, 236, 236, 236),
                      child: Icon(
                        Icons.group,
                        color: Colors.black,
                      ))
                  : FutureBuilder(
                      future: ConversationService().getConversationAvatar(
                          token,
                          state.conversations!.name!,
                          state.conversations!.lastMessage!.actorType!,
                          64),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data ?? Container();
                        } else {
                          return Container();
                        }
                      }),
            ),
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
                    builder: (context) => CallPage(
                      token: token,
                      user: user.username.toString(),
                    ),
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
                      builder: (context) => ConversationInfo(
                          conversations: state.conversations!,
                          listParticipant: state.listParticipants!),
                    ));
              },
            ),
            PopupMenuItem(
              child: Text('Shared items'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SharedItem(
                          token: token,
                          name: state.conversations!.displayName.toString()),
                    ));
              },
            ),
          ],
        ),
      ],
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
