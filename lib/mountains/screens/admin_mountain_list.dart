import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../widgets/base_scaffold.dart';
import '../models/mountain.dart';
import 'admin_mountain_form.dart';
import 'package:mounttrack_mobile/config.dart';

class AdminMountainListPage extends StatefulWidget {
  const AdminMountainListPage({super.key});

  @override
  State<AdminMountainListPage> createState() => _AdminMountainListPageState();
}

class _AdminMountainListPageState extends State<AdminMountainListPage> {
  List<Mountain> _mountains = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  static const cafeNoir = Color(0xFF4C3D19);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);

  @override
  void initState() {
    super.initState();
    _fetchMountains();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMountains() async {
    setState(() => _isLoading = true);
    
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        '${AppConfig.baseUrl}/mountains/api/mountains/',
      );
      
      if (response != null && response['mountains'] != null) {
        final List<dynamic> mountainsJson = response['mountains'];
        setState(() {
          _mountains = mountainsJson.map((json) => Mountain.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading mountains: $e')),
        );
      }
    }
  }

  Future<void> _deleteMountain(Mountain mountain) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mountain'),
        content: Text('Are you sure you want to delete ${mountain.name}?'),
        backgroundColor: bone,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: cafeNoir)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '${AppConfig.baseUrl}/mountains/api/delete/${mountain.id}/',
        {},
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: kombuGreen,
            ),
          );
          _fetchMountains();
        } else if (response['status'] == 'error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete mountain'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToForm({Mountain? mountain}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminMountainFormPage(mountain: mountain),
      ),
    );

    if (result == true) {
      _fetchMountains();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Admin - Manage Mountains',
      backgroundColor: bone,
      appBarBackgroundColor: kombuGreen,
      appBarElevation: 0,
      appBarIconTheme: const IconThemeData(color: bone),
      titleTextStyle: const TextStyle(
        color: bone,
        fontWeight: FontWeight.bold,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Main Content
                Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search mountains...',
                          prefixIcon: const Icon(Icons.search, color: kombuGreen),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: tan),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: tan),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: kombuGreen, width: 2),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),

                    // Mountain List
                    Expanded(
                      child: _mountains.isEmpty
                          ? const Center(
                              child: Text(
                                'No mountains found',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 80, // Space for FAB
                              ),
                              itemCount: _mountains.where((m) {
                                final query = _searchController.text.toLowerCase();
                                return query.isEmpty ||
                                    m.name.toLowerCase().contains(query) ||
                                    m.province.toLowerCase().contains(query);
                              }).length,
                              itemBuilder: (context, index) {
                                final filteredMountains = _mountains.where((m) {
                                  final query = _searchController.text.toLowerCase();
                                  return query.isEmpty ||
                                      m.name.toLowerCase().contains(query) ||
                                      m.province.toLowerCase().contains(query);
                                }).toList();
                                final mountain = filteredMountains[index];

                                return Card(
                                  color: bone,
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: tan, width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Mountain Name
                                        Text(
                                          mountain.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: kombuGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Info Row
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: cafeNoir),
                                            const SizedBox(width: 4),
                                            Text(mountain.province),
                                            const SizedBox(width: 16),
                                            Icon(Icons.height, size: 16, color: cafeNoir),
                                            const SizedBox(width: 4),
                                            Text('${mountain.heightMdpl} mdpl'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Status Badge
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: mountain.availability
                                                    ? kombuGreen.withOpacity(0.1)
                                                    : Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                mountain.availability ? 'Available' : 'Closed',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: mountain.availability
                                                      ? kombuGreen
                                                      : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: mossGreen.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                mountain.experienceRequired,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: mossGreen,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Action Buttons
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () => _navigateToForm(mountain: mountain),
                                              icon: const Icon(Icons.edit, size: 18),
                                              label: const Text('Edit'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: kombuGreen,
                                                side: const BorderSide(color: kombuGreen),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton.icon(
                                              onPressed: () => _deleteMountain(mountain),
                                              icon: const Icon(Icons.delete, size: 18),
                                              label: const Text('Delete'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                
                // Floating Action Button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () => _navigateToForm(),
                    backgroundColor: kombuGreen,
                    foregroundColor: bone,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Mountain'),
                  ),
                ),
              ],
            ),
    );
  }
}
