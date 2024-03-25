part of 'add_participants_bloc.dart';

sealed class AddParticipantsEvent extends Equatable {
  const AddParticipantsEvent();

  @override
  List<Object> get props => [];
}

class ChangedQueryEvent extends AddParticipantsEvent {
  final String query;
  final String token;
  const ChangedQueryEvent(this.query, this.token);
}

class SelectUserEvent extends AddParticipantsEvent {
  final index;
  const SelectUserEvent(this.index);
}
