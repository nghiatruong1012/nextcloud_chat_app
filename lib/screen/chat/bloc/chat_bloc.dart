import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/models/conversations.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/participants_service.dart';
import 'package:nextcloud_chat_app/utils.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState()) {
    late Timer _timer;

    on<ChatEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LoadInitialChat>((event, emit) async {
      final conversations =
          await ParticipantsService().joinConversation(event.token);
      final listChat =
          await ChatService().getChatContext(event.token, event.messageId);
      emit(state.copyWith(
          token: event.token,
          conversations: conversations,
          lastKnownMessageId: conversations.lastMessage!.id.toString(),
          listChat: listChat));
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      print(state.lastKnownMessageId);
      if (state.token != null && state.lastKnownMessageId != null) {
        final response = await ChatService().receiveMessage(state.token!, {
          "setReadMarker": "0",
          "lookIntoFuture": "1",
          "lastKnownMessageId": state.lastKnownMessageId.toString(),
          "limit": "100",
          "includeLastKnown": "0"
        });
        if (response.statusCode == 200) {
          print("nhan tin nhan moi");
          List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
          List<Chat> listChat =
              data.map((item) => Chat.fromJson(item)).toList();

          emit(state.copyWith(
              lastKnownMessageId:
                  response.headers["x-chat-last-given"].toString()));
          print("mess id" + response.headers.toString());
        } else {
          print("khong nhan dc tin nhan moi");
        }
      }
    });

    on<SendMessage>((event, emit) async {
      print("gui");
      final response = await ChatService().sendMessage(state.token!, {
        "message": event.message,
        "actorDisplayName": event.actorDisplayName,
        "referenceId": generateRandomStringWithSha256(16),
        "silent": "false"
      });
      if (response.statusCode == 200) {
        print("gui tin nhan moi");
        // List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        // List<Chat> listChat = data.map((item) => Chat.fromJson(item)).toList();
        // state.listChat!.addAll(listChat);
        emit(state.copyWith(
            lastKnownMessageId:
                response.headers["x-chat-last-given"].toString()));
        print("mess id" + response.headers.toString());
      } else {
        print("khong gui dc tin nhan moi" + response.statusCode.toString());
      }
    });
  }
}
