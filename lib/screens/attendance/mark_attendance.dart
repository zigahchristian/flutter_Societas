import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:societas/models/attendance.dart';
import 'package:societas/models/turnout.dart';

class AddAttendanceScreen extends StatefulWidget {
  const AddAttendanceScreen({super.key});

  @override
  _AddAttendanceScreenState createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Turnout> _turnouts = [];
  Turnout? _selectedTurnout;

  // Form values
  String? _memberid;
  String _turnoutStatus = 'Present';
  bool _participation = true;
  String? _remarks;

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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedTurnout == null) return;
    _formKey.currentState!.save();

    final attendance = Attendance(
      id: '', // Server will generate this
      memberid: _memberid!,
      date: _selectedTurnout!.eventdate,
      turnout: _turnoutStatus,
      participation: _participation,
      remarks: _remarks,
    );

    final response = await http.post(
      Uri.parse('http://your-api-url.com/attendance'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(attendance.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Attendance added successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save attendance')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _turnouts.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
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
                      onChanged: (val) =>
                          setState(() => _selectedTurnout = val),
                      validator: (value) =>
                          value == null ? 'Please select a turnout' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Member ID'),
                      onSaved: (val) => _memberid = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Member ID is required'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Turnout Status'),
                      value: _turnoutStatus,
                      items: ['Present', 'Absent', 'Late'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _turnoutStatus = val!),
                    ),
                    SwitchListTile(
                      title: Text('Participated'),
                      value: _participation,
                      onChanged: (val) => setState(() => _participation = val),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Remarks (Optional)',
                      ),
                      onSaved: (val) => _remarks = val,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit Attendance'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
