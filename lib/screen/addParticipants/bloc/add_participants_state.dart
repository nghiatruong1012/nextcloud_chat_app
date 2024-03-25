// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'add_participants_bloc.dart';

@immutable
class AddParticipantsState extends Equatable {
  final String? query;
  final List<UserConversation>? users;
  AddParticipantsState({this.query, this.users});

  @override
  List<Object?> get props => [this.query, this.users];

  AddParticipantsState copyWith({
    String? query,
    List<UserConversation>? users,
  }) {
    return AddParticipantsState(
      query: query ?? this.query,
      users: users ?? this.users,
    );
  }
}

// final class AddParticipantsInitial extends AddParticipantsState {}
