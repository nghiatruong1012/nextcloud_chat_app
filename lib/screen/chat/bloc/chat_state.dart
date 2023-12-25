part of 'chat_bloc.dart';

@immutable
class ChatState extends Equatable {
  final Conversations? conversations;
  final List<Chat>? listChat;

  ChatState({this.conversations, this.listChat});

  @override
  // TODO: implement props
  List<Object?> get props => [this.conversations, this.listChat];

  ChatState copyWith({Conversations? conversations, List<Chat>? listChat}) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      listChat: listChat ?? this.listChat,
    );
  }
}

// final class ChatInitial extends ChatState {}
