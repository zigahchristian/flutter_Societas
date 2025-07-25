import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:societas/models/turnout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TurnoutProvider with ChangeNotifier {
  // Base URL for turnout-related API endpoints
  final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:7240/api';

  // This is constructed using the API base URL from the environment variables.
  final String _turnoutEndpoint = '/turnout';

  // List of turnouts
  List<Turnout> _turnouts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Turnout> get turnouts => _turnouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch turnouts from the API
  Future<void> fetchTurnouts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl$_turnoutEndpoint'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _turnouts = data.map((json) => Turnout.fromJson(json)).toList();
        _error = null;
      } else {
        throw Exception('Failed to load turnouts: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new turnout
  Future<void> addTurnout(Turnout newTurnout) async {
    _isLoading = true;
    notifyListeners();

    try {
      final turnoutJson = newTurnout.toJson();
      turnoutJson.remove('id'); // Remove 'id' if present

      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_turnoutEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(turnoutJson),
      );

      if (response.statusCode == 201) {
        final addedTurnout = Turnout.fromJson(jsonDecode(response.body));
        _turnouts.add(addedTurnout);
        _error = null;
      } else {
        throw Exception('Failed to add turnout: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing turnout
  Future<void> updateTurnout(Turnout updatedTurnout) async {
    _isLoading = true;
    notifyListeners();

    try {
      final turnoutJson = updatedTurnout.toJson();
      final response = await http.put(
        Uri.parse('$_apiBaseUrl$_turnoutEndpoint/${updatedTurnout.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(turnoutJson),
      );

      if (response.statusCode == 200) {
        final index = _turnouts.indexWhere((t) => t.id == updatedTurnout.id);
        if (index != -1) {
          _turnouts[index] = updatedTurnout;
          _error = null;
        }
      } else {
        throw Exception('Failed to update turnout: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a turnout
  Future<void> deleteTurnout(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl$_turnoutEndpoint/$id'),
      );

      if (response.statusCode == 204) {
        _turnouts.removeWhere((t) => t.id == id);
        _error = null;
      } else {
        throw Exception('Failed to delete turnout: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
