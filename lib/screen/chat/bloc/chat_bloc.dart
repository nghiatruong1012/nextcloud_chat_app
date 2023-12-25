import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/models/conversations.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/participants_service.dart';

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
      final listChat =
          await ChatService().getChatContext(event.token, event.messageId);
      emit(state.copyWith(conversations: conversations, listChat: listChat));
    });
  }
}
