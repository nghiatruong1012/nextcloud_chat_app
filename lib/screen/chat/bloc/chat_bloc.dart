import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/models/conversations.dart';
import 'package:nextcloud_chat_app/models/participants.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/participants_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';
import 'package:http/http.dart' as http;

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState()) {
    on<ChatEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LoadInitialChat>((event, emit) async {
      final conversations =
          await ParticipantsService().joinConversation(event.token);
      final listParticipants =
          await ParticipantsService().getListParticipants(event.token);
      final listChat =
          await ChatService().getChatContext(event.token, event.messageId);
      emit(state.copyWith(
        token: event.token,
        conversations: conversations,
        lastKnownMessageId: conversations.lastMessage!.id.toString(),
        listChat: listChat,
        listParticipants: listParticipants,
      ));
      fetchApi();
    });
    // on<ChangeMessage>((event, emit) {
    //   emit(state.copyWith(
    //       listChat: state.listChat!
    //           .map((e) =>
    //               e.id == event.chat.parent!.id ? event.chat.parent as Chat : e)
    //           .toList()));
    // });

    // on<ReceiveMessage>((event, emit) async {
    //   print(state.lastKnownMessageId);
    //   if (state.token != null && state.lastKnownMessageId != null) {
    //     final response = await ChatService().receiveMessage(state.token!, {
    //       "setReadMarker": "0",
    //       "lookIntoFuture": "1",
    //       "lastKnownMessageId": state.lastKnownMessageId.toString(),
    //       "limit": "100",
    //       "includeLastKnown": "0"
    //     });
    //     if (response.statusCode == 200) {
    //       print("nhan tin nhan moi");
    //       List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
    //       List<Chat> listChat =
    //           data.map((item) => Chat.fromJson(item)).toList();
    //       state.listChat!.addAll(listChat);
    //       emit(state.copyWith(
    //           lastKnownMessageId:
    //               response.headers["x-chat-last-given"].toString()));
    //       print("mess id" + response.headers["x-chat-last-given"].toString());

    //       return;
    //     } else {
    //       print("khong nhan dc tin nhan moi");
    //     }
    //   }
    // });

    on<SendMessage>((event, emit) async {
      final response = await ChatService().sendMessage(state.token!, {
        "message": event.message,
        "actorDisplayName": event.actorDisplayName,
        "replyTo": event.id,
        "referenceId": generateRandomStringWithSha256(16),
        "silent": "false"
      });
      if (response.statusCode == 200) {
        // List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        // List<Chat> listChat = data.map((item) => Chat.fromJson(item)).toList();
        // state.listChat!.addAll(listChat);
        emit(state.copyWith(
            lastKnownMessageId:
                response.headers["x-chat-last-given"].toString()));
      } else {}
    });

    on<LoadOlderMessage>((event, emit) async {
      if (!state.isLoading! && (state.listChat![0].id! > 0)) {
        state.copyWith(isLoading: true);

        final response = await ChatService().receiveMessage(state.token!, {
          "setReadMarker": "0",
          "lookIntoFuture": "0",
          "lastKnownMessageId": state.listChat![0].id.toString(),
          "limit": "100",
          "includeLastKnown": "0"
        });
        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
          List<Chat> listChat =
              data.map((item) => Chat.fromJson(item)).toList();
          state.listChat!.insertAll(0, listChat.reversed);

          state.copyWith(isLoading: false);
          emit(state.copyWith(listChat: state.listChat));
        } else {}
      }
    });
  }
  Future<void> fetchApi() async {
    if (state.token != null && state.lastKnownMessageId != null) {
      Map<String, String> requestHeaders = await HTTPService().authHeader();

      final params = {
        "setReadMarker": "0",
        "lookIntoFuture": "1",
        "lastKnownMessageId": state.lastKnownMessageId.toString(),
        "limit": "100",
        "includeLastKnown": "0"
      };

      final response = await http.get(
        Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v1/chat/${state.token}',
            queryParameters: params),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        List<Chat> listChat = data.map((item) => Chat.fromJson(item)).toList();

        state.listChat!.addAll(listChat);
        emit(state.copyWith(
            lastKnownMessageId:
                response.headers["x-chat-last-given"].toString()));

        fetchApi();
      } else {
        fetchApi();
      }
    } else {
      fetchApi();
    }
  }
}
