import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final String _baseUrl = 'http://your-api-url.com/payments';
  List<Payment> _payments = [];

  List<Payment> get payments => _payments;

  /// Fetch all payments
  Future<void> fetchPayments() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      _payments = data.map((e) => Payment.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  /// Create a new payment
  Future<void> addPayment(Payment payment) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payment.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final created = Payment.fromJson(json.decode(response.body));
      _payments.add(created);
      notifyListeners();
    } else {
      throw Exception('Failed to add payment');
    }
  }

  /// Update existing payment
  Future<void> updatePayment(Payment payment) async {
    if (payment.id == null) throw Exception('Payment ID required for update');

    final response = await http.put(
      Uri.parse('$_baseUrl/${payment.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payment.toJson()),
    );

    if (response.statusCode == 200) {
      final index = _payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        _payments[index] = payment;
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update payment');
    }
  }

  /// Delete payment
  Future<void> deletePayment(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      _payments.removeWhere((p) => p.id == id);
      notifyListeners();
    } else {
      throw Exception('Failed to delete payment');
    }
  }
}
