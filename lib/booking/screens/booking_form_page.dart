import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_navbar.dart';

class BookingFormPage extends StatefulWidget {
  final String mountainId;
  final String mountainName;

  const BookingFormPage({
    super.key,
    required this.mountainId,
    required this.mountainName,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  late int _pax = 1;

  late bool _porterRequired = false;
  late bool _porterSuggested = false;

  bool _porterHireSelected = false;

 
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _ageControllers = [];
  final List<String> _selectedGenders = [];
  final List<String> _selectedLevels = [];

  @override
  void initState() {
    super.initState();
    _initializeMemberFields(1);
  }

  void _initializeMemberFields(int paxCount) {
   
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _ageControllers) {
      controller.dispose();
    }

    
    _nameControllers.clear();
    _ageControllers.clear();
    _selectedGenders.clear();
    _selectedLevels.clear();

    for (int i = 0; i < paxCount; i++) {
      _nameControllers.add(TextEditingController());
      _ageControllers.add(TextEditingController());
      _selectedGenders.add('M');
      _selectedLevels.add('beginner');
    }

    _pax = paxCount;
  }

  void _updatePorterRequirement() {

    final beginnerCount = _selectedLevels.where((level) => level == 'beginner').length;
    final intermediateCount = _selectedLevels.where((level) => level == 'intermediate').length;

    if (beginnerCount == _pax && _pax > 0) {
      _porterRequired = true;
      _porterSuggested = false;
    } else if (beginnerCount > 0 && intermediateCount >= 2) {
      _porterRequired = false;
      _porterSuggested = true;
    } else {
      _porterRequired = false;
      _porterSuggested = false;
    }


    if (_porterRequired) _porterHireSelected = false;

    setState(() {});
  }

  bool _validateForm() {
    
    for (int i = 0; i < _pax; i++) {
      if (_nameControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nama anggota ${i + 1} harus diisi')),
        );
        return false;
      }
      if (_ageControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usia anggota ${i + 1} harus diisi')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _submitBooking() async {
    if (!_validateForm()) return;

    final request = context.read<CookieRequest>();

   
    if (_porterRequired && !_porterHireSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking ini wajib menyewa porter. Silakan pilih opsi sewa porter.')),
      );
      return;
    }

  
    List<Map<String, dynamic>> membersData = [];
    for (int i = 0; i < _pax; i++) {
      membersData.add({
        'name': _nameControllers[i].text,
        'age': int.parse(_ageControllers[i].text),
        'gender': _selectedGenders[i],
        'level': _selectedLevels[i],
      });
    }

    try {
      
      final response = await request.post(
        'http://localhost:8000/booking/book/',
        {
          'gunung_id': widget.mountainId,
          'pax': _pax,
          'anggota': membersData,
          'porter_hire': _porterHireSelected ? 'yes' : 'no',
        },
      );

      if (!mounted) return;

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking berhasil dibuat!')),
        );
        // Navigate to summary page
        Navigator.pushNamed(context, '/booking/summary');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Booking gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _ageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: 'Booking - ${widget.mountainName}'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mountain Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Pendakian',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mountainName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PAX Selector
              const Text(
                'Jumlah Peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _pax > 1
                        ? () {
                            _initializeMemberFields(_pax - 1);
                            _updatePorterRequirement();
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_pax Orang',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _pax < 10
                        ? () {
                            _initializeMemberFields(_pax + 1);
                            _updatePorterRequirement();
                          }
                        : null,
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Member Details Section
              const Text(
                'Detail Peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pax,
                itemBuilder: (context, index) {
                  return _buildMemberCard(index);
                },
              ),
              const SizedBox(height: 24),

              // Porter info / selection
              if (_porterRequired || _porterSuggested)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _porterRequired ? Colors.orange[50] : Colors.yellow[50],
                    border: Border.all(color: _porterRequired ? Colors.orange : Colors.amber),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_porterRequired ? Icons.warning : Icons.info, color: _porterRequired ? Colors.orange : Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _porterRequired
                                  ? 'Semua peserta adalah pemula — booking ini mewajibkan penyewaan porter.'
                                  : 'Terdapat peserta pemula dan beberapa peserta menengah (≥2). Disarankan menyewa porter untuk keamanan.',
                              style: TextStyle(
                                color: _porterRequired ? Colors.orange[900] : Colors.brown[800],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Hire toggle
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _porterHireSelected,
                              onChanged: (v) {
                                setState(() {
                                  _porterHireSelected = v ?? false;
                                });
                              },
                              title: const Text('Sewa Porter (Rp 250,000)'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Peserta × Rp 500,000'),
                        Text(
                          'Rp ${_pax * 500000}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_porterRequired) ...[
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Porter × Rp 250,000'),
                          Text(
                            'Rp 250,000',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    Divider(color: Colors.grey[300]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${(_pax * 500000) + (_porterRequired ? 250000 : 0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lanjutkan ke Pembayaran',
                    style: TextStyle(
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

  Widget _buildMemberCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peserta ${index + 1}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Name Field
          TextField(
            controller: _nameControllers[index],
            decoration: InputDecoration(
              labelText: 'Nama',
              hintText: 'Masukkan nama lengkap',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Age Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Usia',
                    hintText: 'Usia dalam tahun',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Gender Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGenders[index],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGenders[index] = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'F', child: Text('Perempuan')),
                    DropdownMenuItem(value: 'O', child: Text('Lainnya')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Jenis Kelamin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Level Dropdown
          DropdownButtonFormField<String>(
            value: _selectedLevels[index],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLevels[index] = value;
                  _updatePorterRequirement();
                });
              }
            },
            items: const [
              DropdownMenuItem(value: 'beginner', child: Text('Pemula')),
              DropdownMenuItem(value: 'intermediate', child: Text('Menengah')),
              DropdownMenuItem(value: 'advanced', child: Text('Mahir')),
            ],
            decoration: InputDecoration(
              labelText: 'Level Pendaki',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
