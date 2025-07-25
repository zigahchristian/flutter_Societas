class Turnout {
  final int id;
  final String name;
  final String? description;
  final DateTime turnoutDate;
  final String? location;
  final String? organizer;
  final String? status;

  Turnout({
    required this.id,
    required this.name,
    this.description,
    required this.turnoutDate,
    this.location,
    this.organizer,
    this.status,
  });

  factory Turnout.fromJson(Map<String, dynamic> json) {
    return Turnout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      turnoutDate: DateTime.parse(json['turnoutdate']),
      location: json['location'],
      organizer: json['organizer'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'turnoutdate': turnoutDate.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'status': status,
    };
  }

  String get dateDifference {
    final now = DateTime.now();
    final difference = turnoutDate.difference(now);

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} days';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return '${difference.inDays.abs()} days ago';
    }
  }

  get date => null;

  String get title => '';

  get attendees => null;

  get eventdate => null;

  Turnout copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? turnoutDate,
    String? location,
    String? organizer,
    String? status,
  }) {
    return Turnout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      turnoutDate: turnoutDate ?? this.turnoutDate,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      status: status ?? this.status,
    );
  }
}
