import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:societas/models/turnout.dart';

class TurnoutCrudScreen extends StatefulWidget {
  const TurnoutCrudScreen({super.key});

  @override
  _TurnoutCrudScreenState createState() => _TurnoutCrudScreenState();
}

class _TurnoutCrudScreenState extends State<TurnoutCrudScreen> {
  List<Turnout> _turnouts = [];
  bool _isLoading = true;

  final _baseUrl = 'http://your-api-url.com/turnout';

  @override
  void initState() {
    super.initState();
    _fetchTurnouts();
  }

  Future<void> _fetchTurnouts() async {
    setState(() => _isLoading = true);
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _turnouts = data.map((e) => Turnout.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      _showError('Failed to load turnouts');
    }
  }

  Future<void> _addOrEditTurnout({Turnout? existing}) async {
    final formKey = GlobalKey<FormState>();
    String name = existing?.name ?? '';
    String description = existing?.description ?? '';
    DateTime? eventdate = existing?.eventdate;
    String location = existing?.location ?? '';
    String status = existing?.status ?? 'upcoming';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Turnout' : 'Edit Turnout'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(labelText: 'Name'),
                      onSaved: (val) => name = val ?? '',
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      initialValue: description,
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (val) => description = val ?? '',
                    ),
                    TextFormField(
                      initialValue: location,
                      decoration: InputDecoration(labelText: 'Location'),
                      onSaved: (val) => location = val ?? '',
                    ),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: InputDecoration(labelText: 'Status'),
                      items: ['upcoming', 'completed', 'cancelled'].map((val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => status = val ?? 'upcoming'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: eventdate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => eventdate = picked);
                      },
                      child: Text(
                        eventdate == null
                            ? 'Pick Event Date'
                            : 'Event Date: ${eventdate!.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate() || eventdate == null) {
                return;
              }
              formKey.currentState!.save();

              final turnout = Turnout(
                id: existing?.id,
                name: name,
                description: description,
                eventdate: eventdate!,
                location: location,
                status: status,
                attendance: null,
              );

              final uri = existing == null
                  ? Uri.parse(_baseUrl)
                  : Uri.parse('$_baseUrl/${existing.id}');
              final method = existing == null ? http.post : http.put;

              final response = await method(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: json.encode(turnout.toJson()),
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                _fetchTurnouts();
              } else {
                _showError('Failed to save');
              }
            },
            child: Text(existing == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTurnout(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Turnout'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _fetchTurnouts();
      } else {
        _showError('Failed to delete');
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turnout Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addOrEditTurnout(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _turnouts.isEmpty
          ? Center(child: Text('No turnouts found.'))
          : ListView.builder(
              itemCount: _turnouts.length,
              itemBuilder: (_, i) {
                final t = _turnouts[i];
                return Card(
                  child: ListTile(
                    title: Text(t.name),
                    subtitle: Text(
                      '${t.eventdate.toLocal().toString().split(' ')[0]} — ${t.status}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _addOrEditTurnout(existing: t),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTurnout(t.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
