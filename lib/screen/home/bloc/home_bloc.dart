import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:nextcloud_chat_app/models/conversations.dart';
import 'package:nextcloud_chat_app/models/participants.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    on<HomeEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LoadConversationEvent>((event, emit) async {
      final list = await ConversationService().getUserConversations({});
      list.sort(
        (a, b) => b.lastMessage!.id!.compareTo(a.lastMessage!.id!),
      );
      emit(HomeState(listConversations: list, searchList: list));
    });
    on<SearchConversationEvent>((event, emit) {
      final searchList = state.listConversations!
          .where((element) =>
              element.name!.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(HomeState(searchList: searchList));
    });
  }
}
    // _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
    //   final list = await ConversationService().getUserConversations({});
    //   if (list != state.listConversations) {
    //     emit(state.copyWith(listConversations: list));
    //   } else {
    //     print("error");
    //   }
    // });