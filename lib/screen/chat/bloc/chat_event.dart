part of 'chat_bloc.dart';

@immutable
class ChatEvent {}

class LoadInitialChat extends ChatEvent {
  String token;
  int messageId;
  LoadInitialChat(this.token, this.messageId);
}
