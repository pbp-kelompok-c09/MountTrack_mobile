import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../config.dart';
import '../community_theme.dart';

class CommunityEventCreatePage extends StatefulWidget {
  const CommunityEventCreatePage({super.key});

  @override
  State<CommunityEventCreatePage> createState() => _CommunityEventCreatePageState();
}

class _CommunityEventCreatePageState extends State<CommunityEventCreatePage> {
  final titleC = TextEditingController();
  final mountainC = TextEditingController();
  final capacityC = TextEditingController(text: "10");
  final priceC = TextEditingController();
  final meetingPointC = TextEditingController();
  final contactC = TextEditingController();
  final descriptionC = TextEditingController();

  DateTime? startAt;
  DateTime? endAt;

  String difficulty = "BEGINNER";
  String status = "OPEN";
  bool _isSubmitting = false;

  // Mapping for display
  final Map<String, String> difficultyMap = {
    'BEGINNER': 'Pemula',
    'INTERMEDIATE': 'Menengah',
    'ADVANCED': 'Berpengalaman',
  };

  final Map<String, String> statusMap = {
    'DRAFT': 'Draf',
    'OPEN': 'Dibuka',
  };

  @override
  void dispose() {
    titleC.dispose();
    mountainC.dispose();
    capacityC.dispose();
    priceC.dispose();
    meetingPointC.dispose();
    contactC.dispose();
    descriptionC.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime({DateTime? initial}) async {
    final base = initial ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: base,
    );
    if (d == null) return null;

    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: base.hour, minute: base.minute));
    if (t == null) return null;

    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  void _submit() async {
    final title = titleC.text.trim();
    final mountain = mountainC.text.trim();
    final contact = contactC.text.trim();
    final desc = descriptionC.text.trim();

    if (title.isEmpty || mountain.isEmpty || contact.isEmpty || startAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul, gunung, kontak, dan start_at wajib diisi.")),
      );
      return;
    }

    final cap = int.tryParse(capacityC.text.trim()) ?? 10;
    if (cap <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Capacity harus > 0")));
      return;
    }

    final pr = priceC.text.trim().isEmpty ? null : int.tryParse(priceC.text.trim());
    final contactInt = int.tryParse(contact);
    if (contactInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nomor kontak harus berupa angka")));
      return;
    }

    final request = context.read<CookieRequest>();
    
    // Check if user is logged in
    if (!request.loggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login terlebih dahulu')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final Map<String, dynamic> data = {
        'title': title,
        'mountain_name': mountain,
        'start_at': startAt!.toIso8601String(),
        'capacity': cap,
        'difficulty': difficulty,
        'meeting_point': meetingPointC.text.trim(),
        'contact_person': contactInt,
        'description': desc,
        'status': status,
      };
      
      if (endAt != null) {
        data['end_at'] = endAt!.toIso8601String();
      }
      if (pr != null) {
        data['price'] = pr;
      }

      print('=== CREATE EVENT DEBUG ===');
      print('URL: ${AppConfig.baseUrl}/community/api/create/');
      print('Data: $data');
      print('Data types:');
      data.forEach((key, value) {
        print('  $key: ${value.runtimeType} = $value');
      });
      
      print('Attempting request with pbp_django_auth...');
      
      // Use the standard post method which sends form data
      final response = await request.post(
        '${AppConfig.baseUrl}/community/api/create/',
        jsonEncode(data),
      );
      
      print('Response received: $response');
      print('Response type: ${response.runtimeType}');

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (response['status'] == 'success' || response['success'] == true) {
          print('Event created successfully!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event berhasil dibuat!')),
          );
          print('Popping back to event list...');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          print('Error creating event: ${response['message']}');
          final errorMsg = response['message'] ?? response['error'] ?? 'Gagal membuat event';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } catch (e) {
      print('=== ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace:');
      print(StackTrace.current);
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CommunityTheme.theme,
      child: Scaffold(
        appBar: AppBar(title: const Text("Create Event")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              inputField("Judul Event", titleC),
              inputField("Nama Gunung", mountainC),

              _dateTile(
                label: "Mulai",
                value: startAt,
                onPick: () async {
                  final dt = await _pickDateTime(initial: startAt);
                  if (dt != null) setState(() => startAt = dt);
                },
              ),
              _dateTile(
                label: "Berakhir (opsional)",
                value: endAt,
                onPick: () async {
                  final dt = await _pickDateTime(initial: endAt ?? startAt);
                  if (dt != null) setState(() => endAt = dt);
                },
                onClear: endAt == null ? null : () => setState(() => endAt = null),
              ),

              inputField("Kapasitas", capacityC, type: TextInputType.number),
              inputField("Harga (opsional)", priceC, type: TextInputType.number),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Tingkat Kesulitan",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: difficulty,
                  items: difficultyMap.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  )).toList(),
                  onChanged: (v) => setState(() => difficulty = v!),
                ),
              ),

              inputField("Titik Kumpul", meetingPointC),
              inputField("Nomor Kontak (WA/Telp) *", contactC),
              textAreaField("Deskripsi", descriptionC),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: status,
                  items: statusMap.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  )).toList(),
                  onChanged: (v) => setState(() => status = v!),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Create Event"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? value,
    required VoidCallback onPick,
    VoidCallback? onClear,
  }) {
    String two(int x) => x.toString().padLeft(2, '0');
    String fmt(DateTime d) => "${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}";
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onPick,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onClear != null) IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.calendar_month),
                ),
              ],
            ),
          ),
          child: Text(value == null ? "-" : fmt(value)),
        ),
      ),
    );
  }

  Widget inputField(String label, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget textAreaField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
