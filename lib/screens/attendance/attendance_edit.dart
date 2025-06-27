import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:societas/models/attendance.dart';

class EditAttendanceScreen extends StatefulWidget {
  final Attendance attendance;

  const EditAttendanceScreen({super.key, required this.attendance});

  @override
  _EditAttendanceScreenState createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _turnout;
  late bool _participation;
  String? _remarks;

  @override
  void initState() {
    super.initState();
    _turnout = widget.attendance.turnout;
    _participation = widget.attendance.participation;
    _remarks = widget.attendance.remarks;
  }

  Future<void> _updateAttendance() async {
    final updatedAttendance = Attendance(
      id: widget.attendance.id,
      memberid: widget.attendance.memberid,
      date: widget.attendance.date,
      turnout: _turnout,
      participation: _participation,
      remarks: _remarks,
    );

    try {
      final response = await http.put(
        Uri.parse('http://your-api-url.com/attendance/${widget.attendance.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedAttendance.toJson()),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attendance updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showError(
          'Failed to update attendance (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Editing Attendance for Member: ${widget.attendance.memberid}',
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Turnout Status'),
                value: _turnout,
                items: ['Present', 'Absent', 'Late'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) => setState(() => _turnout = val!),
              ),
              SwitchListTile(
                title: Text('Participated'),
                value: _participation,
                onChanged: (val) => setState(() => _participation = val),
              ),
              TextFormField(
                initialValue: _remarks ?? '',
                decoration: InputDecoration(labelText: 'Remarks (optional)'),
                onSaved: (val) => _remarks = val,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.save();
                  _updateAttendance();
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
