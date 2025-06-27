import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/member.dart';
import 'package:societas/providers/member_provider.dart';
import 'package:societas/screens/members/member_edit.dart';

class MemberDetailPage extends StatelessWidget {
  final Member member;

  const MemberDetailPage({super.key, required this.member});

  void _editMember(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemberEditPage(member: member)),
    );
  }

  Future<void> _deleteMember(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Member'),
        content: Text(
          'Are you sure you want to delete "${member.membername}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Provider.of<MemberProvider>(
          context,
          listen: false,
        ).deleteMember(member.id!);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Member deleted')));

        Navigator.pop(context); // Go back to list
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete member')));
      }
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(date);
      return DateFormat.yMMMMd().format(parsed); // Example: June 23, 2025
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.membername),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editMember(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteMember(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    member.profilepicture != null &&
                        member.profilepicture!.isNotEmpty
                    ? NetworkImage(member.profilepicture!)
                    : null,
                child:
                    member.profilepicture == null ||
                        member.profilepicture!.isEmpty
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Name: ${member.membername}'),
            Text('Email: ${member.email ?? '-'}'),
            Text('Phone: ${member.phone ?? '-'}'),
            Text('Position: ${member.position ?? '-'}'),
            Text('Status: ${member.status}'),
            Text('DOB: ${_formatDate(member.dateofbirth as String?)}'),
            Text('Occupation: ${member.occupation ?? '-'}'),
            Text('Other Skills: ${member.otherskills ?? '-'}'),
            Text('Address: ${member.memberaddress ?? '-'}'),
            const SizedBox(height: 10),
            Text(
              'Emergency Contact:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: ${member.emergencycontactname ?? '-'}'),
            Text('Phone: ${member.emergencycontactphone ?? '-'}'),
            Text('Relationship: ${member.emergencycontactrelationship ?? '-'}'),
            const SizedBox(height: 16),
            Text('Join Date: ${_formatDate(member.joindate as String?)}'),
          ],
        ),
      ),
    );
  }
}
