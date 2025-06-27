import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:societas/models/turnout.dart';
import 'package:societas/models/attendance.dart';

class AttendanceByTurnoutScreen extends StatefulWidget {
  const AttendanceByTurnoutScreen({super.key});

  @override
  _AttendanceByTurnoutScreenState createState() =>
      _AttendanceByTurnoutScreenState();
}

class _AttendanceByTurnoutScreenState extends State<AttendanceByTurnoutScreen> {
  List<Turnout> _turnouts = [];
  List<Attendance> _attendances = [];
  Turnout? _selectedTurnout;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTurnouts();
  }

  Future<void> _fetchTurnouts() async {
    final response = await http.get(
      Uri.parse('http://your-api-url.com/turnout'),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _turnouts = data.map((e) => Turnout.fromJson(e)).toList();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch events')));
    }
  }

  Future<void> _fetchAttendanceForTurnout(String turnoutName) async {
    setState(() => _isLoading = true);

    // Example assumes `turnout` field in attendance matches `Turnout.name`
    final response = await http.get(
      Uri.parse('http://your-api-url.com/attendance?turnout=$turnoutName'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _attendances = data.map((e) => Attendance.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load attendance')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance by Turnout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Turnout>(
              decoration: InputDecoration(labelText: 'Select Turnout'),
              value: _selectedTurnout,
              items: _turnouts.map((turnout) {
                return DropdownMenuItem(
                  value: turnout,
                  child: Text(
                    '${turnout.name} (${turnout.eventdate.toLocal().toString().split(' ')[0]})',
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTurnout = val;
                  _attendances.clear();
                });
                if (val != null) _fetchAttendanceForTurnout(val.name);
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: _attendances.isEmpty
                        ? Text('No attendance records')
                        : ListView.builder(
                            itemCount: _attendances.length,
                            itemBuilder: (ctx, i) {
                              final att = _attendances[i];
                              return Card(
                                child: ListTile(
                                  title: Text('Member: ${att.memberid}'),
                                  subtitle: Text(
                                    'Participation: ${att.participation ? "Yes" : "No"}\nRemarks: ${att.remarks ?? "-"}',
                                  ),
                                  trailing: Text(att.turnout),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
