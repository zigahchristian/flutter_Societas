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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member deleted successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete member')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat.yMMMMd().format(date);
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.membername),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _editMember(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () => _deleteMember(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        member.profilepicture != null &&
                            member.profilepicture!.isNotEmpty
                        ? NetworkImage(member.profilepicture!)
                        : null,
                    child:
                        member.profilepicture == null ||
                            member.profilepicture!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.membername,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (member.position != null && member.position!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        member.position!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basic Information Card
            _buildInfoCard('Basic Information', [
              _buildInfoRow('Email', member.email ?? ''),
              _buildInfoRow('Phone', member.phone ?? ''),
              _buildInfoRow('Status', member.status.toString()),
              _buildInfoRow('Date of Birth', _formatDate(member.dateofbirth)),
              _buildInfoRow('Occupation', member.occupation ?? ''),
              _buildInfoRow('Skills', member.otherskills ?? ''),
              _buildInfoRow('Address', member.memberaddress ?? ''),
              _buildInfoRow('Join Date', _formatDate(member.joindate)),
            ]),

            // Emergency Contact Card
            _buildInfoCard('Emergency Contact', [
              _buildInfoRow('Name', member.emergencycontactname ?? ''),
              _buildInfoRow('Phone', member.emergencycontactphone ?? ''),
              _buildInfoRow(
                'Relationship',
                member.emergencycontactrelationship ?? '',
              ),
            ]),

            // Additional Actions
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                    onPressed: member.phone != null && member.phone!.isNotEmpty
                        ? () {} // Implement call functionality
                        : null,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.email, size: 18),
                    label: const Text('Email'),
                    onPressed: member.email != null && member.email!.isNotEmpty
                        ? () {} // Implement email functionality
                        : null,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Message'),
                    onPressed: member.phone != null && member.phone!.isNotEmpty
                        ? () {} // Implement messaging functionality
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
