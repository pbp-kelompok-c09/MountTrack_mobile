import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../widgets/base_scaffold.dart';
import '../models/mountain.dart';
import 'package:mounttrack_mobile/config.dart';

class AdminMountainFormPage extends StatefulWidget {
  final Mountain? mountain; // null = create mode, non-null = edit mode

  const AdminMountainFormPage({super.key, this.mountain});

  @override
  State<AdminMountainFormPage> createState() => _AdminMountainFormPageState();
}

class _AdminMountainFormPageState extends State<AdminMountainFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _heightController = TextEditingController();
  final _provinceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minBookController = TextEditingController();

  bool _availability = true;
  String _experienceRequired = 'Beginner';
  bool _isLoading = false;

  final List<String> _experienceLevels = ['Beginner', 'Intermediate', 'Advanced'];
  
  static const cafeNoir = Color(0xFF4C3D19);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);

  @override
  void initState() {
    super.initState();
    if (widget.mountain != null) {
      // Edit mode - populate fields
      _nameController.text = widget.mountain!.name;
      _urlController.text = widget.mountain!.url;
      _heightController.text = widget.mountain!.heightMdpl.toString();
      _provinceController.text = widget.mountain!.province;
      _imageUrlController.text = widget.mountain!.imageUrl;
      _descriptionController.text = widget.mountain!.description;
      _minBookController.text = widget.mountain!.minBook.toString();
      _availability = widget.mountain!.availability;
      _experienceRequired = widget.mountain!.experienceRequired;
    } else {
      // Create mode - set defaults
      _minBookController.text = '1';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _heightController.dispose();
    _provinceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _minBookController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    final isEditMode = widget.mountain != null;
    
    final endpoint = isEditMode
        ? '${AppConfig.baseUrl}/mountains/api/edit/${widget.mountain!.id}/'
        : '${AppConfig.baseUrl}/mountains/api/create/';

    try {
      final response = await request.postJson(
        endpoint,
        {
          'name': _nameController.text.trim(),
          'url': _urlController.text.trim(),
          'height_mdpl': int.parse(_heightController.text.trim()),
          'province': _provinceController.text.trim(),
          'image_url': _imageUrlController.text.trim(),
          'description': _descriptionController.text.trim(),
          'availability': _availability,
          'min_book': int.parse(_minBookController.text.trim()),
          'experience_required': _experienceRequired,
        },
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: kombuGreen,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (response['status'] == 'error') {
          // Handle validation errors
          String errorMessage = response['message'] ?? 'Unknown error occurred';
          
          if (response['errors'] != null) {
            final errors = response['errors'] as Map<String, dynamic>;
            errorMessage = errors.entries
                .map((e) => '${e.key}: ${e.value.join(", ")}')
                .join('\n');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        String errorMsg = 'Error: $e';
        if (e.toString().contains('403')) {
          errorMsg = 'Access Denied: You do not have permission to perform this action.';
        } else if (e.toString().contains('500')) {
          errorMsg = 'Server error occurred. Please try again later.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.mountain != null;
    
    return BaseScaffold(
      title: isEditMode ? 'Edit Mountain' : 'Add Mountain',
      backgroundColor: bone,
      appBarBackgroundColor: kombuGreen,
      appBarElevation: 0,
      appBarIconTheme: const IconThemeData(color: bone),
      titleTextStyle: const TextStyle(
        color: bone,
        fontWeight: FontWeight.bold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mountain Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Mountain Name *',
                  labelStyle: const TextStyle(color: kombuGreen),
                  hintText: 'e.g., Gunung Merapi',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mountain name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reference URL
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Reference URL *',
                  labelStyle: const TextStyle(color: kombuGreen),
                  hintText: 'https://example.com/mountain-info',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Reference URL is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Height and Province Row
              Row(
                children: [
                  // Height
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Height (mdpl) *',
                        labelStyle: const TextStyle(color: kombuGreen),
                        hintText: '2930',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Height is required';
                        }
                        final height = int.tryParse(value);
                        if (height == null || height <= 0) {
                          return 'Height must be > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Min Book Days
                  Expanded(
                    child: TextFormField(
                      controller: _minBookController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Min Booking Days *',
                        labelStyle: const TextStyle(color: kombuGreen),
                        hintText: '1',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Min booking is required';
                        }
                        final minBook = int.tryParse(value);
                        if (minBook == null || minBook < 1) {
                          return 'Must be >= 1';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Province
              TextFormField(
                controller: _provinceController,
                decoration: InputDecoration(
                  labelText: 'Province *',
                  labelStyle: const TextStyle(color: kombuGreen),
                  hintText: 'e.g., Jawa Tengah',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Province is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL (Optional)',
                  labelStyle: const TextStyle(color: kombuGreen),
                  hintText: 'https://example.com/image.jpg',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  labelStyle: const TextStyle(color: kombuGreen),
                  hintText: 'Enter detailed description of the mountain...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Experience Level Dropdown
              DropdownButtonFormField<String>(
                value: _experienceRequired,
                decoration: InputDecoration(
                  labelText: 'Experience Required *',
                  labelStyle: const TextStyle(color: kombuGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                items: _experienceLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _experienceRequired = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Availability Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: tan),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CheckboxListTile(
                  title: const Text('Available for Booking'),
                  value: _availability,
                  activeColor: kombuGreen,
                  onChanged: (value) {
                    setState(() {
                      _availability = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kombuGreen,
                    foregroundColor: bone,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditMode ? 'Update Mountain' : 'Create Mountain',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
