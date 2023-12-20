class Conversations {
  final int? id;
  final String? token;
  final String? displayName;
  final LastMessage? lastMessage;
  final String? avatarVersion;

  const Conversations(this.id, this.token, this.displayName, this.lastMessage,
      this.avatarVersion);
  factory Conversations.fromJson(Map<String, dynamic> json) {
    return Conversations(
      json['id'],
      json['token'],
      json['displayName'],
      LastMessage.fromJson(json['lastMessage']),
      json['avatarVersion'],
    );
  }
  static const empty = Conversations(null, null, null, null, null);
}

class LastMessage {
  final int? id;
  final String? message;
  const LastMessage(this.id, this.message);
  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      json['id'],
      json['message'],
    );
  }
  static const empty = LastMessage(null, null);
}
