// ignore_for_file: public_member_api_docs, sort_constructors_first
class Chat {
  final int? id;
  final String? actorId;
  final String? message;
  final String? systemMessage;
  final DateTime? timestamp;
  final dynamic? messageParameters;
  final Map? reactions;
  final ParentChat? parent;

  const Chat(this.id, this.actorId, this.message, this.systemMessage,
      this.timestamp, this.messageParameters, this.reactions, this.parent);
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      json["id"],
      json["actorId"],
      (json["messageParameters"] is Map)
          ? getSystemMessage(
              json["message"], json["messageParameters"], json["systemMessage"])
          : json["message"],
      json["systemMessage"],
      DateTime.fromMillisecondsSinceEpoch(json["timestamp"] * 1000),
      json["messageParameters"],
      json["reactions"],
      (json["parent"] != null) ? ParentChat.fromJson(json["parent"]) : null,
    );
  }
  static const empty = Chat(null, null, null, null, null, null, null, null);
}

String getSystemMessage(String initalMessage,
    Map<String, dynamic> messageParameters, String systemMessage) {
  // if (!systemMessage.isNotEmpty) {
  //   return initalMessage;
  // } else {
  String finalMessage = initalMessage;

  // Thay thế các giá trị trong message bằng giá trị từ messageParameters

  messageParameters.forEach((key, value) {
    finalMessage = finalMessage.replaceAll('{$key}', value['name']);
  });
  return finalMessage;
  // }
}

class ParentChat {
  final int? id;
  final String? actorId;
  final String? message;
  final String? systemMessage;
  final DateTime? timestamp;
  final dynamic? messageParameters;
  final Map? reactions;
  final Map<String, dynamic>? parent;

  const ParentChat(this.id, this.actorId, this.message, this.systemMessage,
      this.timestamp, this.messageParameters, this.reactions, this.parent);
  factory ParentChat.fromJson(Map<String, dynamic> json) {
    return ParentChat(
        json["id"],
        json["actorId"],
        (json["messageParameters"] is Map)
            ? getSystemMessage(json["message"], json["messageParameters"],
                json["systemMessage"])
            : json["message"],
        json["systemMessage"],
        DateTime.fromMillisecondsSinceEpoch(json["timestamp"] * 1000),
        json["messageParameters"],
        json["reactions"],
        json["parent"]);
  }
  static const empty = Chat(null, null, null, null, null, null, null, null);
}
