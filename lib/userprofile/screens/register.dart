import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'login.dart';
import '../../widgets/base_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);

  String _selectedCategoryExperience = 'beginner';
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: bone,
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        backgroundColor: kombuGreen,
        foregroundColor: bone,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: bone,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(color: tan),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: kombuGreen,
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // username
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Masukkan username Anda',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mohon isi username Anda.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // nama lengkap
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama asli Anda',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mohon isi nama lengkap Anda.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

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
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mohon isi umur Anda.';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Umur harus berupa angka positif.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // nomor telepon
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: 'Masukkan nomor telepon Anda',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mohon isi nomor telepon Anda.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan email Anda',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mohon isi email Anda.';
                        }
                        final emailRegex =
                            RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Format email tidak valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // category experience
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryExperience,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Pengalaman',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
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
                          child: Text('Pemula (Beginner)'),
                        ),
                        DropdownMenuItem(
                          value: 'intermediate',
                          child: Text('Menengah (Intermediate)'),
                        ),
                        DropdownMenuItem(
                          value: 'advanced',
                          child: Text('Berpengalaman (Advanced)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryExperience = value ?? 'beginner';
                        });
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // jenis kelamin
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon pilih jenis kelamin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // password
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password Anda',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon masukkan password Anda.';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // confirm password
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi password',
                        hintText: 'Ulangi password Anda',
                        labelStyle: TextStyle(color: kombuGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: mossGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: kombuGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon konfirmasi password Anda.';
                        }
                        if (value != _passwordController.text) {
                          return 'Konfirmasi password tidak cocok.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),

                    ElevatedButton(
                      onPressed: () async {
                        // cek semua validator
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        String username = _usernameController.text.trim();
                        String nama = _namaController.text.trim();
                        String umurStr = _umurController.text.trim();
                        String phone = _phoneController.text.trim();
                        String email = _emailController.text.trim();
                        String password1 = _passwordController.text;
                        String password2 = _confirmPasswordController.text;

                        final umur = int.parse(umurStr);

                        final response = await request.postJson(
                          "http://localhost:8000/accounts/registerapp/",
                          jsonEncode({
                            "username": username,
                            "password1": password1,
                            "password2": password2,
                            "nama": nama,
                            "umur": umur,
                            "nomor_telepon": phone,
                            "email": email,
                            "category_experience":
                                _selectedCategoryExperience,
                            "jenis_kelamin": _selectedGender,
                          }),
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: kombuGreen,
                                content: Text(
                                  'Pendaftaran akun sukses!',
                                  style: TextStyle(color: bone),
                                ),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red[700],
                                content: Text(
                                  response['message'] ??
                                      'Pendaftaran akun gagal!',
                                  style:
                                      const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: bone,
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: kombuGreen,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
