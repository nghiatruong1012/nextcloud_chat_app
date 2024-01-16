class UserConversation {
  final String? id;
  final String? label;
  final String? shareWithDisplayNameUnique;

  const UserConversation(this.id, this.label, this.shareWithDisplayNameUnique);
  factory UserConversation.fromJson(Map<String, dynamic> json) {
    return UserConversation(
      json['id'],
      json['label'],
      json['shareWithDisplayNameUnique'],
    );
  }
  static const empty = UserConversation(null, null, null);
}
