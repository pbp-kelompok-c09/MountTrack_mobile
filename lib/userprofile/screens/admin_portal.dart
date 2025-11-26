import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminPortalPage extends StatefulWidget {
  const AdminPortalPage({super.key});

  @override
  State<AdminPortalPage> createState() => _AdminPortalPageState();
}

class _AdminPortalPageState extends State<AdminPortalPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<dynamic> _users = [];

  // form tambah user baru
  final _newUsernameController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _newUsernameController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String? _getCurrentUsername(CookieRequest request) {
    try {
      final data = request.jsonData;
      if (data['username'] != null) {
        return data['username'].toString();
      }
    } catch (_) {
    }
    return null;
  }

  Future<void> _fetchUsers() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await request.get(
        "http://localhost:8000/accounts/admin-portal/get-users/",
      );

      if (response is List) {
        setState(() {
          _users = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format data user tidak sesuai.'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat daftar user.'),
          ),
        );
      }
    }
  }

  Future<void> _addUser() async {
    final request = context.read<CookieRequest>();

    final username = _newUsernameController.text.trim();
    final email = _newEmailController.text.trim();
    final password = _newPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password wajib diisi.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await request.postJson(
        "http://localhost:8000/accounts/admin-portal/add-user/",
        jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (!mounted) return;

      if (response['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'].toString()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User baru berhasil ditambahkan.'),
          ),
        );
        _newUsernameController.clear();
        _newEmailController.clear();
        _newPasswordController.clear();
        await _fetchUsers();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menambah user.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _toggleAdmin(String userId, bool isCurrentlyAdmin) async {
    final request = context.read<CookieRequest>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
          isCurrentlyAdmin
              ? 'Yakin ingin menghapus status admin user ini?'
              : 'Yakin ingin menjadikan user ini sebagai admin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await request.postJson(
        "http://localhost:8000/accounts/manage_user_app/",
        jsonEncode({
          "user_id": userId,
          "action": "toggle",
        }),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Status admin diperbarui.'),
          ),
        );
        await _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['error']?.toString() ??
                  response['message']?.toString() ??
                  'Gagal mengubah status admin.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat mengubah status admin.'),
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    final request = context.read<CookieRequest>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await request.postJson(
        "http://localhost:8000/accounts/manage_user_app/",
        jsonEncode({
          "user_id": userId,
          "action": "delete",
        }),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'User dihapus.'),
          ),
        );
        await _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['error']?.toString() ??
                  response['message']?.toString() ??
                  'Gagal menghapus user.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menghapus user.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isLoggedIn = request.loggedIn;
    final currentUsername = _getCurrentUsername(request);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
      ),
      body: !isLoggedIn
          ? const Center(
              child: Text('Silakan login sebagai admin terlebih dahulu.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (currentUsername != null)
                    Text(
                      'Login sebagai: $currentUsername',
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 12),

                  // tabel user scrollable
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _users.isEmpty
                            ? const Center(
                                child: Text('Belum ada user.'),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  itemCount: _users.length,
                                  itemBuilder: (context, index) {
                                    final user = _users[index];
                                    final username =
                                        user['username']?.toString() ?? '';
                                    final id = user['id'];
                                    final email =
                                        user['email']?.toString() ?? '';
                                    final isStaff = user['is_staff'] == true;

                                    final isSelf =
                                        (currentUsername != null &&
                                            username == currentUsername);

                                    return ListTile(
                                      title: Text(username),
                                      subtitle: email.isNotEmpty
                                          ? Text(email)
                                          : null,
                                      trailing: isSelf
                                          ? const Text(
                                              '(Diri sendiri)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            )
                                          : Wrap(
                                              spacing: 8,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    _toggleAdmin(
                                                      id,
                                                      isStaff,
                                                    );
                                                  },
                                                  child: Text(
                                                    isStaff
                                                        ? 'Hapus Admin'
                                                        : 'Jadikan Admin',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _deleteUser(
                                                      id,
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  child:
                                                      const Text('Hapus User'),
                                                ),
                                              ],
                                            ),
                                    );
                                  },
                                ),
                              ),
                  ),

                  const SizedBox(height: 16),

                  // form tambah user baru
                  const Text(
                    'Tambah User Baru',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newUsernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _addUser,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Tambah User'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
