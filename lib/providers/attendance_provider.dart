import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';

class AttendanceProvider with ChangeNotifier {
  final String _baseUrl = 'http://your-backend-url.com/attendance';

  List<Attendance> _items = [];

  List<Attendance> get items => [..._items];

  // Fetch all records
  Future<void> fetchAttendance() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      final List<dynamic> data = json.decode(response.body);

      _items = data.map((jsonItem) => Attendance.fromJson(jsonItem)).toList();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to load attendance data: $error');
    }
  }

  // Add new attendance
  Future<void> addAttendance(Attendance attendance) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(attendance.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newAttendance = Attendance.fromJson(json.decode(response.body));
        _items.add(newAttendance);
        notifyListeners();
      } else {
        throw Exception('Failed to create attendance');
      }
    } catch (error) {
      throw Exception('Error creating attendance: $error');
    }
  }

  // Update existing attendance
  Future<void> updateAttendance(String id, Attendance updated) async {
    final url = '$_baseUrl/$id';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updated.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _items.indexWhere((att) => att.id == id);
        if (index >= 0) {
          _items[index] = updated;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update attendance');
      }
    } catch (error) {
      throw Exception('Error updating attendance: $error');
    }
  }

  // Delete attendance
  Future<void> deleteAttendance(String id) async {
    final url = '$_baseUrl/$id';

    final existingIndex = _items.indexWhere((att) => att.id == id);
    Attendance? existingItem = _items[existingIndex];

    _items.removeAt(existingIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingItem);
      notifyListeners();
      throw Exception('Could not delete attendance.');
    }

    existingItem = null;
  }
}
