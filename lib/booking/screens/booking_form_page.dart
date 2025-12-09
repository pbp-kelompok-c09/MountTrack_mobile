import 'dart:convert';

import 'package:flutter/material.dart';
// Color palette5
import 'dart:ui';
import 'package:mounttrack_mobile/booking/screens/booking_summary.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../mountains/screens/all_mountains.dart';
import '../models/booking.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_navbar.dart';
import 'package:http/http.dart' as http;

class BookingFormPage extends StatefulWidget {
  final String? mountainId;
  final String? mountainName;
  final Booking? initialBooking;
  final bool isEditing;

  const BookingFormPage({
    super.key,
    this.mountainId,
    this.mountainName,
    this.initialBooking,
    this.isEditing = false,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}


class _BookingFormPageState extends State<BookingFormPage> {
  // Color palette5
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const sacramento = Color(0xFF102114);
  static const pine = Color(0xFF294122);
  static const salmon = Color(0xFFFFBBA6);
  static const tangerine = Color(0xFFEB3D00);
  static const chiffon = Color(0xFFFFEED2);

  late int _pax = 1;
  late bool _porterRequired = false;
  late bool _porterSuggested = false;
  bool _porterHireSelected = false;
  DateTime? _climbingDate;
  bool _profileLoaded = false;
  final List<String?> _selectedProfileIds = [];
  final List<bool> _isFromProfile = [];
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _ageControllers = [];
  final List<String> _selectedGenders = [];
  final List<String> _selectedLevels = [];
  // Store profile data for first member
  String _firstMemberName = '';
  int _firstMemberAge = 0;
  String _firstMemberGender = 'M';
  String _firstMemberLevel = 'beginner';
  String? _firstMemberProfileId;

    // --- letakkan ini di atas initState() ---
  Future<void> _initAfterBuild() async {
  final request = context.read<CookieRequest>();

  // ensure initial fields exist
  if (_nameControllers.isEmpty) _initializeMemberFields(1);

  // if not logged in, just mark as loaded
  if (!request.loggedIn) {
    if (!mounted) return;
    setState(() {
      _profileLoaded = true;
    });
    return;
  }

  try {
    final profile = await request.get("http://localhost:8000/accounts/profileapp/");
    if (!mounted) return;

    if (profile is Map && widget.initialBooking == null) {
      // take values as nullable Strings first
      final String? nama = profile['nama']?.toString();
      final String? umurStr = profile['umur']?.toString();
      final String? jenisKelamin = profile['jenis_kelamin']?.toString();
      final String? cat = profile['category_experience']?.toString();
      final String? pid = profile['id']?.toString();

      // apply safely (use defaults if needed)
      if (nama != null && nama.isNotEmpty) _firstMemberName = nama;
      if (umurStr != null && int.tryParse(umurStr) != null) {
        _firstMemberAge = int.tryParse(umurStr)!;
      }
      if (jenisKelamin != null && (jenisKelamin == 'M' || jenisKelamin == 'F' || jenisKelamin == 'O')) {
        _firstMemberGender = jenisKelamin;
      }
      if (cat != null && (cat == 'beginner' || cat == 'intermediate' || cat == 'advanced')) {
        _firstMemberLevel = cat;
      }
      if (pid != null && pid.isNotEmpty) _firstMemberProfileId = pid;

      // ensure controllers exist and fill first member fields
      if (_nameControllers.isEmpty) _initializeMemberFields(1);
      _nameControllers[0].text = _firstMemberName;
      if (_firstMemberAge > 0) _ageControllers[0].text = _firstMemberAge.toString();

      // lists _selectedGenders/_selectedLevels are non-nullable String lists;
      // assign using fallback to existing value or default
      if (_selectedGenders.isNotEmpty) {
        _selectedGenders[0] = jenisKelamin ?? _firstMemberGender;
      }
      if (_selectedLevels.isNotEmpty) {
        _selectedLevels[0] = cat ?? _firstMemberLevel;
      }
    }
  } catch (e) {
    // ignore network error for profile
  }

  // handle route args / initialBooking (edit mode)
  final args = ModalRoute.of(context)?.settings.arguments;
  if (args is Map) {
    final mid = args['mountainId']?.toString();
    final mname = args['mountainName']?.toString();
    if (mid != null) _selectedMountainId = mid;
    if (mname != null) _selectedMountainName = mname;
  }

  if (widget.initialBooking != null) {
    final b = widget.initialBooking!;
    _initializeMemberFields(b.pax);
    for (int i = 0; i < b.members.length && i < _nameControllers.length; i++) {
      final m = b.members[i];
      _nameControllers[i].text = m.name;
      _ageControllers[i].text = (m.age ?? 0).toString();
      _selectedGenders[i] = m.gender ?? 'M';
      _selectedLevels[i] = m.level;
      _selectedProfileIds[i] = null;
      _isFromProfile[i] = false;
    }
    _selectedMountainName = b.gunungNama;
    _pax = b.pax;
    _porterHireSelected = b.porterRequired;
  }

  _updatePorterRequirement();

  if (!mounted) return;
  setState(() {
    _profileLoaded = true;
  });
}


  // --- lalu di initState() panggil _initAfterBuild():
  @override
  void initState() {
    super.initState();

    // initialize minimal fields so controllers exist quickly
    _initializeMemberFields(widget.initialBooking?.pax ?? 1);

    // run async init after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAfterBuild();
    });
  }

  String? _selectedMountainId;
  String? _selectedMountainName;

  void _initializeMemberFields(int paxCount) {
  // safety: minimum 1
  if (paxCount < 1) paxCount = 1;

 
  if (paxCount == _pax && _nameControllers.length >= paxCount) {
    _pax = paxCount;
    return;
  }

  
  while (_nameControllers.length < paxCount) {
    _nameControllers.add(TextEditingController());
    _ageControllers.add(TextEditingController());
    _selectedGenders.add('M');
    _selectedLevels.add('beginner');
    _selectedProfileIds.add(null);
    _isFromProfile.add(false);
  }

  
  while (_nameControllers.length > paxCount) {
    final idx = _nameControllers.length - 1;
    _nameControllers[idx].dispose();
    _ageControllers[idx].dispose();
    _nameControllers.removeAt(idx);
    _ageControllers.removeAt(idx);
    _selectedGenders.removeAt(idx);
    _selectedLevels.removeAt(idx);
    _selectedProfileIds.removeAt(idx);
    _isFromProfile.removeAt(idx);
  }

  _pax = paxCount;

 
  if (_nameControllers.isNotEmpty) {
    if (_nameControllers[0].text.isEmpty && _firstMemberName.isNotEmpty) {
      _nameControllers[0].text = _firstMemberName;
    }
    if (_ageControllers[0].text.isEmpty && _firstMemberAge > 0) {
      _ageControllers[0].text = _firstMemberAge.toString();
    }
  }
}

void _setPax(int newPax) {
  _initializeMemberFields(newPax);
  _updatePorterRequirement();
}


  void _updatePorterRequirement() {
  
  final levels = List<String>.from(_selectedLevels);
  while (levels.length < _pax) levels.add('beginner');

  final beginnerCount = levels.where((l) => l == 'beginner').length;
  final intermediateCount = levels.where((l) => l == 'intermediate').length;

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
      // For first member, check state variable; for others, check controller
      final name = (i == 0) ? _firstMemberName : _nameControllers[i].text;
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nama anggota ${i + 1} harus diisi')),
        );
        return false;
      }
      
      final age = (i == 0) ? _firstMemberAge.toString() : _ageControllers[i].text;
      if (age.isEmpty || age == '0') {
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

  if (_climbingDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tanggal pendakian harus dipilih')),
    );
    return;
  }

  final request = context.read<CookieRequest>();

  if (_porterRequired && !_porterHireSelected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking ini wajib menyewa porter. Silakan pilih opsi sewa porter.')),
    );
    return;
  }

  // Build anggota list
  List<Map<String, dynamic>> membersData = [];

  if (_firstMemberProfileId != null && _firstMemberProfileId!.isNotEmpty) {
    membersData.add({'profile_id': _firstMemberProfileId});
  } else {
    final firstAge = (_firstMemberAge > 0) ? _firstMemberAge : null;
    final m0 = <String, dynamic>{
      'name': _firstMemberName.trim().isNotEmpty ? _firstMemberName.trim() : null,
      'age': firstAge,
      'gender': _firstMemberGender,
      'level': _firstMemberLevel,
    }..removeWhere((k, v) => v == null);
    membersData.add(m0);
  }

  for (int i = 1; i < _pax; i++) {
    final name = _nameControllers.length > i ? _nameControllers[i].text.trim() : '';
    final age = _ageControllers.length > i ? int.tryParse(_ageControllers[i].text.trim() ?? '') : null;
    final gender = _selectedGenders.length > i ? _selectedGenders[i] : 'M';
    final level = _selectedLevels.length > i ? _selectedLevels[i] : 'beginner';
    final profileId = _selectedProfileIds.length > i ? _selectedProfileIds[i] : null;

    if (profileId != null && profileId.isNotEmpty) {
      membersData.add({'profile_id': profileId});
    } else {
      final m = <String, dynamic>{};
      if (name.isNotEmpty) m['name'] = name;
      if (age != null && age > 0) m['age'] = age;
      m['gender'] = gender;
      m['level'] = level;
      membersData.add(m);
    }
  }

  final payload = {
    // prefer int for gunung_id and pax
    'gunung_id': int.tryParse((_selectedMountainId ?? widget.mountainId ?? '').toString()) ?? (_selectedMountainId ?? widget.mountainId),
    'pax': _pax, // integer
    'anggota': membersData,
    'porter_hire': _porterHireSelected ? 'yes' : 'no',
    'climbing_date': _climbingDate!.toIso8601String().split('T').first,
  };

  debugPrint('DEBUG PAYLOAD JSON: ${jsonEncode(payload)}');

  try {
  debugPrint("=== SUBMIT BOOKING USING CookieRequest.post ===");
  debugPrint("CookieRequest.loggedIn = ${request.loggedIn}");
  debugPrint("CookieRequest.cookies = ${request.cookies}");

  final url = 'http://localhost:8000/booking/api/book/';

  final resp = await request.post(
    url,
    {
      "payload": jsonEncode(payload),
    },
  );

  debugPrint("RAW RESP: $resp");

  if (!mounted) return;

  if (resp is Map<String, dynamic>) {
    debugPrint("Parsed JSON: $resp");

    // coba ambil booking id dari beberapa kemungkinan key
    final bookingId = (resp['booking_id'] ?? resp['id'] ?? resp['booking_id_str'])?.toString();

    if (resp['success'] == true && bookingId != null && bookingId.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEditing ? 'Booking diperbarui.' : 'Booking berhasil dibuat.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSummaryPage(),
          settings: RouteSettings(arguments: {'bookingId': bookingId}),
        ),
      );
      return;
    }

    // jika success true tapi no id: debug dan beri pesan
    if (resp['success'] == true && (bookingId == null || bookingId.isEmpty)) {
      debugPrint("WARN: server reported success but didn't return booking_id: $resp");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking berhasil (server tidak mengembalikan id).')),
      );
      return;
    }

    // error JSON
    final errorMsg = resp['message']?.toString() ??
        resp['detail']?.toString() ??
        "Booking gagal.";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    return;
  }

  if (resp is String) {
    final trimmed = resp.length > 200 ? resp.substring(0, 200) : resp;
    debugPrint("HTML STRING RETURNED (likely login page): $trimmed");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesi login tidak valid / expired. Silakan login ulang.')),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Response server tidak dikenali.')));
} catch (e, st) {
  debugPrint("Error during booking submit: $e\n$st");
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saat submit: $e')));
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
      backgroundColor: bone,
      appBar: AppNavBar(title: 'Booking${widget.mountainName != null ? ' - ${widget.mountainName}' : ''}'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero / intro header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kombuGreen, pine],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: cafeNoir.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rencanakan Pendakianmu',
                      style: TextStyle(
                        color: bone,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih gunung favorit, tentukan jumlah peserta, dan kami akan membantu mengatur perjalanan Anda dengan sempurna.',
                      style: TextStyle(color: chiffon, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    if (_selectedMountainName == null)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllMountainsPage(),
                            ),
                          );
                          if (result is Map) {
                            if (context.mounted) {
                              setState(() {});
                            }
                          }
                        },
                        icon: const Icon(Icons.terrain),
                        label: const Text('Pilih Gunung'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mossGreen,
                          foregroundColor: cafeNoir,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (widget.mountainName == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tan,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Belum memilih gunung — klik "Pilih Gunung" untuk memilih.', style: TextStyle(color: cafeNoir)),
                ),
              const SizedBox(height: 12),
              // Mountain Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mossGreen.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Pendakian',
                      style: TextStyle(
                        fontSize: 13,
                        color: pine,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedMountainName ?? widget.mountainName ?? 'Belum dipilih',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cafeNoir,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // PAX Selector
              Text(
                'Jumlah Peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: bone,
                  border: Border.all(color: tan, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: tangerine),
                      onPressed: _pax > 1 ? () {
                        _initializeMemberFields(_pax - 1);
                        _updatePorterRequirement();
                      } : null,
                    ),
                    Text(
                      '$_pax Orang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cafeNoir,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: mossGreen),
                      onPressed: _pax < 10 ? () {
                        _initializeMemberFields(_pax + 1);
                        _updatePorterRequirement();
                      } : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Tanggal Pendakian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _climbingDate ?? DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _climbingDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: tan, width: 2),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _climbingDate == null
                            ? 'Pilih tanggal'
                            : '${_climbingDate!.day}/${_climbingDate!.month}/${_climbingDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _climbingDate == null ? tan : cafeNoir,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: mossGreen),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Data Peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pax,
                itemBuilder: (context, index) {
                  return _buildMemberCard(index);
                },
              ),
              const SizedBox(height: 20),

              if (_porterRequired || _porterSuggested)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _porterRequired ? salmon.withOpacity(0.18) : chiffon,
                    border: Border.all(color: _porterRequired ? tangerine : mossGreen, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_porterRequired ? Icons.warning : Icons.info, color: _porterRequired ? tangerine : mossGreen),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _porterRequired
                                  ? 'Semua peserta adalah pemula — booking ini mewajibkan penyewaan porter.'
                                  : 'Terdapat peserta pemula dan beberapa peserta menengah (≥2). Disarankan menyewa porter untuk keamanan.',
                              style: TextStyle(
                                color: cafeNoir,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                              title: Text('Sewa Porter (Rp 250,000)', style: TextStyle(color: cafeNoir)),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: mossGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: chiffon,
                  border: Border.all(color: tan, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cafeNoir,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Peserta × Rp 500,000', style: TextStyle(color: cafeNoir)),
                        Text(
                          'Rp ${_pax * 500000}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: cafeNoir),
                        ),
                      ],
                    ),
                    if (_porterRequired) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Porter × Rp 250,000', style: TextStyle(color: cafeNoir)),
                          Text(
                            'Rp 250,000',
                            style: TextStyle(fontWeight: FontWeight.bold, color: cafeNoir),
                          ),
                        ],
                      ),
                    ],
                    Divider(color: tan, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cafeNoir,
                          ),
                        ),
                        Text(
                          'Rp ${(_pax * 500000) + (_porterRequired ? 250000 : 0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: mossGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cafeNoir,
                    foregroundColor: bone,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  child: const Text('Selesai Booking'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfileForIndex(int index) async {
  final request = context.read<CookieRequest>();
  String query = '';
  List<Map<String,dynamic>> results = [];

  
  final search = await showDialog<String?>(
    context: context,
    builder: (ctx) {
      String q = '';
      return AlertDialog(
        title: const Text('Cari profile'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Masukkan username atau nama'),
          onChanged: (v) => q = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, q.trim()), child: const Text('Cari')),
        ],
      );
    }
  );

  if (search == null || search.isEmpty) return;
  query = search;

  try {
    final url = 'http://localhost:8000/booking/api/profiles/?search=${Uri.encodeQueryComponent(query)}';
    final resp = await request.get(url);

   
    if (resp is Map && resp['profiles'] is List) {
      results = List<Map<String,dynamic>>.from(resp['profiles'] as List);
    } else if (resp is List) {
      results = List<Map<String,dynamic>>.from(resp);
    } else {
      results = [];
    }


    final sel = await showDialog<Map<String,dynamic>?>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text('Pilih profile (${results.length})'),
          children: results.isNotEmpty
            ? results.map((r) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(r['name'] ?? r['username'] ?? r['username']), Text(r['profile_id']?.toString() ?? '')],
                ),
              )).toList()
            : [Padding(padding: const EdgeInsets.all(12), child: Text('Tidak ada hasil'))],
        );
      }
    );

    if (sel != null) {
      // apply to index
      setState(() {
        _selectedProfileIds[index] = sel['profile_id']?.toString() ?? sel['id']?.toString();
        _isFromProfile[index] = true;
        // fill controllers and selects
        final name = sel['name'] ?? sel['username'] ?? '';
        final ageVal = sel['age'];
        final gender = sel['gender'];
        final level = sel['level'];
        _nameControllers[index].text = name;
        if (ageVal != null) _ageControllers[index].text = ageVal.toString();
        _selectedGenders[index] = (gender?.toString() ?? 'M');
        _selectedLevels[index] = (level?.toString() ?? 'beginner');
        _updatePorterRequirement();
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error mencari profile: $e')));
  }
}


  Widget _buildMemberCard(int index) {
  final isFirstMember = index == 0;
  // safety: pastikan lists ada slot index
  if (_nameControllers.length <= index) {
    _initializeMemberFields(index + 1);
  }
  final fromProfile = (_selectedProfileIds.length > index && _selectedProfileIds[index] != null);

  // shared decoration for text fields & dropdowns
  InputDecoration fieldDecoration({required String label, String? hint}) {
    return InputDecoration(
      filled: true,
      fillColor: chiffon,
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: cafeNoir, fontWeight: FontWeight.w600),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: mossGreen.withOpacity(0.9), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kombuGreen, width: 1.4),
      ),
    );
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(color: mossGreen.withOpacity(0.25)),
      borderRadius: BorderRadius.circular(12),
      color: isFirstMember ? mossGreen.withOpacity(0.08) : bone,
      boxShadow: [
        BoxShadow(color: cafeNoir.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Peserta ${index + 1}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cafeNoir),
            ),
            if (isFirstMember)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: mossGreen, borderRadius: BorderRadius.circular(4)),
                child: const Text('Anda', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            const Spacer(),
            if (!isFirstMember) ...[
              IconButton(
                icon: Icon(Icons.person_search, color: mossGreen),
                tooltip: 'Pilih profile yang sudah terdaftar',
                onPressed: () => _pickProfileForIndex(index),
              ),
              if (fromProfile)
                IconButton(
                  icon: Icon(Icons.clear, color: tangerine),
                  tooltip: 'Hapus pilihan profile',
                  onPressed: () {
                    setState(() {
                      _selectedProfileIds[index] = null;
                      _isFromProfile[index] = false;
                      _nameControllers[index].text = '';
                      _ageControllers[index].text = '';
                      _selectedGenders[index] = 'M';
                      _selectedLevels[index] = 'beginner';
                      _updatePorterRequirement();
                    });
                  },
                ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        if (isFirstMember)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bone,
              border: Border.all(color: mossGreen.withOpacity(0.18)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _profileLoaded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameControllers.isNotEmpty && _nameControllers[0].text.isNotEmpty
                            ? _nameControllers[0].text
                            : (_firstMemberName.isNotEmpty ? _firstMemberName : 'Nama tidak tersedia'),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cafeNoir),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Usia: ${_ageControllers.isNotEmpty && _ageControllers[0].text.isNotEmpty ? _ageControllers[0].text : (_firstMemberAge > 0 ? _firstMemberAge : '-')}',
                            style: TextStyle(color: cafeNoir),
                          ),
                          Text(
                            'Gender: ${_selectedGenders.isNotEmpty ? (_selectedGenders[0] == 'M' ? 'Laki-laki' : _selectedGenders[0] == 'F' ? 'Perempuan' : 'Lainnya') : '-'}',
                            style: TextStyle(color: cafeNoir),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Level: ${_selectedLevels.isNotEmpty ? (_selectedLevels[0][0].toUpperCase() + _selectedLevels[0].substring(1)) : _firstMemberLevel}',
                        style: TextStyle(color: cafeNoir),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fromProfile)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: tan, border: Border.all(color: cafeNoir), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.person, size: 16, color: bone),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Diisi dari profile (ID: ${_selectedProfileIds[index]})',
                            style: const TextStyle(fontSize: 12, color: bone),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
              TextField(
                controller: _nameControllers[index],
                decoration: fieldDecoration(label: 'Nama', hint: 'Masukkan nama lengkap'),
                style: TextStyle(color: cafeNoir),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ageControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration(label: 'Usia', hint: 'Usia dalam tahun'),
                    style: TextStyle(color: cafeNoir),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGenders[index],
                    onChanged: (v) => setState(() => _selectedGenders[index] = v ?? 'M'),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'F', child: Text('Perempuan')),
                      DropdownMenuItem(value: 'O', child: Text('Lainnya')),
                    ],
                    decoration: fieldDecoration(label: 'Jenis Kelamin'),
                    iconEnabledColor: kombuGreen,
                    dropdownColor: bone,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLevels[index],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedLevels[index] = v;
                      _updatePorterRequirement();
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Pemula')),
                  DropdownMenuItem(value: 'intermediate', child: Text('Menengah')),
                  DropdownMenuItem(value: 'advanced', child: Text('Mahir')),
                ],
                decoration: fieldDecoration(label: 'Level Pendaki'),
                iconEnabledColor: kombuGreen,
                dropdownColor: bone,
              ),
            ],
          )
      ],
    ),
  );
}
}