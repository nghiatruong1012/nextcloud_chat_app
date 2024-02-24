part of 'chat_bloc.dart';

@immutable
class ChatState extends Equatable {
  final bool? isLoading;
  final String? token;
  final Conversations? conversations;
  final String? lastKnownMessageId;
  final List<Chat>? listChat;
  final List<Participant>? listParticipants;


  ChatState(
      {this.isLoading = false,
      this.token,
      this.conversations,
      this.lastKnownMessageId,
      this.listChat, this.listParticipants,});

  @override
  // TODO: implement props
  List<Object?> get props => [
        this.isLoading,
        this.token,
        this.conversations,
        this.lastKnownMessageId,
        this.listChat, this.listParticipants,
      ];

  ChatState copyWith(
      {bool? isLoading,
      String? token,
      Conversations? conversations,
      String? lastKnownMessageId,
      List<Participant>? listParticipants,
      List<Chat>? listChat,}) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      lastKnownMessageId: lastKnownMessageId ?? this.lastKnownMessageId,
      token: token ?? this.token,
      conversations: conversations ?? this.conversations,
      listChat: listChat ?? this.listChat,
      listParticipants: listParticipants ?? this.listParticipants
    );
  }
}

// final class ChatInitial extends ChatState {}
