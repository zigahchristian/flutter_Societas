import 'package:flutter/material.dart';
import 'package:societas/models/member.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MemberProvider with ChangeNotifier {
  final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:7240/api/member';

  // Base URL for member-related API endpoints
  // This is constructed using the API base URL from the environment variables.
  // It is used to make HTTP requests to the member-related endpoints.
  // The base URL is used to fetch, add, update, and delete members.
  // It is a common practice to keep the base URL in a separate variable
  late final String _baseUrl = '$_apiBaseUrl/member';

  // ✅ List of members
  // This will hold the members fetched from the API
  // and will be used to display in the UI.
  // It is initialized as an empty list.
  // The list will be populated when the fetchMembers method is called.
  // The notifyListeners() method will be called to update the UI when the list changes.
  // This is a common pattern in Flutter to manage state with ChangeNotifier.
  // The members will be used in various parts of the app, such as displaying a list
  // of members, adding new members, updating existing members, and deleting members.
  // The members list is private to the class, but can be accessed through the members getter
  // which returns a copy of the list to prevent external modification.
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

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(memberJson),
    );

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
    if (updatedMember.id == null) {
      throw Exception('Member ID required for update');
    }

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
