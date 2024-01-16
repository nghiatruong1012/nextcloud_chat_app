// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'create_conversation_bloc.dart';

@immutable
class CreateConversationState extends Equatable {
  final String? query;
  final List<UserConversation>? users;
  CreateConversationState({this.query, this.users});

  @override
  List<Object?> get props => [this.query, this.users];

  CreateConversationState copyWith({
    String? query,
    List<UserConversation>? users,
  }) {
    return CreateConversationState(
      query: query ?? this.query,
      users: users ?? this.users,
    );
  }
}

// final class CreateConversationInitial extends CreateConversationState {}
