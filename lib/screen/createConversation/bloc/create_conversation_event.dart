part of 'create_conversation_bloc.dart';

sealed class CreateConversationEvent extends Equatable {
  const CreateConversationEvent();

  @override
  List<Object> get props => [];
}

class ChangedQueryEvent extends CreateConversationEvent {
  final String query;
  const ChangedQueryEvent(this.query);
}

class SelectUserEvent extends CreateConversationEvent {
  final index;
  const SelectUserEvent(this.index);
}
