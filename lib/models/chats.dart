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
    // this.messageParameters,
  );
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      json["id"],
      json["actorId"],
      (json["messageParameters"] is Map)
          ? getSystemMessage(
              json["message"], json["messageParameters"], json["systemMessage"])
          : json["message"],
      json["systemMessage"],
      // json["messageParameters"],
    );
  }
  static const empty = Chat(null, null, null, null);
}

String getSystemMessage(String initalMessage,
    Map<String, dynamic> messageParameters, String systemMessage) {
  if (!systemMessage.isNotEmpty) {
    return initalMessage;
  } else {
    String finalMessage = initalMessage;

    // Thay thế các giá trị trong message bằng giá trị từ messageParameters

    messageParameters.forEach((key, value) {
      finalMessage = finalMessage.replaceAll('{$key}', value['name']);
    });
    print(finalMessage);
    return finalMessage;
  }
}
