import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nextcloud_chat_app/models/list_user.dart';
import 'package:nextcloud_chat_app/screen/createConversation/model/createConverationModel.dart';
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
      final user = await CreateConversationService().getListUser({
        'search': event.query,
        'itemType': 'call',
        'itemId': '',
        'shareTypes[]': ['0'],
      });
      final List<SelectUser> selectedUser = user
          .map(
            (e) => SelectUser(userConversation: e, isSelected: false),
          )
          .toList();

      emit(state.copyWith(users: user));
    });
    // on<SelectUserEvent>((event, emit) {
    //   state.users![event.index].isSelected =
    //       !state.users![event.index].isSelected;
    //   emit(state.copyWith(users: state.users));
    // });
  }
}
