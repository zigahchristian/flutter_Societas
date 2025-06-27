class Turnout {
  final int? id; // nullable for new inserts
  final String name;
  final String? description;
  final DateTime eventdate;
  final String? location;
  final int? organizer;
  final String status;
  final String? attendance;

  Turnout({
    this.id,
    required this.name,
    this.description,
    required this.eventdate,
    this.location,
    this.organizer,
    this.status = 'upcoming',
    this.attendance,
  });

  // Convert from JSON
  factory Turnout.fromJson(Map<String, dynamic> json) {
    return Turnout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      eventdate: DateTime.parse(json['event_date']),
      location: json['location'],
      organizer: json['organizer'],
      status: json['status'],
      attendance: json['attendance'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'event_date': eventdate.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'status': status,
      'attendance': attendance,
    };
  }
}
