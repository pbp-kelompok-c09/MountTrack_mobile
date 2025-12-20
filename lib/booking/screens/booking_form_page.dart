import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:mounttrack_mobile/booking/screens/booking_summary.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/booking.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_navbar.dart';

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
  // Color palette
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const pine = Color(0xFF294122);
  static const salmon = Color(0xFFFFBBA6);
  static const tangerine = Color(0xFFEB3D00);

  late int _pax = 1;
  late bool _porterRequired = false;
  bool _porterHireSelected = false;
  int _duration = 0;
  DateTime? _climbingDate;
  DateTime? _climbingEndDate;
  List<Map<String, dynamic>> _mountains = [];
  final List<String?> _selectedProfileIds = [];
  final List<bool> _isFromProfile = [];
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _ageControllers = [];
  final List<String> _selectedGenders = [];
  final List<String> _selectedLevels = [];

  String _firstMemberName = '';
  int _firstMemberAge = 0;
  String _firstMemberGender = 'M';
  String _firstMemberLevel = 'beginner';
  String? _firstMemberProfileId;

  Future<void> _initAfterBuild() async {
    final request = context.read<CookieRequest>();

    if (_nameControllers.isEmpty) _initializeMemberFields(1);

    if (!request.loggedIn) {
      if (!mounted) return;
      return;
    }

    try {
      final profile = await request.get("http://localhost:8000/accounts/profileapp/");
      if (!mounted) return;

      if (profile is Map && widget.initialBooking == null) {
        final String? nama = profile['nama']?.toString();
        final String? umurStr = profile['umur']?.toString();
        final String? jenisKelamin = profile['jenis_kelamin']?.toString();
        final String? cat = profile['category_experience']?.toString();
        final String? pid = profile['id']?.toString();

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

        if (_nameControllers.isEmpty) _initializeMemberFields(1);
        _nameControllers[0].text = _firstMemberName;
        if (_firstMemberAge > 0) _ageControllers[0].text = _firstMemberAge.toString();

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
    await _loadMountains();

    if (!mounted) return;
  }

  @override
  void initState() {
    super.initState();
    _initializeMemberFields(widget.initialBooking?.pax ?? 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAfterBuild();
    });
  }

  String? _selectedMountainId;
  String? _selectedMountainName;

  Future<void> _loadMountains() async {
    final request = context.read<CookieRequest>();
    try {
      debugPrint('=== LOADING MOUNTAINS ===');
      debugPrint('Cookies: ${request.cookies}');
      debugPrint('Logged in: ${request.loggedIn}');
      
      // Try the main endpoint first
      debugPrint('Attempting: http://localhost:8000/mountains/api/mountains/');
      final response = await request.get('http://localhost:8000/mountains/api/mountains/');
      
      if (!mounted) return;
      
      debugPrint('Raw response type: ${response.runtimeType}');
      debugPrint('Raw response length: ${response.toString().length}');
      
      // Handle different response types
      if (response is List && response.isNotEmpty) {
        debugPrint('✓ Response is List with ${response.length} items');
        setState(() {
          _mountains = List<Map<String, dynamic>>.from(response);
        });
        debugPrint('Loaded ${_mountains.length} mountains');
      } else if (response is Map) {
        debugPrint('Response is Map with keys: ${response.keys.toList()}');
        
        // Try different keys for the mountains data
        List<dynamic>? mountainsList;
        if (response['results'] is List) {
          mountainsList = response['results'];
          debugPrint('Found in results key');
        } else if (response['data'] is List) {
          mountainsList = response['data'];
          debugPrint('Found in data key');
        } else if (response['mountains'] is List) {
          mountainsList = response['mountains'];
          debugPrint('Found in mountains key');
        }
        
        if (mountainsList != null && mountainsList.isNotEmpty) {
          debugPrint('✓ Found mountains list with ${mountainsList.length} items');
          setState(() {
            _mountains = List<Map<String, dynamic>>.from(mountainsList!);
          });
        } else {
          debugPrint('✗ No mountains list found in response keys');
          // Print first few keys and their values for debugging
          response.forEach((k, v) {
            debugPrint('  $k: ${v.runtimeType}');
          });
        }
      } else if (response is String) {
        debugPrint('✗ Response is String (likely HTML error)');
        final preview = response.length > 500 ? response.substring(0, 500) : response;
        debugPrint('Preview: $preview');
      } else {
        debugPrint('✗ Mountains response format unexpected: $response');
      }
    } catch (e, st) {
      debugPrint('✗ Error loading mountains: $e');
      debugPrint('Stack trace: $st');
    }
  }

  void _updateEndDate() {
    if (_duration == 0 || _climbingDate == null) {
      _climbingEndDate = null;
      return;
    }
    _climbingEndDate = _climbingDate!.add(Duration(days: _duration - 1));
    setState(() {});
  }

  void _initializeMemberFields(int paxCount) {
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

  void _updatePorterRequirement() {
    final levels = List<String>.from(_selectedLevels);
    while (levels.length < _pax) levels.add('beginner');

    final beginnerCount = levels.where((l) => l == 'beginner').length;
    final intermediateCount = levels.where((l) => l == 'intermediate').length;

    if (beginnerCount == _pax && _pax > 0) {
      _porterRequired = true;
    } else if (beginnerCount > 0 && intermediateCount >= 2) {
      _porterRequired = false;
    } else {
      _porterRequired = false;
    }

    if (_porterRequired) _porterHireSelected = false;
    setState(() {});
  }

  bool _validateForm() {
    for (int i = 0; i < _pax; i++) {
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
        const SnackBar(
            content: Text(
                'Booking ini wajib menyewa porter. Silakan pilih opsi sewa porter.')),
      );
      return;
    }

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
      final age = _ageControllers.length > i ? int.tryParse(_ageControllers[i].text.trim()) : null;
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
      'gunung_id': int.tryParse((_selectedMountainId ?? widget.mountainId ?? '').toString()) ?? (_selectedMountainId ?? widget.mountainId),
      'pax': _pax,
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

        final bookingId = (resp['booking_id'] ?? resp['id'] ?? resp['booking_id_str'])?.toString();

        if (resp['success'] == true && bookingId != null && bookingId.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEditing ? 'Booking diperbarui.' : 'Booking berhasil dibuat.')),
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

        if (resp['success'] == true && (bookingId == null || bookingId.isEmpty)) {
          debugPrint("WARN: server reported success but didn't return booking_id: $resp");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking berhasil (server tidak mengembalikan id).')),
          );
          return;
        }

        final errorMsg = resp['message']?.toString() ?? resp['detail']?.toString() ?? "Booking gagal.";
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
      appBar: AppNavBar(title: 'Booking'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kombuGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rencanakan Pendakianmu',
                      style: TextStyle(
                        color: const Color(0xFFFFFFE2),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih gunung favorit, tentukan jumlah peserta, dan kami akan membantu mengatur perjalanan Anda dengan sempurna.',
                      style: TextStyle(
                        color: const Color(0xFFFFFFE2).withOpacity(0.95),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // User Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EFD9),
                  border: Border.all(color: tan, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: mossGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Informasi Anda',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: pine,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildOutlinedInfoField('Nama', _firstMemberName.isNotEmpty ? _firstMemberName : '-'),
                    _buildOutlinedInfoField('Umur', _firstMemberAge > 0 ? '${_firstMemberAge}' : '-'),
                    _buildOutlinedInfoField('Jenis Kelamin', _getGenderDisplay(_firstMemberGender)),
                    _buildOutlinedInfoField('Pengalaman', _getLevelDisplay(_firstMemberLevel)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mountain, Duration, Dates
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EFD9),
                  border: Border.all(color: tan, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mountain
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Gunung',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cafeNoir,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFE2),
                            border: Border.all(color: _mountains.isEmpty ? tangerine : mossGreen, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _mountains.isEmpty
                              ? Container(
                                  height: 48,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(mossGreen),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Memuat gunung...',
                                        style: TextStyle(fontSize: 12, color: cafeNoir),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButton<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    _selectedMountainName ?? 'Pilih Gunung',
                                    style: TextStyle(fontSize: 12, color: cafeNoir),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: _mountains.any((m) => m['id'].toString() == _selectedMountainId) ? _selectedMountainId : null,
                                  items: _mountains.map((mountain) {
                                    return DropdownMenuItem<String>(
                                      value: mountain['id'].toString(),
                                      child: Text(
                                        mountain['name']?.toString() ?? 'Unknown',
                                        style: TextStyle(fontSize: 12, color: cafeNoir),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    final selectedMtn = _mountains.firstWhere(
                                      (m) => m['id'].toString() == value,
                                      orElse: () => {},
                                    );
                                    setState(() {
                                      _selectedMountainId = value;
                                      _selectedMountainName = selectedMtn['name']?.toString();
                                    });
                                  },
                                  underline: const SizedBox(),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Duration
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durasi Pendakian',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cafeNoir,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(3, (index) {
                              int days = index + 1;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _duration = days;
                                      _updateEndDate();
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _duration == days
                                          ? const Color(0xFFFFFFE2)
                                          : tan,
                                      border: Border.all(color: mossGreen, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$days Hari',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _duration == days ? mossGreen : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              );
                              })
                          ],
                        ),
                      ],
                    ),

                    // Dates (only if duration selected)
                    if (_duration > 0) ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Mulai Pendakian',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cafeNoir,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _climbingDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setState(() {
                                  _climbingDate = picked;
                                  _updateEndDate();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFE2),
                                border: Border.all(color: mossGreen, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _climbingDate != null
                                        ? DateFormat('dd/MM/yyyy').format(_climbingDate!)
                                        : 'Pilih tanggal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _climbingDate != null ? cafeNoir : tan,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today, size: 16, color: mossGreen),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_climbingDate != null && _climbingEndDate != null) ...[
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Berakhir Pendakian',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cafeNoir,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: bone,
                                border: Border.all(color: tan, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_climbingEndDate!),
                                    style: TextStyle(fontSize: 12, color: cafeNoir),
                                  ),
                                  Icon(Icons.check_circle, size: 16, color: mossGreen),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PAX & Porter
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EFD9),
                  border: Border.all(color: tan, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PAX
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah Anggota',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cafeNoir,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_pax > 1) {
                                    setState(() {
                                      _pax--;
                                      _initializeMemberFields(_pax);
                                      _updatePorterRequirement();
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: tan,
                                    border: Border.all(color: mossGreen, width: 2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('−', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF4C3019))),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFE2),
                                    border: Border.all(color: mossGreen, width: 2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text('$_pax', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4C3019))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _pax++;
                                    _initializeMemberFields(_pax);
                                    _updatePorterRequirement();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: mossGreen,
                                    border: Border.all(color: mossGreen, width: 2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('+', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFFFFFE2))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Porter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sewa Porter',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cafeNoir,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFE2),
                              border: Border.all(color: mossGreen, width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButton<bool>(
                              value: _porterHireSelected,
                              onChanged: (v) => setState(() => _porterHireSelected = v ?? false),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: [
                                DropdownMenuItem(
                                  value: false,
                                  child: Text('Tidak', style: TextStyle(fontSize: 11, color: cafeNoir)),
                                ),
                                DropdownMenuItem(
                                  value: true,
                                  child: Text('Ya', style: TextStyle(fontSize: 11, color: cafeNoir)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Members
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EFD9),
                  border: Border.all(color: tan, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Anggota Tambahan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pine),
                    ),
                    const SizedBox(height: 10),
                    if (_pax > 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 1; i < _pax; i++) ...[
                            _buildMemberCard(i),
                            if (i < _pax - 1) const SizedBox(height: 10),
                          ],
                        ],
                      )
                    else
                      Text(
                        'Tidak ada anggota tambahan. Peserta utama adalah akun Anda.',
                        style: TextStyle(fontSize: 11, color: cafeNoir),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Porter Warning
              if (_porterRequired && !_porterHireSelected)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: salmon.withOpacity(0.08),
                    border: Border.all(color: tangerine, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: tangerine, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Penyewaan Porter Diperlukan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cafeNoir,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Semua peserta adalah pemula. Booking ini mewajibkan penyewaan porter untuk keselamatan.',
                                  style: TextStyle(fontSize: 11, color: cafeNoir),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _porterHireSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                _porterHireSelected = value ?? false;
                              });
                            },
                            activeColor: mossGreen,
                            side: BorderSide(color: mossGreen, width: 2),
                          ),
                          Expanded(
                            child: Text(
                              'Sewa Porter (Rp 250.000)',
                              style: TextStyle(fontSize: 11, color: cafeNoir),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EFD9),
                  border: Border.all(color: tan, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Biaya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cafeNoir,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Peserta ($_pax) × Rp 500.000',
                          style: TextStyle(fontSize: 11, color: cafeNoir),
                        ),
                        Text(
                          'Rp ${(_pax * 500000).toString()}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cafeNoir),
                        ),
                      ],
                    ),
                    if (_porterHireSelected) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Porter × Rp 250.000',
                            style: TextStyle(fontSize: 11, color: cafeNoir),
                          ),
                          Text(
                            'Rp 250.000',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cafeNoir),
                          ),
                        ],
                      ),
                    ],
                    Divider(color: tan, height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cafeNoir,
                          ),
                        ),
                        Text(
                          'Rp ${((_pax * 500000) + (_porterHireSelected ? 250000 : 0)).toString()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: mossGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Submit
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pastikan data anggota lengkap sebelum submit.',
                    style: TextStyle(fontSize: 11, color: cafeNoir),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cafeNoir,
                        foregroundColor: const Color(0xFFFFFFE2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Selesai Booking',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedInfoField(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: mossGreen, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: cafeNoir, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cafeNoir),
          ),
        ],
      ),
    );
  }

  String _getGenderDisplay(String? gender) {
    switch (gender) {
      case 'M':
        return 'Laki-laki';
      case 'F':
        return 'Perempuan';
      case 'O':
        return 'Lainnya';
      default:
        return '-';
    }
  }

  String _getLevelDisplay(String? level) {
    switch (level) {
      case 'beginner':
        return 'Pemula';
      case 'intermediate':
        return 'Menengah';
      case 'advanced':
        return 'Mahir';
      default:
        return 'Pemula';
    }
  }

  Widget _buildMemberCard(int index) {
    if (_nameControllers.length <= index) {
      _initializeMemberFields(index + 1);
    }
    final fromProfile = (_selectedProfileIds.length > index && _selectedProfileIds[index] != null);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tan,
        border: Border.all(color: mossGreen, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anggota ${index}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pine),
          ),
          const SizedBox(height: 8),
          if (fromProfile)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tan,
                border: Border.all(color: cafeNoir),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 12, color: cafeNoir),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Profil: ${_selectedProfileIds[index]}',
                      style: TextStyle(fontSize: 10, color: cafeNoir),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            children: [
              _buildMemberField('Nama', _nameControllers[index], TextInputType.text),
              _buildMemberField('Usia', _ageControllers[index], TextInputType.number),
              _buildGenderDropdown(index),
              _buildLevelDropdown(index),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pine),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: cafeNoir, fontSize: 10),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFFE2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: mossGreen, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: kombuGreen, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pine),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFE2),
              border: Border.all(color: mossGreen, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              value: _selectedGenders[index],
              onChanged: (v) => setState(() => _selectedGenders[index] = v ?? 'M'),
              isExpanded: true,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'M', child: Text('Laki-laki', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'F', child: Text('Perempuan', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'O', child: Text('Lainnya', style: TextStyle(fontSize: 10))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelDropdown(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pine),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFE2),
              border: Border.all(color: mossGreen, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              value: _selectedLevels[index],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedLevels[index] = v;
                    _updatePorterRequirement();
                  });
                }
              },
              isExpanded: true,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'beginner', child: Text('Pemula', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'intermediate', child: Text('Menengah', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'advanced', child: Text('Mahir', style: TextStyle(fontSize: 10))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
