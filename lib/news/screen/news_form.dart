import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart'; // Import model

class NewsFormPage extends StatefulWidget {
  // Tambahkan parameter opsional untuk mode edit
  final NewsEntry? news;

  const NewsFormPage({Key? key, this.news}) : super(key: key);

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();

  List<TextEditingController> _additionalImageControllers = [];

  final Color _bgBeige = const Color(0xFFE5D7C4);
  final Color _textDarkGreen = const Color(0xFF354024);
  final Color _cardOlive = const Color(0xFF889063);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika widget.news tidak null, berarti ini mode EDIT
    if (widget.news != null) {
      _titleController.text = widget.news!.title;
      _contentController.text = widget.news!.content;
      _thumbnailController.text = widget.news!.pinnedThumbnail ?? "";

      // Isi controller gambar tambahan jika ada
      if (widget.news!.additionalImages != null) {
        for (var imgUrl in widget.news!.additionalImages!) {
          _additionalImageControllers.add(TextEditingController(text: imgUrl));
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    for (var controller in _additionalImageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addParamField() {
    setState(() {
      _additionalImageControllers.add(TextEditingController());
    });
  }

  void _removeParamField(int index) {
    setState(() {
      _additionalImageControllers[index].dispose();
      _additionalImageControllers.removeAt(index);
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textDarkGreen, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: _bgBeige,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _textDarkGreen, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _textDarkGreen, width: 3.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Tentukan Judul Halaman & URL berdasarkan mode
    final bool isEditMode = widget.news != null;
    final String pageTitle = isEditMode ? "Edit Berita" : "Buat Berita Baru";
    final String buttonText = isEditMode ? "Simpan Perubahan" : "Unggah Berita";

    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: _cardOlive,
        foregroundColor: _bgBeige,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            color: _cardOlive,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: _textDarkGreen),
                      decoration: _inputDecoration("Judul Berita"),
                      validator: (val) =>
                          val!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      style: TextStyle(color: _textDarkGreen),
                      decoration: _inputDecoration("Isi Berita"),
                      maxLines: 5,
                      validator: (val) =>
                          val!.isEmpty ? 'Isi berita tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _thumbnailController,
                      style: TextStyle(color: _textDarkGreen),
                      decoration: _inputDecoration("Thumbnail (URL)"),
                      validator: (val) =>
                          val!.isEmpty ? 'Thumbnail tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),

                    // --- Bagian Gambar Tambahan ---
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: _textDarkGreen, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Gambar Tambahan",
                            style: TextStyle(
                              color: _textDarkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: _textDarkGreen, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _additionalImageControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      _additionalImageControllers[index],
                                  style: TextStyle(color: _textDarkGreen),
                                  decoration: _inputDecoration(
                                    "URL Gambar ${index + 1}",
                                  ),
                                  validator: (val) => val!.isEmpty
                                      ? 'URL tidak boleh kosong'
                                      : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeParamField(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    OutlinedButton(
                      onPressed: _addParamField,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _bgBeige,
                        side: BorderSide(color: _textDarkGreen),
                        foregroundColor: _textDarkGreen,
                      ),
                      child: const Text("+ Tambah Gambar Lain"),
                    ),
                    const SizedBox(height: 32),

                    // --- Tombol Submit ---
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);

                                List<String> additionalImages =
                                    _additionalImageControllers
                                        .map((c) => c.text)
                                        .toList();

                                // Tentukan URL endpoint
                                String url;
                                if (isEditMode) {
                                  // Edit Mode: Gunakan ID dari widget.news
                                  url =
                                      "http://localhost:8000/news/edit-flutter/${widget.news!.id}/";
                                } else {
                                  // Create Mode
                                  url =
                                      "http://localhost:8000/news/create-flutter/";
                                }

                                try {
                                  final response = await request.postJson(
                                    url,
                                    jsonEncode(<String, dynamic>{
                                      'title': _titleController.text,
                                      'content': _contentController.text,
                                      'pinned_thumbnail':
                                          _thumbnailController.text,
                                      'additional_images': additionalImages,
                                    }),
                                  );

                                  if (context.mounted) {
                                    if (response['status'] == 'success') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Berita berhasil $buttonText!",
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Gagal: ${response['message']}",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Terjadi kesalahan: $e"),
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _textDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(buttonText),
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
