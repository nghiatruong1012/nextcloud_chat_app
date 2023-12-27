// ignore_for_file: public_member_api_docs, sort_constructors_first
class Chat {
  final int? id;
  final String? actorId;
  final String? message;
  final String? systemMessage;
  const Chat(
    this.id,
    this.actorId,
    this.message,
    this.systemMessage,
  );
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      json["id"],
      json["actorId"],
      json["message"],
      json["systemMessage"],
    );
  }
  static const empty = Chat(null, null, null, null);
}
