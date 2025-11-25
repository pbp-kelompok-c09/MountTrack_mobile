import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
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
        "http://localhost:8000/accounts/profileapp/",
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
        "http://localhost:8000/accounts/profileapp/",
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isLoggedIn
              ? const Center(
                  child: Text('Silakan login terlebih dahulu.'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Lengkapi atau ubah data profil Anda',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 16),

                            // info login + tombol admin jika admin
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Login sebagai: $_username',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                if (_isStaff)
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: ganti dengan navigator ke admin portal

                                    },
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
                                      border: OutlineInputBorder(),
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
                                      border: OutlineInputBorder(),
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
                                      border: OutlineInputBorder(),
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
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return null;
                                      }
                                      final emailRegex = RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+');
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
                                      border: OutlineInputBorder(),
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
                                      border: OutlineInputBorder(),
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
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_historyMountains.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Belum ada riwayat pendakian.',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: _historyMountains
                                      .map((m) => Text('• $m'))
                                      .toList(),
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
