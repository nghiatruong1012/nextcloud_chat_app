// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

class ChatEvent {}

class LoadInitialChat extends ChatEvent {
  String token;
  int messageId;
  LoadInitialChat(this.token, this.messageId);
}

class ReceiveMessage extends ChatEvent {}

class SendMessage extends ChatEvent {
  String message;
  String actorDisplayName;
  String? id;
  SendMessage(
    this.message,
    this.actorDisplayName,
    this.id,
  );
}

class LoadOlderMessage extends ChatEvent {}
