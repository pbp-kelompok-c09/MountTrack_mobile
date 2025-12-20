import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import 'package:mounttrack_mobile/config.dart';

class NewsFormPage extends StatefulWidget {
  final NewsEntry? news;

  const NewsFormPage({super.key, this.news});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();
  final List<TextEditingController> _additionalImageControllers = [];

  bool _isLoading = false;

  // --- PALET WARNA ALAM ---
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const sacramento = Color(0xFF102114);
  static const tangerine = Color(0xFFEB3D00);

  @override
  void initState() {
    super.initState();
    // Mode Edit: Isi data
    if (widget.news != null) {
      _titleController.text = widget.news!.title;
      _contentController.text = widget.news!.content;
      _thumbnailController.text = widget.news!.pinnedThumbnail ?? "";

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

  // Helper untuk Style Text Field ala ProKit
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: kombuGreen),
      validator: validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(
          0.6,
        ), // Transparan dikit biar blend sama bone
        hintText: hint,
        hintStyle: TextStyle(color: kombuGreen.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Clean look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kombuGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: tangerine, width: 1.5),
        ),
      ),
    );
  }

  // Helper untuk Label Text
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: kombuGreen,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isEditMode = widget.news != null;
    final String pageTitle = isEditMode ? "Edit Article" : "Create New Article";
    final String buttonText = isEditMode ? "Save Changes" : "Publish Article";

    return Scaffold(
      backgroundColor: bone, // Warna dasar
      appBar: AppBar(
        backgroundColor: bone,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kombuGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          pageTitle,
          style: const TextStyle(
            color: kombuGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. THUMBNAIL (Cover Image) ---
              // Dibuat mirip container putus-putus di referensi, tapi untuk input URL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tan.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kombuGreen,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      color: kombuGreen,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Article Cover URL",
                      style: TextStyle(
                        color: kombuGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _thumbnailController,
                      hint: "Paste image URL here (Optional)",
                      // Validator dihapus/return null sesuai request sebelumnya
                      validator: (val) => null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. TITLE ---
              _buildLabel('Title'),
              _buildTextField(
                controller: _titleController,
                hint: 'Write a Title',
                validator: (val) =>
                    val!.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 24),

              // --- 3. CONTENT ---
              _buildLabel('Write Article'),
              _buildTextField(
                controller: _contentController,
                hint: 'Write something here...',
                maxLines: 8,
                validator: (val) =>
                    val!.isEmpty ? 'Content cannot be empty' : null,
              ),
              const SizedBox(height: 24),

              // --- 4. ADDITIONAL IMAGES (Dynamic List) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Gallery Images'),
                  // Tombol Tambah (Kecil)
                  InkWell(
                    onTap: _addParamField,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mossGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Add Image",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // List Gambar Tambahan
              if (_additionalImageControllers.isEmpty)
                Text(
                  "No additional images added.",
                  style: TextStyle(
                    color: kombuGreen.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),

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
                          child: _buildTextField(
                            controller: _additionalImageControllers[index],
                            hint: "Image URL ${index + 1}",
                            validator: (val) =>
                                val!.isEmpty ? 'URL cannot be empty' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Hapus (Merah/Tangerine)
                        InkWell(
                          onTap: () => _removeParamField(index),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: tangerine.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: tangerine,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- 5. SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56, // Tinggi tombol ala UI Kit
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _submitForm(request, isEditMode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kombuGreen,
                    foregroundColor: bone,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: bone)
                      : Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIKA SUBMIT TERPISAH (Agar kode build lebih bersih) ---
  Future<void> _submitForm(CookieRequest request, bool isEditMode) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    List<String> additionalImages = _additionalImageControllers
        .map((c) => c.text)
        .toList();

    // Tentukan URL
    String url;
    if (isEditMode) {
      url = "${AppConfig.baseUrl}/news/edit-flutter/${widget.news!.id}/";
    } else {
      url = "${AppConfig.baseUrl}/news/create-flutter/";
    }

    try {
      final response = await request.postJson(
        url,
        jsonEncode(<String, dynamic>{
          'title': _titleController.text,
          'content': _contentController.text,
          'pinned_thumbnail': _thumbnailController.text.isEmpty
              ? ""
              : _thumbnailController.text,
          'additional_images': additionalImages,
        }),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? "Changes Saved!" : "Article Published!"),
            backgroundColor: kombuGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response['message']}"),
            backgroundColor: tangerine,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: cafeNoir),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
