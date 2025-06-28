import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/member.dart';
import 'package:societas/providers/member_provider.dart';

class MemberAddPage extends StatefulWidget {
  const MemberAddPage({super.key});

  @override
  State<MemberAddPage> createState() => _MemberAddPageState();
}

class _MemberAddPageState extends State<MemberAddPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _membershipTypeController =
      TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyRelationshipController =
      TextEditingController();

  // Default values
  MemberStatus _selectedStatus = MemberStatus.active;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _skillsController.dispose();
    _membershipTypeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationshipController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    // Parse date safely
    DateTime? parsedDate;
    if (_dobController.text.isNotEmpty) {
      parsedDate = DateTime.tryParse(_dobController.text);
      if (parsedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date format. Please use YYYY-MM-DD'),
          ),
        );
        return;
      }
    }

    final newMember = Member(
      id: null, // Will be assigned by the database
      membername: _nameController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      position: _positionController.text.isEmpty
          ? null
          : _positionController.text,
      memberaddress: _addressController.text.isEmpty
          ? null
          : _addressController.text,
      dateofbirth: parsedDate,
      occupation: _occupationController.text.isEmpty
          ? null
          : _occupationController.text,
      otherskills: _skillsController.text.isEmpty
          ? null
          : _skillsController.text,
      status: _selectedStatus,
      membershiptype: _membershipTypeController.text,
      emergencycontactname: _emergencyNameController.text.isEmpty
          ? null
          : _emergencyNameController.text,
      emergencycontactphone: _emergencyPhoneController.text.isEmpty
          ? null
          : _emergencyPhoneController.text,
      emergencycontactrelationship:
          _emergencyRelationshipController.text.isEmpty
          ? null
          : _emergencyRelationshipController.text,
      joindate: DateTime.now(), // Set current date as join date
      profilepicture: null, // Can add profile picture handling if needed
    );

    setState(() => _isSubmitting = true);

    try {
      await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).addMember(newMember);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add member: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Member')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),

              // Personal Details
              const SizedBox(height: 24),
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      DateTime.tryParse(value) == null) {
                    return 'Invalid date format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Other Skills',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              // Membership Info
              const SizedBox(height: 24),
              const Text(
                'Membership Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MemberStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status*',
                  border: OutlineInputBorder(),
                ),
                items: MemberStatus.values.map((status) {
                  return DropdownMenuItem<MemberStatus>(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (MemberStatus? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _membershipTypeController,
                decoration: const InputDecoration(
                  labelText: 'Membership Type*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),

              // Emergency Contact
              const SizedBox(height: 24),
              const Text(
                'Emergency Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emergencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emergencyRelationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
              ),

              // Submit Button
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveMember,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Add Member', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
