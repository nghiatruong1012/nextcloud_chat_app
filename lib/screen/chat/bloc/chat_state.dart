part of 'chat_bloc.dart';

@immutable
class ChatState extends Equatable {
  final String? token;
  final Conversations? conversations;
  final String? lastKnownMessageId;
  final List<Chat>? listChat;

  ChatState(
      {this.token, this.conversations, this.lastKnownMessageId, this.listChat});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [this.token, this.conversations, this.lastKnownMessageId, this.listChat];

  ChatState copyWith(
      {String? token, Conversations? conversations, String? lastKnownMessageId, List<Chat>? listChat}) {
    return ChatState(
      lastKnownMessageId: lastKnownMessageId ?? this.lastKnownMessageId,
      token: token ?? this.token,
      conversations: conversations ?? this.conversations,
      listChat: listChat ?? this.listChat,
    );
  }
}

// final class ChatInitial extends ChatState {}
