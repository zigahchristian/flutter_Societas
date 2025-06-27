import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/member.dart';
import 'package:societas/providers/member_provider.dart';

class MemberEditPage extends StatefulWidget {
  final Member member;

  const MemberEditPage({super.key, required this.member});

  @override
  _MemberEditPageState createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _occupationController;
  late TextEditingController _skillsController;
  late TextEditingController _membershipTypeController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyRelationshipController;

  // Status handling
  late MemberStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with member data
    _nameController = TextEditingController(text: widget.member.membername);
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _phoneController = TextEditingController(text: widget.member.phone ?? '');
    _positionController = TextEditingController(
      text: widget.member.position ?? '',
    );
    _addressController = TextEditingController(
      text: widget.member.memberaddress ?? '',
    );

    // Proper DateTime initialization
    _dobController = TextEditingController(
      text: widget.member.dateofbirth != null
          ? DateFormat('yyyy-MM-dd').format(widget.member.dateofbirth!)
          : '',
    );

    _occupationController = TextEditingController(
      text: widget.member.occupation ?? '',
    );
    _skillsController = TextEditingController(
      text: widget.member.otherskills ?? '',
    );
    _selectedStatus = widget.member.status;
    _membershipTypeController = TextEditingController(
      text: widget.member.membershiptype,
    );
    _emergencyNameController = TextEditingController(
      text: widget.member.emergencycontactname ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: widget.member.emergencycontactphone ?? '',
    );
    _emergencyRelationshipController = TextEditingController(
      text: widget.member.emergencycontactrelationship ?? '',
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
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

  Future<void> _updateMember() async {
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

    final updatedMember = widget.member.copyWith(
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
    );

    setState(() => _isSubmitting = true);

    try {
      await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).updateMember(updatedMember);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update member: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.member.dateofbirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Member')),
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
                  labelText: 'Date of Birth (YYYY-MM-DD)*',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  if (DateTime.tryParse(value) == null) {
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
                onPressed: _isSubmitting ? null : _updateMember,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(
                        'Update Member',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
