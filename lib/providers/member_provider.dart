import 'package:flutter/material.dart';
import 'package:societas/models/member.dart'; // Your model class
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MemberProvider with ChangeNotifier {
  List<Member> _members = [];

  List<Member> get members => _members;

  Future<void> fetchMembers() async {
    try {
      print('Fetching members from API...');
      final response = await http.get(
        Uri.parse('http://localhost:7240/api/member'),
        headers: {'Accept': 'application/json'},
      );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // parse and update members
        final List data = jsonDecode(response.body);
        print(data);
        _members = data.map((json) => Member.fromJson(json)).toList();
        print("Completed");
        notifyListeners();
      } else {
        print('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  // ✅ Add new member
  Future<void> addMember(Member newMember) async {
    final url = dotenv.env['DATABASE_URL'] ?? 'http://localhost:3000/members';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newMember.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final added = Member.fromJson(jsonDecode(response.body));
      _members.add(added);
      notifyListeners();
    } else {
      throw Exception('Failed to add member');
    }
  }

  // ✅ Update member
  Future<void> updateMember(Member updatedMember) async {
    final url = 'http://localhost:8000/members/${updatedMember.id}';
    final response = await http.put(
      Uri.parse(url),
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
    final url = 'http://localhost:8000/members/$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 204) {
      _members.removeWhere((member) => member.id == id);
      notifyListeners();
    } else {
      throw Exception('Failed to delete member');
    }
  }
}
