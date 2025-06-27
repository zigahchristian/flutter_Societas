class Attendance {
  final String id; // Unique attendance record ID
  final String memberid;
  final DateTime date;
  final String turnout;
  final bool participation;
  final String? remarks;

  Attendance({
    required this.id,
    required this.memberid,
    required this.date,
    required this.turnout,
    required this.participation,
    this.remarks,
  });

  // Convert to JSON (e.g., for Firebase or API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberid,
      'date': date.toIso8601String(),
      'participation': participation,
      'turnout': turnout,
      'remarks': remarks,
    };
  }

  // Create from JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      memberid: json['memberId'],
      date: DateTime.parse(json['date']),
      participation: json['isPresent'],
      turnout: json['turnout'],
      remarks: json['remarks'],
    );
  }
}
