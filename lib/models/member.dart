class Member {
  final int? id;
  final String membername;
  final String? email;
  final String? phone;
  final String? position;
  final String? memberaddress;
  final DateTime? dateofbirth;
  final String? occupation;
  final String? otherskills;
  final String? profilepicture;
  final String? emergencycontactname;
  final String? emergencycontactphone;
  final String? emergencycontactrelationship;
  final String membershiptype;
  final DateTime joindate;
  final MemberStatus status;

  Member({
    this.id,
    required this.membername,
    this.email,
    this.phone,
    this.position,
    this.memberaddress,
    this.dateofbirth,
    this.occupation,
    this.otherskills,
    this.profilepicture,
    this.emergencycontactname,
    this.emergencycontactphone,
    this.emergencycontactrelationship,
    required this.membershiptype,
    required this.joindate,
    required this.status,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] != null ? json['id'] as int : null,
      membername: json['membername'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      position: json['position'] as String?,
      memberaddress: json['memberaddress'] as String?,
      dateofbirth: json['dateofbirth'] != null
          ? DateTime.tryParse(json['dateofbirth'] as String)
          : null,
      occupation: json['occupation'] as String?,
      otherskills: json['otherskills'] as String?,
      profilepicture: json['profilepicture'] as String?,
      emergencycontactname: json['emergencycontactname'] as String?,
      emergencycontactphone: json['emergencycontactphone'] as String?,
      emergencycontactrelationship:
          json['emergencycontactrelationship'] as String?,
      membershiptype: json['membershiptype'] as String? ?? 'regular',
      joindate: DateTime.tryParse(
        json['join_date'] as String? ?? DateTime.now().toIso8601String(),
      )!,
      status: MemberStatus.fromString(json['status'] as String? ?? 'active'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'membername': membername,
      'email': email,
      'phone': phone,
      'position': position,
      'memberaddress': memberaddress,
      'dateofbirth': dateofbirth?.toIso8601String(),
      'occupation': occupation,
      'otherskills': otherskills,
      'profilepicture': profilepicture,
      'emergencycontactname': emergencycontactname,
      'emergencycontactphone': emergencycontactphone,
      'emergencycontactrelationship': emergencycontactrelationship,
      'membershiptype': membershiptype,
      'join_date': joindate.toIso8601String(),
      'status': status.toString(),
    };
  }

  Member copyWith({
    int? id,
    String? membername,
    String? email,
    String? phone,
    String? position,
    String? memberaddress,
    DateTime? dateofbirth,
    String? occupation,
    String? otherskills,
    String? profilepicture,
    String? emergencycontactname,
    String? emergencycontactphone,
    String? emergencycontactrelationship,
    String? membershiptype,
    DateTime? joindate,
    MemberStatus? status,
  }) {
    return Member(
      id: id ?? this.id,
      membername: membername ?? this.membername,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      memberaddress: memberaddress ?? this.memberaddress,
      dateofbirth: dateofbirth ?? this.dateofbirth,
      occupation: occupation ?? this.occupation,
      otherskills: otherskills ?? this.otherskills,
      profilepicture: profilepicture ?? this.profilepicture,
      emergencycontactname: emergencycontactname ?? this.emergencycontactname,
      emergencycontactphone:
          emergencycontactphone ?? this.emergencycontactphone,
      emergencycontactrelationship:
          emergencycontactrelationship ?? this.emergencycontactrelationship,
      membershiptype: membershiptype ?? this.membershiptype,
      joindate: joindate ?? this.joindate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Member(id: $id, name: $membername, status: $status)';
  }
}

enum MemberStatus {
  active,
  inactive,
  suspended,
  pending;

  factory MemberStatus.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return MemberStatus.active;
      case 'inactive':
        return MemberStatus.inactive;
      case 'suspended':
        return MemberStatus.suspended;
      case 'pending':
        return MemberStatus.pending;
      default:
        return MemberStatus.active;
    }
  }

  @override
  String toString() {
    return name;
  }
}
