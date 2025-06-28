// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societas/providers/member_provider.dart';
import 'package:societas/providers/theme_provider.dart';
import 'package:societas/screens/members/member_add.dart';
import 'package:societas/screens/members/member_details.dart';

class MemberViewPage extends StatefulWidget {
  const MemberViewPage({super.key});

  @override
  _MemberViewPageState createState() => _MemberViewPageState();
}

class _MemberViewPageState extends State<MemberViewPage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _perPage = 10;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load members: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List filteredMembers(List members) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return members;

    return members
        .where((m) => m.membername.toLowerCase().contains(query))
        .toList();
  }

  List paginatedMembers(List allMembers) {
    final start = (_currentPage - 1) * _perPage;
    final end = (_currentPage * _perPage).clamp(0, allMembers.length);
    return allMembers.sublist(start, end);
  }

  void _nextPage(int total) {
    if (_currentPage * _perPage < total) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  void _navigateToAddMember(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MemberAddPage()),
    ).then((_) => _loadMembers());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<MemberProvider>(context);
    final allMembers = filteredMembers(provider.members);
    final visibleMembers = paginatedMembers(allMembers);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddMember(context),
            tooltip: 'Add new member',
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
            tooltip: isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _currentPage = 1;
                });
              },
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    ElevatedButton(
                      onPressed: _loadMembers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (provider.members.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No members found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _navigateToAddMember(context),
                      child: const Text('Add New Member'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMembers,
                child: ListView.builder(
                  itemCount: visibleMembers.length,
                  itemBuilder: (context, index) {
                    final member = visibleMembers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              member.profilepicture != null &&
                                  member.profilepicture!.isNotEmpty
                              ? NetworkImage(member.profilepicture!)
                              : const AssetImage('assets/default_user.png')
                                    as ImageProvider,
                        ),
                        title: Text(member.membername),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${member.status}'),
                            if (member.position != null)
                              Text('Position: ${member.position}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberDetailPage(member: member),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          if (allMembers.length > _perPage)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _prevPage,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Page $_currentPage of ${(allMembers.length / _perPage).ceil()}',
                  ),
                  IconButton(
                    onPressed: () => _nextPage(allMembers.length),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMember(context),
        child: const Icon(Icons.add),
        tooltip: 'Add new member',
      ),
    );
  }
}
