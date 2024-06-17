class Participant {
  final String id;
  final String eventId;
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String status;

  Participant({
    required this.id,
    required this.eventId,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      eventId: json['eventId'],
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      status: json['status'],
    );
  }
}
