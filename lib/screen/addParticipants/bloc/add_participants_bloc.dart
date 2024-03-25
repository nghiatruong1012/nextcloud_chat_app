import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nextcloud_chat_app/models/list_user.dart';
import 'package:nextcloud_chat_app/screen/addParticipants/model/createConverationModel.dart';
import 'package:nextcloud_chat_app/service/create_conversation_service.dart';

part 'add_participants_event.dart';
part 'add_participants_state.dart';

class AddParticipantsBloc
    extends Bloc<AddParticipantsEvent, AddParticipantsState> {
  AddParticipantsBloc() : super(AddParticipantsState()) {
    on<AddParticipantsEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<ChangedQueryEvent>((event, emit) async {
      final user = await CreateConversationService().getListUser({
        'search': event.query,
        'itemType': 'call',
        'itemId': event.token,
        'sharedTypes[]': '0',
        'sharedTypes[]': '1',
        'sharedTypes[]': '7',
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
