class Participant {
  final int? attendeeId;
  final int? participantType;
  final String? actorId;
  final String? displayName;
  final String? status;

  const Participant(this.attendeeId, this.participantType, this.actorId,
      this.displayName, this.status);
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(json['attendeeId'], json['participantType'],
        json['actorId'], json['displayName'], json['status']);
  }
}
