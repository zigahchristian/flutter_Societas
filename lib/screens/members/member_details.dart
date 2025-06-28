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
        title: const Text('Delete Member'),
        content: Text(
          'Are you sure you want to delete "${member.membername}"?',
        ),
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

    if (confirm == true) {
      try {
        await Provider.of<MemberProvider>(
          context,
          listen: false,
        ).deleteMember(member.id!);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Member deleted')));

        Navigator.pop(context); // Go back to list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete member')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat.yMMMMd().format(date); // Example: June 23, 2025
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.membername),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMember(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
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
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Name: ${member.membername}'),
            Text('Email: ${member.email ?? '-'}'),
            Text('Phone: ${member.phone ?? '-'}'),
            Text('Position: ${member.position ?? '-'}'),
            Text('Status: ${member.status}'),
            Text('DOB: ${_formatDate(member.dateofbirth)}'),
            Text('Occupation: ${member.occupation ?? '-'}'),
            Text('Other Skills: ${member.otherskills ?? '-'}'),
            Text('Address: ${member.memberaddress ?? '-'}'),
            const SizedBox(height: 10),
            const Text(
              'Emergency Contact:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: ${member.emergencycontactname ?? '-'}'),
            Text('Phone: ${member.emergencycontactphone ?? '-'}'),
            Text('Relationship: ${member.emergencycontactrelationship ?? '-'}'),
            const SizedBox(height: 16),
            Text('Join Date: ${_formatDate(member.joindate)}'),
          ],
        ),
      ),
    );
  }
}
