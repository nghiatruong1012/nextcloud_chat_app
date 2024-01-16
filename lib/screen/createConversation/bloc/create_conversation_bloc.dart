import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nextcloud_chat_app/models/list_user.dart';
import 'package:nextcloud_chat_app/service/create_conversation_service.dart';

part 'create_conversation_event.dart';
part 'create_conversation_state.dart';

class CreateConversationBloc
    extends Bloc<CreateConversationEvent, CreateConversationState> {
  CreateConversationBloc() : super(CreateConversationState()) {
    on<CreateConversationEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<ChangedQueryEvent>((event, emit) async {
      print('search');
      final user = await CreateConversationService().getListUser({
        'search': event.query,
        'itemType': '',
        'itemId': '',
        'sharedTypes[]': '0',
        'sharedTypes[]': '1',
        'sharedTypes[]': '7',
      });
      emit(state.copyWith(users: user));
      
    });
  }
}
