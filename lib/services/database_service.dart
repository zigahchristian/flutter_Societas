import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart'; // You would need to add this package to your pubspec.yaml
import 'package:societas/models/member.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  late PostgreSQLConnection _connection; // Holds the database connection

  // The database URL string
  final String databaseUrl;

  DatabaseService({required this.databaseUrl});

  // Method to initialize and open the database connection
  Future<void> initialize() async {
    try {
      // Parse the databaseUrl to extract connection parameters
      // PostgreSQLConnection can often parse a URL directly, or you can extract components
      // Example: postgresql://user:password@host:port/database_name
      final Uri uri = Uri.parse(databaseUrl);
      _connection = PostgreSQLConnection(
        uri.host,
        uri.port,
        uri.pathSegments.last, // Gets the database name from the path
        username: uri.userInfo.split(':')[0],
        password: uri.userInfo.split(':')[1],
        useSSL:
            uri.scheme == 'https' ||
            uri.scheme == 'postgresqls', // Use SSL if the scheme implies it
      );

      await _connection.open();
      print('Database connection opened successfully.');
    } catch (e) {
      print('Error opening database connection: $e');
      // Handle the error appropriately, e.g., throw an exception, show a user message
    }
  }

  // Method to close the database connection
  Future<void> close() async {
    try {
      await _connection.close();
      print('Database connection closed.');
    } catch (e) {
      print('Error closing database connection: $e');
    }
  }

  // Example method to fetch data (conceptual)
  // In a real app, this would involve SQL queries
  Future<List<Member>> fetchMembers() async {
    final String apiUrl =
        dotenv.env['DATABASE_URL'] ??
        'http://localhost:3000/members'; // Replace with your actual backend URL

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  // Example method to add data (conceptual)
  // In a real app, this would involve SQL INSERT statements
  Future<void> addMember(Map<String, dynamic> memberData) async {
    if (_connection.isClosed) {
      print('Database connection is closed. Reopening...');
      await initialize();
    }
    // Example: INSERT INTO members (membername, email, join_date) VALUES (@name, @email, @join_date);
    // This is placeholder for prepared statements
    await _connection.query(
      'INSERT INTO members (membername, email, join_date) VALUES (@membername, @email, @join_date)',
      substitutionValues: {
        'membername': memberData['membername'],
        'email': memberData['email'],
        'join_date': DateTime.parse(
          memberData['join_date'],
        ), // Convert string back to DateTime
      },
    );
    print('Member added to database.');
  }
}

  /** 
  // Payment CRUD operations
  Future<List<Payment>> getPayments(int memberId) async {
    final results = await _connection.query(
      'SELECT * FROM payments WHERE member_id = @memberId ORDER BY payment_date DESC',
      substitutionValues: {'memberId': memberId},
    );
    return results.map((row) => Payment.fromMap(row.toColumnMap())).toList();
  }

  Future<void> addPayment(Payment payment) async {
    await _connection.query(
      'INSERT INTO payments (member_id, amount, payment_date, payment_method, period_start, period_end, notes) '
      'VALUES (@memberId, @amount, @paymentDate, @paymentMethod, @periodStart, @periodEnd, @notes)',
      substitutionValues: payment.toMap(),
    );
  }

  // Attendance CRUD operations
  Future<List<Attendance>> getAttendanceRecords(int memberId) async {
    final results = await _connection.query(
      'SELECT * FROM attendance WHERE member_id = @memberId ORDER BY date DESC',
      substitutionValues: {'memberId': memberId},
    );
    return results.map((row) => Attendance.fromMap(row.toColumnMap())).toList();
  }

  Future<void> markAttendance(Attendance attendance) async {
    await _connection.query(
      'INSERT INTO attendance (member_id, date, check_in, check_out, status) '
      'VALUES (@memberId, @date, @checkIn, @checkOut, @status)',
      substitutionValues: attendance.toMap(),
    );
  }

  // Close connection when done
  Future<void> close() async {
    await _connection.close();
  }
}
*/

