import 'package:nextcloud_chat_app/models/chats.dart';

class Conversations {
  final int? id;
  final String? token;
  final int? type;
  final int? participantType;
  final bool? canLeaveConversation;
  final bool? canDeleteConversation;
  final int? notificationLevel;
  final int? notificationCalls;
  final String? name;
  final String? displayName;
  final int? lastReadMessage;
  final LastMessage? lastMessage;
  final String? avatarVersion;
  final String? status;

  const Conversations(
    this.id,
    this.token,
    this.type,
    this.participantType,
    this.canLeaveConversation,
    this.canDeleteConversation,
    this.notificationLevel,
    this.notificationCalls,
    this.name,
    this.displayName,
    this.lastReadMessage,
    this.lastMessage,
    this.avatarVersion,
    this.status,
  );
  factory Conversations.fromJson(Map<String, dynamic> json) {
    return Conversations(
      json['id'],
      json['token'],
      json['type'],
      json['participantType'],
      json['canLeaveConversation'],
      json['canDeleteConversation'],
      json['notificationLevel'],
      json['notificationCalls'],
      json['name'],
      json['displayName'],
      json['lastReadMessage'],
      LastMessage.fromJson(json['lastMessage']),
      json['avatarVersion'],
      json['status'],
    );
  }
  static const empty = Conversations(null, null, null, null, null, null, null,
      null, null, null, null, null, null, null);
}

class LastMessage {
  final int? id;
  final String? actorType;
  final String? actorId;
  final String? message;
  final DateTime? timestamp;
  const LastMessage(
      this.id, this.actorType, this.actorId, this.message, this.timestamp);
  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      json['id'],
      json['actorType'],
      json['actorId'],
      (json["messageParameters"] is Map)
          ? getSystemMessage(
              json["message"], json["messageParameters"], json["systemMessage"])
          : json["message"],
      DateTime.fromMillisecondsSinceEpoch(json["timestamp"] * 1000),
    );
  }
  static const empty = LastMessage(null, null, null, null, null);
}
