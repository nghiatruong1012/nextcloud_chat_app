class UserData {
  final String? id;
  final String? email;
  final String? displayname;
  final String? phone;
  final String? address;
  final String? website;
  final String? twitter;

  const UserData(this.id, this.email, this.displayname, this.phone,
      this.address, this.website, this.twitter);

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      json["id"],
      json["email"],
      json["displayname"],
      json["phone"],
      json["address"],
      json["website"],
      json["twitter"],
    );
  }

  static const empty = UserData(null, null, null, null, null, null, null);
}
