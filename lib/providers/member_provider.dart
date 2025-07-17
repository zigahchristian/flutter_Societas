import 'package:flutter/material.dart';
import 'package:societas/models/member.dart'; // Your model class
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MemberProvider with ChangeNotifier {
  final String _baseUrl =
      dotenv.env['API_BASE_URL_MEMBER'] ?? 'http://localhost:7240/api/member';
  List<Member> _members = [];

  List<Member> get members => _members;

  Future<void> fetchMembers() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        // parse and update members
        final List data = jsonDecode(response.body);
        _members = data.map((json) => Member.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  // ✅ Add new member
  Future<void> addMember(Member newMember) async {
    // Remove 'id' from the JSON map if present
    final memberJson = newMember.toJson();
    memberJson.remove('id');

    print('Adding new member: ${memberJson}');
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(memberJson),
    );
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final added = Member.fromJson(jsonDecode(response.body));
      _members.add(added);
      notifyListeners();
    } else {
      throw Exception('Failed to add member laaa');
    }
  }

  // ✅ Update member
  Future<void> updateMember(Member updatedMember) async {
    print('Updating member: ${updatedMember.toJson()}');
    if (updatedMember.id == null) {
      throw Exception('Member ID required for update');
    }
    print('$_baseUrl/${updatedMember.id}');
    final response = await http.patch(
      Uri.parse('$_baseUrl/${updatedMember.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedMember.toJson()),
    );

    if (response.statusCode == 200) {
      final index = _members.indexWhere(
        (member) => member.id == updatedMember.id,
      );
      if (index != -1) {
        _members[index] = updatedMember;
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update member');
    }
  }

  // ✅ Delete member
  Future<void> deleteMember(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      _members.removeWhere((member) => member.id == id);
      notifyListeners();
    } else {
      throw Exception('Failed to delete member');
    }
  }
}
