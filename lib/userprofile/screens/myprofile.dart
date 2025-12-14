import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mounttrack_mobile/config.dart';
import 'package:mounttrack_mobile/home/screens/main_navigation.dart';
import 'package:mounttrack_mobile/userprofile/screens/admin_portal.dart';
import 'package:mounttrack_mobile/userprofile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  
  final _formKey = GlobalKey<FormState>();

  // field yang bisa diedit
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCategoryExperience = 'beginner';
  String? _selectedGender;

  // info tidak bisa diedit
  String _username = '';
  bool _isStaff = false;
  List<String> _historyMountains = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _umurController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        "${AppConfig.baseUrl}/accounts/profileapp/",
      );

      if (response is Map) {
        setState(() {
          _username = response['username']?.toString() ?? '';

          _namaController.text = response['nama']?.toString() ?? '';
          _umurController.text =
              response['umur'] != null ? response['umur'].toString() : '';
          _phoneController.text =
              response['nomor_telepon']?.toString() ?? '';
          _emailController.text = response['email']?.toString() ?? '';

          _selectedCategoryExperience =
              response['category_experience']?.toString() ?? 'beginner';
          _selectedGender = response['jenis_kelamin']?.toString();

          _isStaff = response['is_staff'] == true;

          final history = response['history_gunung'];
          if (history is List) {
            _historyMountains =
                history.map((e) => e.toString()).toList(growable: false);
          } else {
            _historyMountains = [];
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memuat profil.'),
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
            content: Text('Terjadi kesalahan saat memuat profil.'),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();

    final nama = _namaController.text.trim();
    final umurStr = _umurController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    // validasi umur angka positif
    int? umur;
    if (umurStr.isNotEmpty) {
      umur = int.tryParse(umurStr);
      if (umur == null || umur <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Umur harus berupa angka positif.'),
          ),
        );
        return;
      }
    }

    try {
      final response = await request.postJson(
        "${AppConfig.baseUrl}/accounts/profileapp/",
        jsonEncode({
          "nama": nama,
          "umur": umur,
          "nomor_telepon": phone,
          "email": email,
          "category_experience": _selectedCategoryExperience,
          "jenis_kelamin": _selectedGender,
        }),
      );

      if (!mounted) return;

      final status = response['status'];
      final message = response['message'] ?? 'Perubahan tersimpan.';

      if (status == true || status == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.toString().isNotEmpty
                  ? message.toString()
                  : 'Gagal menyimpan perubahan.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menyimpan profil.'),
        ),
      );
    }
  }
    Future<void> _logout() async {
    final request = context.read<CookieRequest>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(color: cafeNoir),
        ),
        content: const Text(
          'Apakah Anda yakin ingin logout?',
          style: TextStyle(color: cafeNoir),
        ),
        backgroundColor: bone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: kombuGreen),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await request.logout(
        "${AppConfig.baseUrl}/accounts/logoutapp/",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: kombuGreen,
            content: Text(
              response['message'] ?? 'Logged out (no message)',
              style: const TextStyle(color: bone),
            ),
          ),
        );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat logout.'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      backgroundColor: bone,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: kombuGreen,
        foregroundColor: bone,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isLoggedIn
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Silakan login terlebih dahulu.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kombuGreen,
                          foregroundColor: bone,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Card(
                      color: bone,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: const BorderSide(color: tan),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Profil Saya',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: kombuGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Lengkapi atau ubah data profil Anda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: cafeNoir,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // info login + tombol admin jika admin
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Login sebagai: $_username',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: cafeNoir,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_isStaff)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminPortalPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kombuGreen,
                                      foregroundColor: bone,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Ke Admin Portal'),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // grid form + riwayat
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // nama
                                  TextFormField(
                                    controller: _namaController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama Lengkap',
                                      hintText: 'Masukkan nama lengkap Anda',
                                      labelStyle:
                                          TextStyle(color: kombuGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide:
                                            BorderSide(color: mossGreen),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: kombuGreen,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nama tidak boleh kosong.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // umur
                                  TextFormField(
                                    controller: _umurController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Umur',
                                      hintText: 'Masukkan umur Anda',
                                      labelStyle:
                                          TextStyle(color: kombuGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide:
                                            BorderSide(color: mossGreen),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: kombuGreen,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // nomor telepon
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Nomor Telepon',
                                      hintText:
                                          'Masukkan nomor telepon Anda',
                                      labelStyle:
                                          TextStyle(color: kombuGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide:
                                            BorderSide(color: mossGreen),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: kombuGreen,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // email
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Masukkan email Anda',
                                      labelStyle:
                                          TextStyle(color: kombuGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide:
                                            BorderSide(color: mossGreen),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: kombuGreen,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return null;
                                      }
                                      final emailRegex =
                                          RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                      if (!emailRegex
                                          .hasMatch(value.trim())) {
                                        return 'Format email tidak valid.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // kategori pengalaman
                                  DropdownButtonFormField<String>(
                                    value: _selectedCategoryExperience,
                                    decoration: const InputDecoration(
                                      labelText: 'Kategori Pengalaman',
                                      labelStyle:
                                          TextStyle(color: kombuGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide:
                                            BorderSide(color: mossGreen),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: kombuGreen,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'beginner',
                                        child:
                                            Text('Pemula (Beginner)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'intermediate',
                                        child: Text(
                                            'Menengah (Intermediate)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'advanced',
                                        child: Text(
                                            'Berpengalaman (Advanced)'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategoryExperience =
                                            value ?? 'beginner';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // jenis kelamin
                                  DropdownButtonFormField<String>(
                                    value: _selectedGender,
                                    decoration: const InputDecoration(
                                      labelText: 'Jenis Kelamin',
                                      labelStyle:
                                          TextStyle(color: kombuGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide:
                                            BorderSide(color: mossGreen),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: kombuGreen,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'M',
                                        child: Text('Laki-laki'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'F',
                                        child: Text('Perempuan'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'O',
                                        child: Text('Lainnya'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kombuGreen,
                                        foregroundColor: bone,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child:
                                          const Text('Simpan Perubahan'),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // riwayat pendakian
                            const Text(
                              'Riwayat Pendakian',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kombuGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_historyMountains.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: tan),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: const Text(
                                  'Belum ada riwayat pendakian.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: cafeNoir,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: tan),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: _historyMountains
                                      .map((m) => Text(
                                            '• $m',
                                            style: const TextStyle(
                                              color: cafeNoir,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),

                            const SizedBox(height: 24),
                            // tombol logout
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Logout'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
