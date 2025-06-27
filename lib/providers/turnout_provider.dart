import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/turnout.dart';

class TurnoutProvider with ChangeNotifier {
  final String _baseUrl = 'http://your-api-url.com/turnout';

  List<Turnout> _turnouts = [];

  List<Turnout> get turnouts => [..._turnouts];

  // Fetch all turnouts
  Future<void> fetchTurnouts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _turnouts = data.map((item) => Turnout.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load turnouts');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add a new turnout
  Future<void> addTurnout(Turnout turnout) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(turnout.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newTurnout = Turnout.fromJson(json.decode(response.body));
        _turnouts.add(newTurnout);
        notifyListeners();
      } else {
        throw Exception('Failed to create turnout');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update a turnout
  Future<void> updateTurnout(int id, Turnout updatedTurnout) async {
    final url = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTurnout.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _turnouts.indexWhere((item) => item.id == id);
        if (index >= 0) {
          _turnouts[index] = updatedTurnout;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update turnout');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a turnout
  Future<void> deleteTurnout(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final existingIndex = _turnouts.indexWhere((t) => t.id == id);
    Turnout? existingItem = _turnouts[existingIndex];

    _turnouts.removeAt(existingIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _turnouts.insert(existingIndex, existingItem);
      notifyListeners();
      throw Exception('Could not delete turnout.');
    }
  }
}
