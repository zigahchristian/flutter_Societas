import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/turnout.dart';
import 'package:societas/providers/turnout_provider.dart';
import 'package:societas/screens/turnout/turnout_add.dart';
import 'package:intl/intl.dart';

class TurnoutScreen extends StatefulWidget {
  const TurnoutScreen({super.key});

  @override
  State<TurnoutScreen> createState() => _TurnoutScreenState();
}

class _TurnoutScreenState extends State<TurnoutScreen> {
  String _filterType = 'all'; // 'all', 'pending', 'passed'
  String _sortOrder = 'newest'; // 'newest', 'oldest'
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TurnoutProvider>(context, listen: false).fetchTurnouts();
    });
  }

  List<Turnout> _filterAndSortTurnouts(List<Turnout> turnouts) {
    return turnouts.where((t) {
      if (_filterType == 'pending') return t.turnoutDate.isAfter(_now);
      if (_filterType == 'passed') return t.turnoutDate.isBefore(_now);
      return true;
    }).toList()..sort(
      (a, b) => _sortOrder == 'newest'
          ? b.turnoutDate.compareTo(a.turnoutDate)
          : a.turnoutDate.compareTo(b.turnoutDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnouts'),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('All Events'),
                        leading: Radio<String>(
                          value: 'all',
                          groupValue: _filterType,
                          onChanged: (value) {
                            setState(() => _filterType = value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Pending Only'),
                        leading: Radio<String>(
                          value: 'pending',
                          groupValue: _filterType,
                          onChanged: (value) {
                            setState(() => _filterType = value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Passed Only'),
                        leading: Radio<String>(
                          value: 'passed',
                          groupValue: _filterType,
                          onChanged: (value) {
                            setState(() => _filterType = value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Sort button
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Newest First'),
                        leading: Radio<String>(
                          value: 'newest',
                          groupValue: _sortOrder,
                          onChanged: (value) {
                            setState(() => _sortOrder = value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Oldest First'),
                        leading: Radio<String>(
                          value: 'oldest',
                          groupValue: _sortOrder,
                          onChanged: (value) {
                            setState(() => _sortOrder = value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<TurnoutProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.turnouts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchTurnouts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final turnouts = _filterAndSortTurnouts(provider.turnouts);

          if (turnouts.isEmpty) {
            return Center(
              child: Text(
                _filterType == 'pending'
                    ? 'No pending events'
                    : _filterType == 'passed'
                    ? 'No passed events'
                    : 'No events found',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTurnouts(),
            child: ListView.builder(
              itemCount: turnouts.length,
              itemBuilder: (context, index) {
                final turnout = turnouts[index];
                return TurnoutCard(
                  turnout: turnout,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TurnoutDetailsScreen(turnout: turnout),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTurnoutScreen()),
            ).then((_) {
              Provider.of<TurnoutProvider>(
                context,
                listen: false,
              ).fetchTurnouts();
            }),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Turnout Card Widget
class TurnoutCard extends StatelessWidget {
  final Turnout turnout;
  final VoidCallback onTap;

  const TurnoutCard({super.key, required this.turnout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPending = turnout.turnoutDate.isAfter(DateTime.now());
    final daysDifference = turnout.turnoutDate
        .difference(DateTime.now())
        .inDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(turnout.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(turnout.turnoutDate)),
            Row(
              children: [
                Chip(
                  label: Text(isPending ? 'Pending' : 'Passed'),
                  backgroundColor: isPending
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Text(
                  isPending
                      ? 'In ${daysDifference.abs()} days'
                      : '${daysDifference.abs()} days ago',
                ),
              ],
            ),
          ],
        ),
        trailing: turnout.attendees != null
            ? CircleAvatar(child: Text(turnout.attendees.toString()))
            : null,
        onTap: onTap,
      ),
    );
  }
}

// Turnout Details Screen
class TurnoutDetailsScreen extends StatelessWidget {
  final Turnout turnout;

  const TurnoutDetailsScreen({super.key, required this.turnout});

  @override
  Widget build(BuildContext context) {
    final isPending = turnout.turnoutDate.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(turnout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTurnoutScreen(turnout: turnout),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTurnout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailItem(
              icon: Icons.calendar_today,
              title: 'Date',
              value: DateFormat.yMMMMd().format(turnout.turnoutDate),
            ),
            if (turnout.location != null)
              _DetailItem(
                icon: Icons.location_on,
                title: 'Location',
                value: turnout.location!,
              ),
            if (turnout.organizer != null)
              _DetailItem(
                icon: Icons.person,
                title: 'Organizer',
                value: turnout.organizer!,
              ),
            if (turnout.description != null)
              _DetailItem(
                icon: Icons.description,
                title: 'Description',
                value: turnout.description!,
              ),
            Chip(
              label: Text(
                isPending ? 'Pending' : 'Passed',
                style: TextStyle(color: isPending ? Colors.green : Colors.grey),
              ),
              backgroundColor: isPending
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
            ),
            if (turnout.attendees != null)
              _DetailItem(
                icon: Icons.people,
                title: 'Attendees',
                value: turnout.attendees.toString(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTurnout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Turnout'),
        content: const Text('Are you sure you want to delete this turnout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<TurnoutProvider>(
          context,
          listen: false,
        ).deleteTurnout(turnout.id);
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }
}

// Edit Turnout Screen
class EditTurnoutScreen extends StatefulWidget {
  final Turnout turnout;

  const EditTurnoutScreen({super.key, required this.turnout});

  @override
  State<EditTurnoutScreen> createState() => _EditTurnoutScreenState();
}

class _EditTurnoutScreenState extends State<EditTurnoutScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _locationController;
  late final TextEditingController _organizerController;
  late DateTime _selectedDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.turnout.name);
    _descController = TextEditingController(text: widget.turnout.description);
    _locationController = TextEditingController(text: widget.turnout.location);
    _organizerController = TextEditingController(
      text: widget.turnout.organizer,
    );
    _selectedDate = widget.turnout.turnoutDate;
    _selectedStatus = widget.turnout.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    final updatedTurnout = widget.turnout.copyWith(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      turnoutDate: _selectedDate,
      location: _locationController.text.trim(),
      organizer: _organizerController.text.trim(),
      status: _selectedStatus,
    );

    try {
      await Provider.of<TurnoutProvider>(
        context,
        listen: false,
      ).updateTurnout(updatedTurnout);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Turnout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event Name *'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Event Date *'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMMMMd().format(_selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _organizerController,
              decoration: const InputDecoration(labelText: 'Organizer'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'planned', child: Text('Planned')),
                DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Details Screen
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          const Divider(),
        ],
      ),
    );
  }
}
