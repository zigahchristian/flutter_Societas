import 'package:flutter/material.dart'; // Ensure this path is correct
import 'package:societas/models/member.dart'; // Ensure this path is correct
import 'package:intl/intl.dart'; // For date formatting, add intl to pubspec.yaml

class MemberAddPage extends StatefulWidget {
  const MemberAddPage({super.key});

  @override
  State<MemberAddPage> createState() => _MemberAddPageState();
}

class _MemberAddPageState extends State<MemberAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _otherSkillsController = TextEditingController();
  final TextEditingController _profilePictureController =
      TextEditingController();
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _emergencyContactPhoneController =
      TextEditingController();
  final TextEditingController _emergencyContactRelationshipController =
      TextEditingController();

  DateTime? _dateofbirth;
  DateTime? _joindate = DateTime.now(); // Default to current date

  String? _membershiptype;
  final MemberStatus _status = 'active' as MemberStatus; // Default status

  final List<String> _membershiptypes = ['Standard', 'Premium', 'VIP', 'Guest'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _occupationController.dispose();
    _otherSkillsController.dispose();
    _profilePictureController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {required bool isDOB}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDOB ? (_dateofbirth ?? DateTime.now()) : _joindate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Allow slightly future for join date if needed
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.yellow.shade200, // Header background
              onPrimary: Colors.white, // Header text color
              onSurface: Theme.of(
                context,
              ).colorScheme.onSurface, // Calendar text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.yellow.shade200, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDOB) {
          _dateofbirth = picked;
        } else {
          _joindate = picked;
        }
      });
    }
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved on each form field

      final newMember = Member(
        membername: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        position: _positionController.text.isEmpty
            ? null
            : _positionController.text,
        dateofbirth: _dateofbirth,
        occupation: _occupationController.text.isEmpty
            ? null
            : _occupationController.text,
        otherskills: _otherSkillsController.text.isEmpty
            ? null
            : _otherSkillsController.text,
        profilepicture: _profilePictureController.text.isEmpty
            ? null
            : _profilePictureController.text,
        emergencycontactname: _emergencyContactNameController.text.isEmpty
            ? null
            : _emergencyContactNameController.text,
        emergencycontactphone: _emergencyContactPhoneController.text.isEmpty
            ? null
            : _emergencyContactPhoneController.text,
        emergencycontactrelationship:
            _emergencyContactRelationshipController.text.isEmpty
            ? null
            : _emergencyContactRelationshipController.text,
        joindate: _joindate as DateTime,
        membershiptype: _membershiptype as String,
        status: _status,
      );

      // For demonstration, print the new member's details
      // In a real app, you would send this to a database (e.g., Firestore)
      print('New Member Added:');
      print('Name: ${newMember.membername}');
      print('Email: ${newMember.email}');
      print('Join Date: ${newMember.joindate}');
      print('Status: ${newMember.status}');

      // Optionally, show a success message and pop the page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member "${newMember.membername}" added!'),
          backgroundColor: Colors.blue.shade200, // Use custom green for success
        ),
      );
      Navigator.of(context).pop(); // Go back to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Member', style: textTheme.titleLarge),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Member Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter member name';
                  }
                  return null;
                },
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                keyboardType: TextInputType.emailAddress,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                keyboardType: TextInputType.phone,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Date of Birth: ${_dateofbirth == null ? 'Not set' : DateFormat('dd/MM/yyyy').format(_dateofbirth!)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: colorScheme.secondary,
                ),
                onTap: () => _selectDate(context, isDOB: true),
                tileColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupationController,
                decoration: InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otherSkillsController,
                decoration: InputDecoration(
                  labelText: 'Other Skills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                maxLines: 3,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profilePictureController,
                decoration: InputDecoration(
                  labelText: 'Profile Picture URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                keyboardType: TextInputType.url,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Emergency Contact Information',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const Divider(),
              TextFormField(
                controller: _emergencyContactNameController,
                decoration: InputDecoration(
                  labelText: 'Emergency Contact Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyContactPhoneController,
                decoration: InputDecoration(
                  labelText: 'Emergency Contact Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                keyboardType: TextInputType.phone,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyContactRelationshipController,
                decoration: InputDecoration(
                  labelText: 'Emergency Contact Relationship',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Join Date: ${DateFormat('dd/MM/yyyy').format(_joindate!)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: colorScheme.secondary,
                ),
                onTap: () => _selectDate(context, isDOB: false),
                tileColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _membershiptype,
                decoration: InputDecoration(
                  labelText: 'Membership Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                items: _membershiptypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _membershiptype = value;
                  });
                },
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              // DropdownButtonFormField<String>(
              //   value: _status,
              //   decoration: InputDecoration(
              //     labelText: 'Status *',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     filled: true,
              //     fillColor: colorScheme.surface,
              //   ),
              // //   items: statuses.map((status) {
              // //     return DropdownMenuItem(
              // //       value: status,
              // //       child: Text(
              // //         status,
              // //         style: textTheme.bodyMedium?.copyWith(
              // //           color: colorScheme.onSurface,
              // //         ),
              // //       ),
              // //     );
              // //   }).toList(),
              // //   onChanged: (value) {
              // //     setState(() {
              // //       _status = value!;
              // //     });
              // //   },
              // //   validator: (value) {
              // //     if (value == null || value.isEmpty) {
              // //       return 'Please select a status';
              // //     }
              // //     return null;
              // //   },
              // //   style: textTheme.bodyMedium?.copyWith(
              // //     color: colorScheme.onSurface,
              // //   ),
              // // ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .yellow
                      .shade200, // Use custom green for save button
                  foregroundColor:
                      colorScheme.onPrimary, // Text on green button
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Save Member',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
