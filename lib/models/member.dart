import 'package:intl/intl.dart';

class Member {
  final int? id; // Changed from String? to int?
  final String membername;
  final String firstname;
  final String lastname;
  final String? gender;
  final String? email;
  final String? phone;
  final String? position;
  final String? memberaddress;
  final DateTime? dateofbirth;
  final String? occupation;
  final String? otherskills;
  final String? profilepicture;
  final String? publicprofilepictureurl;
  final String? emergencycontactname;
  final String? emergencycontactphone;
  final String? emergencycontactrelationship;
  final String membershiptype;
  final DateTime joindate;
  final MemberStatus status;

  Member({
    this.id,
    required this.membername,
    required this.firstname,
    required this.lastname,
    this.gender,
    this.email,
    this.phone,
    this.position,
    this.memberaddress,
    this.dateofbirth,
    this.occupation,
    this.otherskills,
    this.profilepicture,
    this.publicprofilepictureurl,
    this.emergencycontactname,
    this.emergencycontactphone,
    this.emergencycontactrelationship,
    required this.membershiptype,
    required this.joindate,
    required this.status,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      membername: json['membername'] as String,
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
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
      publicprofilepictureurl: json['publicprofilepictureurl'] as String?,
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
    final map = <String, dynamic>{
      'id': id,
      'membername': membername,
      'firstname': firstname,
      'lastname': lastname,
      'gender': gender,
      'email': email,
      'phone': phone,
      'position': position,
      'memberaddress': memberaddress,
      'dateofbirth': dateofbirth != null
          ? DateFormat('yyyy-MM-dd').format(dateofbirth!)
          : null,
      'occupation': occupation,
      'otherskills': otherskills,
      'profilepicture': profilepicture,
      'publicprofilepictureurl': publicprofilepictureurl,
      'emergencycontactname': emergencycontactname,
      'emergencycontactphone': emergencycontactphone,
      'emergencycontactrelationship': emergencycontactrelationship,
      'membershiptype': membershiptype,
      'joindate': joindate.toIso8601String(),
      'status': status.toString(),
    };
    // Remove null values
    map.removeWhere((key, value) => value == null);
    return map;
  }

  Member copyWith({
    int? id,
    String? membername,
    String? firstname,
    String? lastname,
    String? gender,
    String? email,
    String? phone,
    String? position,
    String? memberaddress,
    DateTime? dateofbirth,
    String? occupation,
    String? otherskills,
    String? profilepicture,
    String? publicprofilepictureurl,
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
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      memberaddress: memberaddress ?? this.memberaddress,
      dateofbirth: dateofbirth ?? this.dateofbirth,
      occupation: occupation ?? this.occupation,
      otherskills: otherskills ?? this.otherskills,
      profilepicture: profilepicture ?? this.profilepicture,
      publicprofilepictureurl:
          publicprofilepictureurl ?? this.publicprofilepictureurl,
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
