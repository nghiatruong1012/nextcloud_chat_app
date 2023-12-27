// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

@immutable
class ChatEvent {}

class LoadInitialChat extends ChatEvent {
  String token;
  int messageId;
  LoadInitialChat(this.token, this.messageId);
}

class SendMessage extends ChatEvent {
  String message;
  String actorDisplayName;
  SendMessage(
    this.message,
    this.actorDisplayName,
  );
}
