import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/booking_user_profile.dart';
import '../../mountains/screens/all_mountains.dart';
import '../models/booking.dart';
import '../models/booking_member.dart';
import '../widgets/booking_user_profile_selector.dart';
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
  static const Color cafeNoir = Color(0xFF4C3019);
  static const Color kombuGreen = Color(0xFF354024);
  static const Color mossGreen = Color(0xFF889063);
  static const Color tan = Color(0xFFCFBB99);
  static const Color bone = Color(0xFFE5D7C4);
  static const Color sacramento = Color(0xFF102114);
  static const Color pine = Color(0xFF294122);
  static const Color salmon = Color(0xFFFFBBA6);
  static const Color tangerine = Color(0xFFEB3D00);
  static const Color chiffon = Color(0xFFFFEED2);

  late int _pax = 1;
  late bool _porterRequired = false;
  late bool _porterSuggested = false;
  bool _porterHireSelected = false;

  DateTime? _climbingDate;
  bool _profileLoaded = false;
  String? _selectedMountainId;
  String? _selectedMountainName;

  BookingUserProfile? _primaryProfile;

  final List<BookingUserProfile?> _selectedProfiles = [];
  final List<String> _selectedLevels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAfterBuild());
  }

  Future<void> _initAfterBuild() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      if (mounted) {
        setState(() {
          _profileLoaded = true;
        });
      }
      return;
    }

    try {
      final profile = await request.get('http://localhost:8000/accounts/profileapp/');
      if (mounted && profile is Map) {
        final profileMap = Map<String, dynamic>.from(profile);
        _primaryProfile = BookingUserProfile.fromJson(profileMap);
        _initializeMemberFields(1);
      }
    } catch (e) {
      debugPrint('Error loading primary profile: $e');
    }

    if (mounted) {
      setState(() {
        _profileLoaded = true;
      });
    }
  }

  void _initializeMemberFields(int paxCount) {
    if (paxCount < 1) paxCount = 1;

    if (_selectedProfiles.isEmpty && _primaryProfile != null) {
      _selectedProfiles.add(_primaryProfile);
      _selectedLevels.add(_primaryProfile!.categoryExperience);
    }

    while (_selectedProfiles.length < paxCount) {
      _selectedProfiles.add(null);
      _selectedLevels.add('beginner');
    }

    while (_selectedProfiles.length > paxCount) {
      _selectedProfiles.removeLast();
      _selectedLevels.removeLast();
    }

    _pax = paxCount;
    _updatePorterRequirement();
  }

  void _setPax(int newPax) {
    setState(() {
      _initializeMemberFields(newPax);
    });
  }

  void _updatePorterRequirement() {
    final beginnerCount = _selectedLevels.where((l) => l == 'beginner').length;
    final intermediateCount = _selectedLevels.where((l) => l == 'intermediate').length;

    bool needsPorter = false;
    bool suggestPorter = false;

    if (beginnerCount == _pax && _pax > 0) {
      needsPorter = false;
      suggestPorter = false;
    } else if (beginnerCount > 0 && intermediateCount >= 2) {
      needsPorter = false;
      suggestPorter = true;
    }

    setState(() {
      _porterRequired = needsPorter;
      _porterSuggested = suggestPorter;
      if (_porterRequired) _porterHireSelected = false;
    });
  }

  bool _validateForm() {
    if (_selectedMountainId == null || _selectedMountainId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gunung.')),
      );
      return false;
    }

    if (_pax < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah peserta harus minimal 1.')),
      );
      return false;
    }

    for (int i = 0; i < _selectedProfiles.length; i++) {
      if (_selectedProfiles[i] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Peserta ${i + 1} harus dipilih.')),
        );
        return false;
      }
    }

    if (_climbingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal pendakian harus dipilih.')),
      );
      return false;
    }

    if (_porterRequired && !_porterHireSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking ini wajib menyewa porter.')),
      );
      return false;
    }

    return true;
  }

  Future<void> _submitBooking() async {
    if (!_validateForm()) return;

    final request = context.read<CookieRequest>();

    try {
      List<Map<String, dynamic>> membersData = [];
      for (final profile in _selectedProfiles) {
        if (profile != null) {
          membersData.add({'profile_id': profile.id});
        }
      }

      final payload = {
        'gunung_id': _selectedMountainId,
        'pax': _pax,
        'anggota': jsonEncode(membersData),
        'porter_hire': _porterHireSelected ? 'yes' : 'no',
        'climbing_date': _climbingDate!.toIso8601String().split('T').first,
      };

      dynamic response;
      if (widget.isEditing && widget.initialBooking != null) {
        final id = widget.initialBooking!.id;
        response = await request.post('http://localhost:8000/booking/api/$id/edit/', payload);
      } else {
        response = await request.post('http://localhost:8000/booking/api/book/', payload);
      }

      if (!mounted) return;

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respon server kosong.')),
        );
        return;
      }

      String? bookingId;
      if (response is Map<String, dynamic>) {
        bookingId = response['booking_id']?.toString() ?? response['id']?.toString();
      }

      if (bookingId != null && bookingId.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/booking/summary',
          arguments: {'bookingId': bookingId},
        );
        return;
      }

      final msg = (response is Map) ? (response['message']?.toString() ?? 'Booking gagal') : 'Booking gagal';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat submit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (!_profileLoaded) {
      return Scaffold(
        backgroundColor: bone,
        appBar: AppNavBar(title: 'Booking'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!request.loggedIn) {
      return Scaffold(
        backgroundColor: bone,
        appBar: AppNavBar(title: 'Booking'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Silakan login terlebih dahulu untuk melakukan booking.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bone,
      appBar: AppNavBar(
        title: 'Booking${_selectedMountainName != null ? ' - $_selectedMountainName' : ''}',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildMountainSelection(),
              const SizedBox(height: 20),
              _buildPaxSelection(),
              const SizedBox(height: 20),
              _buildClimbingDatePicker(),
              const SizedBox(height: 20),
              _buildMembersSelection(),
              const SizedBox(height: 20),
              _buildPorterOption(),
              const SizedBox(height: 20),
              _buildPriceSummary(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mossGreen,
                  foregroundColor: bone,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Lanjut ke Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cafeNoir,
                  side: const BorderSide(color: cafeNoir),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kombuGreen, pine],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rencanakan Pendakianmu',
            style: TextStyle(
              color: bone,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih gunung favorit, tentukan jumlah peserta, dan kami akan membantu mengatur perjalanan Anda dengan sempurna.',
            style: TextStyle(
              color: chiffon,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMountainSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Gunung',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: cafeNoir,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: tan, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: ListTile(
            leading: const Icon(Icons.terrain, color: mossGreen),
            title: Text(
              _selectedMountainName ?? widget.mountainName ?? 'Pilih Gunung',
              style: const TextStyle(color: cafeNoir),
            ),
            trailing: const Icon(Icons.arrow_forward, color: tan),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllMountainsPage()),
              );
              if (result is Map) {
                setState(() {
                  _selectedMountainId = result['id']?.toString();
                  _selectedMountainName = result['name']?.toString();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaxSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah Peserta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: cafeNoir,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: tan, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: tangerine),
                onPressed: _pax > 1 ? () => _setPax(_pax - 1) : null,
              ),
              Text(
                '$_pax Peserta',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: mossGreen),
                onPressed: _pax < 10 ? () => _setPax(_pax + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClimbingDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Pendakian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: cafeNoir,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: tan, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: mossGreen),
            title: Text(
              _climbingDate != null
                  ? '${_climbingDate!.day}/${_climbingDate!.month}/${_climbingDate!.year}'
                  : 'Pilih Tanggal',
              style: TextStyle(
                color: _climbingDate != null ? cafeNoir : tan,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward, color: tan),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _climbingDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _climbingDate = picked;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peserta Pendakian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: cafeNoir,
          ),
        ),
        const SizedBox(height: 8),
        ..._selectedProfiles.asMap().entries.map((entry) {
          final index = entry.key;
          final profile = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: tan, width: 1),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Peserta ${index + 1}${index == 0 ? ' (Anda)' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kombuGreen,
                          ),
                        ),
                      ),
                      if (index > 0)
                        IconButton(
                          icon: const Icon(Icons.close, color: tangerine, size: 20),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (index == 0 && _primaryProfile != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: chiffon,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: mossGreen, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _primaryProfile!.nama,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: cafeNoir,
                                  ),
                                ),
                                Text(
                                  _primaryProfile!.categoryExperience,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cafeNoir.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    BookingUserProfileSelector(
                      initialProfile: profile,
                      onSelected: (selectedProfile) {
                        setState(() {
                          _selectedProfiles[index] = selectedProfile;
                          if (selectedProfile != null) {
                            _selectedLevels[index] = selectedProfile.categoryExperience;
                            _updatePorterRequirement();
                          }
                        });
                      },
                      hint: 'Pilih Peserta',
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPorterOption() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _porterRequired ? tangerine : (_porterSuggested ? salmon : tan),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: _porterRequired ? salmon.withOpacity(0.1) : (_porterSuggested ? chiffon : Colors.white),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add, color: mossGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Porter',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: cafeNoir,
                      ),
                    ),
                    if (_porterRequired)
                      const Text(
                        'Wajib untuk booking ini',
                        style: TextStyle(
                          fontSize: 11,
                          color: tangerine,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (_porterSuggested)
                      const Text(
                        'Disarankan untuk keselamatan',
                        style: TextStyle(
                          fontSize: 11,
                          color: tangerine,
                        ),
                      )
                    else
                      const Text(
                        'Tidak diperlukan untuk grup ini',
                        style: TextStyle(
                          fontSize: 11,
                          color: cafeNoir,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_porterRequired || _porterSuggested)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CheckboxListTile(
                value: _porterHireSelected,
                onChanged: (value) {
                  setState(() {
                    _porterHireSelected = value ?? false;
                  });
                },
                title: const Text(
                  'Ya, saya ingin menyewa porter (Rp 250.000)',
                  style: TextStyle(fontSize: 12, color: cafeNoir),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: mossGreen,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final basePrice = _pax * 500000;
    final porterPrice = _porterHireSelected ? 250000 : 0;
    final total = basePrice + porterPrice;

    return Container(
      decoration: BoxDecoration(
        color: chiffon,
        border: Border.all(color: tan, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Biaya',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: cafeNoir,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_pax Peserta × Rp 500.000',
                style: const TextStyle(fontSize: 12, color: cafeNoir),
              ),
              Text(
                'Rp $basePrice',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
            ],
          ),
          if (_porterHireSelected)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Porter',
                    style: TextStyle(fontSize: 12, color: cafeNoir),
                  ),
                  Text(
                    'Rp $porterPrice',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cafeNoir,
                    ),
                  ),
                ],
              ),
            ),
          Divider(color: tan, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              Text(
                'Rp $total',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: mossGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}


// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:mounttrack_mobile/booking/screens/booking_summary.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import '../../mountains/screens/all_mountains.dart';
// import '../models/booking.dart';
// import 'package:provider/provider.dart';
// import '../../widgets/app_navbar.dart';

// class BookingFormPage extends StatefulWidget {
//   final String? mountainId;
//   final String? mountainName;
//   final Booking? initialBooking;
//   final bool isEditing;

//   const BookingFormPage({
//     super.key,
//     this.mountainId,
//     this.mountainName,
//     this.initialBooking,
//     this.isEditing = false,
//   });

//   @override
//   State<BookingFormPage> createState() => _BookingFormPageState();
// }

// class _BookingFormPageState extends State<BookingFormPage> {
//   late int _pax = 1;

//   late bool _porterRequired = false;
//   late bool _porterSuggested = false;

//   bool _porterHireSelected = false;

//   DateTime? _climbingDate;
//   bool _profileLoaded = false;
//   final List<String?> _selectedProfileIds = []; 
//   final List<bool> _isFromProfile = []; 
//   final List<TextEditingController> _nameControllers = [];
//   final List<TextEditingController> _ageControllers = [];
//   final List<String> _selectedGenders = [];
//   final List<String> _selectedLevels = [];
  
//   // Store profile data for first member
//   String _firstMemberName = '';
//   int _firstMemberAge = 0;
//   String _firstMemberGender = 'M';
//   String _firstMemberLevel = 'beginner';
//   String? _firstMemberProfileId;

//     // --- letakkan ini di atas initState() ---
//   Future<void> _initAfterBuild() async {
//   final request = context.read<CookieRequest>();

//   // ensure initial fields exist
//   if (_nameControllers.isEmpty) _initializeMemberFields(1);

//   // if not logged in, just mark as loaded
//   if (!request.loggedIn) {
//     if (!mounted) return;
//     setState(() {
//       _profileLoaded = true;
//     });
//     return;
//   }

//   try {
//     final profile = await request.get("http://localhost:8000/accounts/profileapp/");
//     if (!mounted) return;

//     if (profile is Map && widget.initialBooking == null) {
//       // take values as nullable Strings first
//       final String? nama = profile['nama']?.toString();
//       final String? umurStr = profile['umur']?.toString();
//       final String? jenisKelamin = profile['jenis_kelamin']?.toString();
//       final String? cat = profile['category_experience']?.toString();
//       final String? pid = profile['id']?.toString();

//       // apply safely (use defaults if needed)
//       if (nama != null && nama.isNotEmpty) _firstMemberName = nama;
//       if (umurStr != null && int.tryParse(umurStr) != null) {
//         _firstMemberAge = int.tryParse(umurStr)!;
//       }
//       if (jenisKelamin != null && (jenisKelamin == 'M' || jenisKelamin == 'F' || jenisKelamin == 'O')) {
//         _firstMemberGender = jenisKelamin;
//       }
//       if (cat != null && (cat == 'beginner' || cat == 'intermediate' || cat == 'advanced')) {
//         _firstMemberLevel = cat;
//       }
//       if (pid != null && pid.isNotEmpty) _firstMemberProfileId = pid;

//       // ensure controllers exist and fill first member fields
//       if (_nameControllers.isEmpty) _initializeMemberFields(1);
//       _nameControllers[0].text = _firstMemberName;
//       if (_firstMemberAge > 0) _ageControllers[0].text = _firstMemberAge.toString();

//       // lists _selectedGenders/_selectedLevels are non-nullable String lists;
//       // assign using fallback to existing value or default
//       if (_selectedGenders.isNotEmpty) {
//         _selectedGenders[0] = jenisKelamin ?? _firstMemberGender;
//       }
//       if (_selectedLevels.isNotEmpty) {
//         _selectedLevels[0] = cat ?? _firstMemberLevel;
//       }
//     }
//   } catch (e) {
//     // ignore network error for profile
//   }

//   // handle route args / initialBooking (edit mode)
//   final args = ModalRoute.of(context)?.settings.arguments;
//   if (args is Map) {
//     final mid = args['mountainId']?.toString();
//     final mname = args['mountainName']?.toString();
//     if (mid != null) _selectedMountainId = mid;
//     if (mname != null) _selectedMountainName = mname;
//   }

//   if (widget.initialBooking != null) {
//     final b = widget.initialBooking!;
//     _initializeMemberFields(b.pax);
//     for (int i = 0; i < b.members.length && i < _nameControllers.length; i++) {
//       final m = b.members[i];
//       _nameControllers[i].text = m.name;
//       _ageControllers[i].text = (m.age ?? 0).toString();
//       _selectedGenders[i] = m.gender ?? 'M';
//       _selectedLevels[i] = m.level;
//       _selectedProfileIds[i] = null;
//       _isFromProfile[i] = false;
//     }
//     _selectedMountainName = b.gunungNama;
//     _pax = b.pax;
//     _porterHireSelected = b.porterRequired;
//   }

//   _updatePorterRequirement();

//   if (!mounted) return;
//   setState(() {
//     _profileLoaded = true;
//   });
// }


//   // --- lalu di initState() panggil _initAfterBuild():
//   @override
//   void initState() {
//     super.initState();

//     // initialize minimal fields so controllers exist quickly
//     _initializeMemberFields(widget.initialBooking?.pax ?? 1);

//     // run async init after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initAfterBuild();
//     });
//   }

//   String? _selectedMountainId;
//   String? _selectedMountainName;

//   void _initializeMemberFields(int paxCount) {
//   // safety: minimum 1
//   if (paxCount < 1) paxCount = 1;

 
//   if (paxCount == _pax && _nameControllers.length >= paxCount) {
//     _pax = paxCount;
//     return;
//   }

  
//   while (_nameControllers.length < paxCount) {
//     _nameControllers.add(TextEditingController());
//     _ageControllers.add(TextEditingController());
//     _selectedGenders.add('M');
//     _selectedLevels.add('beginner');
//     _selectedProfileIds.add(null);
//     _isFromProfile.add(false);
//   }

  
//   while (_nameControllers.length > paxCount) {
//     final idx = _nameControllers.length - 1;
//     _nameControllers[idx].dispose();
//     _ageControllers[idx].dispose();
//     _nameControllers.removeAt(idx);
//     _ageControllers.removeAt(idx);
//     _selectedGenders.removeAt(idx);
//     _selectedLevels.removeAt(idx);
//     _selectedProfileIds.removeAt(idx);
//     _isFromProfile.removeAt(idx);
//   }

//   _pax = paxCount;

 
//   if (_nameControllers.isNotEmpty) {
//     if (_nameControllers[0].text.isEmpty && _firstMemberName.isNotEmpty) {
//       _nameControllers[0].text = _firstMemberName;
//     }
//     if (_ageControllers[0].text.isEmpty && _firstMemberAge > 0) {
//       _ageControllers[0].text = _firstMemberAge.toString();
//     }
//   }
// }

// void _setPax(int newPax) {
//   _initializeMemberFields(newPax);
//   _updatePorterRequirement();
// }


//   void _updatePorterRequirement() {
  
//   final levels = List<String>.from(_selectedLevels);
//   while (levels.length < _pax) levels.add('beginner');

//   final beginnerCount = levels.where((l) => l == 'beginner').length;
//   final intermediateCount = levels.where((l) => l == 'intermediate').length;

//   if (beginnerCount == _pax && _pax > 0) {
//     _porterRequired = true;
//     _porterSuggested = false;
//   } else if (beginnerCount > 0 && intermediateCount >= 2) {
//     _porterRequired = false;
//     _porterSuggested = true;
//   } else {
//     _porterRequired = false;
//     _porterSuggested = false;
//   }

//   if (_porterRequired) _porterHireSelected = false;
//   setState(() {}); 
// }


//   bool _validateForm() {
    
//     for (int i = 0; i < _pax; i++) {
//       // For first member, check state variable; for others, check controller
//       final name = (i == 0) ? _firstMemberName : _nameControllers[i].text;
//       if (name.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Nama anggota ${i + 1} harus diisi')),
//         );
//         return false;
//       }
      
//       final age = (i == 0) ? _firstMemberAge.toString() : _ageControllers[i].text;
//       if (age.isEmpty || age == '0') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Usia anggota ${i + 1} harus diisi')),
//         );
//         return false;
//       }
//     }
//     return true;
//   }

//   // Future<void> _submitBooking() async {
//   //   if (!_validateForm()) return;

//   //   if (_climbingDate == null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Tanggal pendakian harus dipilih')),
//   //     );
//   //     return;
//   //   }

//   //   final request = context.read<CookieRequest>();

//   //   if (_porterRequired && !_porterHireSelected) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Booking ini wajib menyewa porter. Silakan pilih opsi sewa porter.')),
//   //     );
//   //     return;
//   //   }

   
//   //   List<Map<String, dynamic>> membersData = [];
//   //   if (_firstMemberProfileId != null && _firstMemberProfileId!.isNotEmpty) {
//   //     membersData.add({'profile_id': _firstMemberProfileId});
//   //   } else {
//   //     membersData.add({
//   //       'name': _firstMemberName,
//   //       'age': _firstMemberAge > 0 ? _firstMemberAge : null,
//   //       'gender': _firstMemberGender,
//   //       'level': _firstMemberLevel,
//   //     });
//   //   }

//   //   for (int i = 1; i < _pax; i++) {
//   //     final name = _nameControllers[i].text.trim();
//   //     final age = int.tryParse(_ageControllers[i].text.trim());
//   //     final gender = _selectedGenders[i];
//   //     final level = _selectedLevels[i];

//   //     membersData.add({
//   //       if (name.isNotEmpty) 'name': name,
//   //       if (age != null) 'age': age,
//   //       if (gender != null) 'gender': gender,
//   //       'level': level,
//   //     });
//   //   }

//   //   final payload = {
//   //     if ((_selectedMountainId ?? widget.mountainId) != null) 'gunung_id': _selectedMountainId ?? widget.mountainId,
//   //     // omit 'pax' to avoid mismatches; backend computes total pax
//   //     'anggota': membersData,
//   //     'porter_hire': _porterHireSelected ? 'yes' : 'no',
//   //     'climbing_date': _climbingDate!.toIso8601String().split('T').first,
//   //   };

//   //   try {
//   //     dynamic response;
//   //     if (widget.isEditing && widget.initialBooking != null) {
//   //       final id = widget.initialBooking!.id;
//   //       // note: backend view accepts POST for update at /booking/api/<id>/edit/
//   //       response = await request.post('http://localhost:8000/booking/api/$id/edit/', payload);
//   //     } else {
//   //       response = await request.post('http://localhost:8000/booking/api/book/', payload);
//   //     }

//   //     if (!mounted) return;

//   //     if (response != null && response['success'] == true) {
//   //       final bookingId = (response['booking_id'] ?? '').toString();

//   //       // create payment on backend (returns qris payload + amount)
//   //       final payResp = await request.post('http://localhost:8000/booking/api/$bookingId/pay/', {});
//   //       if (payResp != null && payResp['success'] == true) {
//   //         final qris = payResp['qris_payload'];
//   //         final amount = payResp['amount'];

//   //         // Navigate to Payment page with qris payload & amount from backend
//   //         if (!mounted) return;
//   //         Navigator.pushNamed(context, '/booking/payment', arguments: {
//   //           'bookingId': bookingId,
//   //           'totalAmount': amount,
//   //           'qris_payload': qris,
//   //         });
//   //       } else {
//   //         // fallback: navigate to booking summary (or show message)
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(content: Text(widget.isEditing ? 'Booking diperbarui.' : 'Booking dibuat.')),
//   //         );
//   //         if (!mounted) return;
//   //         Navigator.pushReplacementNamed(context, '/booking/summary', arguments: {'bookingId': bookingId});
//   //       }
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text(response?['message'] ?? 'Booking gagal')),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: $e')),
//   //     );
//   //   }
//   // }

//   Future<void> _submitBooking() async {
//   if (!_validateForm()) return;

//   if (_climbingDate == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Tanggal pendakian harus dipilih')),
//     );
//     return;
//   }

//   final request = context.read<CookieRequest>();

//   if (_porterRequired && !_porterHireSelected) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Booking ini wajib menyewa porter. Silakan pilih opsi sewa porter.')),
//     );
//     return;
//   }

//   // --- Build anggota list ---
//   List<Map<String, dynamic>> membersData = [];

//   if (_firstMemberProfileId != null && _firstMemberProfileId!.isNotEmpty) {
//     membersData.add({'profile_id': _firstMemberProfileId});
//   } else {
//     membersData.add({
//       'name': _firstMemberName.trim(),
//       'age': _firstMemberAge,
//       'gender': _firstMemberGender,
//       'level': _firstMemberLevel,
//     });
//   }

//   for (int i = 1; i < _pax; i++) {
//     final name = _nameControllers.length > i ? _nameControllers[i].text.trim() : '';
//     final age = _ageControllers.length > i ? int.tryParse(_ageControllers[i].text.trim()) : null;
//     final gender = _selectedGenders.length > i ? _selectedGenders[i] : 'M';
//     final level = _selectedLevels.length > i ? _selectedLevels[i] : 'beginner';
//     final profileId = _selectedProfileIds.length > i ? _selectedProfileIds[i] : null;

//     if (profileId != null && profileId.isNotEmpty) {
//       membersData.add({'profile_id': profileId});
//     } else {
//       final m = <String, dynamic>{};
//       if (name.isNotEmpty) m['name'] = name;
//       if (age != null) m['age'] = age;  // tetap integer
//       m['gender'] = gender;
//       m['level'] = level;
//       membersData.add(m);
//     }
//   }

//   final payload = {
//   'gunung_id': (_selectedMountainId ?? widget.mountainId).toString(), // pastikan string
//   'pax': _pax.toString(), 
//   'anggota': jsonEncode(membersData),
//   'porter_hire': _porterHireSelected ? 'yes' : 'no',
//   'climbing_date': _climbingDate!.toIso8601String().split('T').first,
// };


//   try {
//     dynamic response;
//     if (widget.isEditing && widget.initialBooking != null) {
//       final id = widget.initialBooking!.id;
//       response = await request.post('http://localhost:8000/booking/api/$id/edit/', payload);
//     } else {
//       response = await request.post('http://localhost:8000/booking/api/book/', payload);
//     }

//     if (!mounted) return;

//     if (response == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respon server kosong.')));
//       return;
//     }

//     String? bookingId;
//     if (response is Map<String, dynamic>) {
//       bookingId = response['booking_id']?.toString() ?? response['id']?.toString();
//     }

//     if (bookingId != null && bookingId.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(widget.isEditing ? 'Booking diperbarui.' : 'Booking berhasil dibuat.')),
//       );
//       Navigator.pushReplacementNamed(context, '/booking/summary', arguments: {'bookingId': bookingId});
//       return;
//     }

//     final msg = (response is Map) ? (response['message']?.toString() ?? 'Booking gagal') : 'Booking gagal';
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saat submit: $e')));
//   }
// }

//   @override
//   void dispose() {
//     for (var controller in _nameControllers) {
//       controller.dispose();
//     }
//     for (var controller in _ageControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppNavBar(title: 'Booking${widget.mountainName != null ? ' - ${widget.mountainName}' : ''}'),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Hero / intro header (merged landing)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFEED2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Rencanakan Pendakianmu',
//                       style: TextStyle(
//                         color: const Color(0xFF354024),
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Pilih gunung, tentukan jumlah peserta, dan kami akan rekomendasikan porter jika diperlukan.',
//                       style: TextStyle(color: const Color(0xFF294122), fontSize: 13),
//                     ),
//                     const SizedBox(height: 12),
//                     if (widget.mountainName == null)
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           // open mountains in select mode
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const AllMountainsPage(),
//                             ),
//                           );
//                           if (result is Map) {
//                             setState(() {
//                               // update selected mountain
//                               // note: widget fields are immutable; store in local state via controllers
//                             });
//                             // set local mountain via Temp variables by rebuilding via non-widget fields
//                             // For simplicity, use a small stateful holder below by calling setState and updating local vars
//                           }
//                         },
//                         icon: const Icon(Icons.terrain),
//                         label: const Text('Pilih Gunung'),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // If widget.mountainName == null show a placeholder card prompting selection
//               if (widget.mountainName == null)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE5D7C4),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text('Belum memilih gunung — klik "Pilih Gunung" untuk memilih.'),
//                 ),
//               const SizedBox(height: 12),
//               // Mountain Info Card
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE8F5E9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Lokasi Pendakian',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF2E7D32),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _selectedMountainName ?? widget.mountainName ?? 'Belum dipilih',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // PAX Selector
//               const Text(
//                 'Jumlah Peserta',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: _pax > 1
//                         ? () {
//                             _initializeMemberFields(_pax - 1);
//                             _updatePorterRequirement();
//                           }
//                         : null,
//                     icon: const Icon(Icons.remove_circle),
//                   ),
//                   Expanded(
//                     child: Container(
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '$_pax Orang',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: _pax < 10
//                         ? () {
//                             _initializeMemberFields(_pax + 1);
//                             _updatePorterRequirement();
//                           }
//                         : null,
//                     icon: const Icon(Icons.add_circle),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // Climbing Date Selector
//               const Text(
//                 'Tanggal Pendakian',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               GestureDetector(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: _climbingDate ?? DateTime.now().add(const Duration(days: 1)),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(const Duration(days: 365)),
//                   );
//                   if (picked != null) {
//                     setState(() {
//                       _climbingDate = picked;
//                     });
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _climbingDate == null
//                             ? 'Pilih tanggal'
//                             : '${_climbingDate!.day}/${_climbingDate!.month}/${_climbingDate!.year}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: _climbingDate == null ? Colors.grey[400] : Colors.black,
//                         ),
//                       ),
//                       Icon(Icons.calendar_today, color: Colors.grey[600]),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Members List
//               const Text(
//                 'Data Peserta',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _pax,
//                 itemBuilder: (context, index) {
//                   return _buildMemberCard(index);
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Porter info / selection
//               if (_porterRequired || _porterSuggested)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: _porterRequired ? Colors.orange[50] : Colors.yellow[50],
//                     border: Border.all(color: _porterRequired ? Colors.orange : Colors.amber),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(_porterRequired ? Icons.warning : Icons.info, color: _porterRequired ? Colors.orange : Colors.amber),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               _porterRequired
//                                   ? 'Semua peserta adalah pemula — booking ini mewajibkan penyewaan porter.'
//                                   : 'Terdapat peserta pemula dan beberapa peserta menengah (≥2). Disarankan menyewa porter untuk keamanan.',
//                               style: TextStyle(
//                                 color: _porterRequired ? Colors.orange[900] : Colors.brown[800],
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       // Hire toggle
//                       Row(
//                         children: [
//                           Expanded(
//                             child: CheckboxListTile(
//                               contentPadding: EdgeInsets.zero,
//                               value: _porterHireSelected,
//                               onChanged: (v) {
//                                 setState(() {
//                                   _porterHireSelected = v ?? false;
//                                 });
//                               },
//                               title: const Text('Sewa Porter (Rp 250,000)'),
//                               controlAffinity: ListTileControlAffinity.leading,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 24),

//               // Summary Section
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Ringkasan',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text('Peserta × Rp 500,000'),
//                         Text(
//                           'Rp ${_pax * 500000}',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     if (_porterRequired) ...[
//                       const SizedBox(height: 8),
//                       const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Porter × Rp 250,000'),
//                           Text(
//                             'Rp 250,000',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ],
//                     Divider(color: Colors.grey[300]),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Total',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'Rp ${(_pax * 500000) + (_porterRequired ? 250000 : 0)}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _submitBooking,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2E7D32),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Selesai Booking',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _pickProfileForIndex(int index) async {
//   final request = context.read<CookieRequest>();
//   String query = '';
//   List<Map<String,dynamic>> results = [];

  
//   final search = await showDialog<String?>(
//     context: context,
//     builder: (ctx) {
//       String q = '';
//       return AlertDialog(
//         title: const Text('Cari profile'),
//         content: TextField(
//           autofocus: true,
//           decoration: const InputDecoration(hintText: 'Masukkan username atau nama'),
//           onChanged: (v) => q = v,
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Batal')),
//           TextButton(onPressed: () => Navigator.pop(ctx, q.trim()), child: const Text('Cari')),
//         ],
//       );
//     }
//   );

//   if (search == null || search.isEmpty) return;
//   query = search;

//   try {
//     final url = 'http://localhost:8000/booking/api/profiles/?search=${Uri.encodeQueryComponent(query)}';
//     final resp = await request.get(url);

   
//     if (resp is Map && resp['profiles'] is List) {
//       results = List<Map<String,dynamic>>.from(resp['profiles'] as List);
//     } else if (resp is List) {
//       results = List<Map<String,dynamic>>.from(resp);
//     } else {
//       results = [];
//     }


//     final sel = await showDialog<Map<String,dynamic>?>(
//       context: context,
//       builder: (ctx) {
//         return SimpleDialog(
//           title: Text('Pilih profile (${results.length})'),
//           children: results.isNotEmpty
//             ? results.map((r) => SimpleDialogOption(
//                 onPressed: () => Navigator.pop(ctx, r),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [Text(r['name'] ?? r['username'] ?? r['username']), Text(r['profile_id']?.toString() ?? '')],
//                 ),
//               )).toList()
//             : [Padding(padding: const EdgeInsets.all(12), child: Text('Tidak ada hasil'))],
//         );
//       }
//     );

//     if (sel != null) {
//       // apply to index
//       setState(() {
//         _selectedProfileIds[index] = sel['profile_id']?.toString() ?? sel['id']?.toString();
//         _isFromProfile[index] = true;
//         // fill controllers and selects
//         final name = sel['name'] ?? sel['username'] ?? '';
//         final ageVal = sel['age'];
//         final gender = sel['gender'];
//         final level = sel['level'];
//         _nameControllers[index].text = name;
//         if (ageVal != null) _ageControllers[index].text = ageVal.toString();
//         _selectedGenders[index] = (gender?.toString() ?? 'M');
//         _selectedLevels[index] = (level?.toString() ?? 'beginner');
//         _updatePorterRequirement();
//       });
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error mencari profile: $e')));
//   }
// }


//   Widget _buildMemberCard(int index) {
//   final isFirstMember = index == 0;
//   // safety: pastikan lists ada slot index
//   if (_nameControllers.length <= index) {
//     _initializeMemberFields(index + 1);
//   }
//   final fromProfile = (_selectedProfileIds.length > index && _selectedProfileIds[index] != null);

//   return Container(
//     margin: const EdgeInsets.only(bottom: 16),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey[300]!),
//       borderRadius: BorderRadius.circular(12),
//       color: isFirstMember ? Colors.blue[50] : Colors.white,
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text('Peserta ${index + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//             if (isFirstMember)
//               Container(
//                 margin: const EdgeInsets.only(left: 8),
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(4)),
//                 child: const Text('Anda', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
//               ),
//             const Spacer(),
//             if (!isFirstMember) ...[
//               IconButton(icon: const Icon(Icons.person_search), tooltip: 'Pilih profile yang sudah terdaftar', onPressed: () => _pickProfileForIndex(index)),
//               if (fromProfile)
//                 IconButton(icon: const Icon(Icons.clear), tooltip: 'Hapus pilihan profile', onPressed: () {
//                   setState(() {
//                     _selectedProfileIds[index] = null;
//                     _isFromProfile[index] = false;
//                     _nameControllers[index].text = '';
//                     _ageControllers[index].text = '';
//                     _selectedGenders[index] = 'M';
//                     _selectedLevels[index] = 'beginner';
//                     _updatePorterRequirement();
//                   });
//                 }),
//             ],
//           ],
//         ),
//         const SizedBox(height: 12),

//         if (isFirstMember)
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
//             child: _profileLoaded
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _nameControllers.isNotEmpty && _nameControllers[0].text.isNotEmpty
//                             ? _nameControllers[0].text
//                             : (_firstMemberName.isNotEmpty ? _firstMemberName : 'Nama tidak tersedia'),
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Usia: ${_ageControllers.isNotEmpty && _ageControllers[0].text.isNotEmpty ? _ageControllers[0].text : (_firstMemberAge > 0 ? _firstMemberAge : '-')}'),
//                           Text('Gender: ${_selectedGenders.isNotEmpty ? (_selectedGenders[0] == 'M' ? 'Laki-laki' : _selectedGenders[0] == 'F' ? 'Perempuan' : 'Lainnya') : '-'}'),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text('Level: ${_selectedLevels.isNotEmpty ? (_selectedLevels[0][0].toUpperCase() + _selectedLevels[0].substring(1)) : _firstMemberLevel}'),
//                     ],
//                   )
//                 : const Center(child: CircularProgressIndicator()),
//           )
//         else
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (fromProfile)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Row(children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(color: Colors.green[50], border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(8)),
//                       child: Row(children: [
//                         const Icon(Icons.person, size: 16, color: Colors.green),
//                         const SizedBox(width: 6),
//                         Flexible(child: Text('Diisi dari profile (ID: ${_selectedProfileIds[index]})', style: const TextStyle(fontSize: 12, color: Colors.green), overflow: TextOverflow.ellipsis)),
//                       ]),
//                     ),
//                   ]),
//                 ),
//               TextField(controller: _nameControllers[index], decoration: InputDecoration(labelText: 'Nama', hintText: 'Masukkan nama lengkap', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
//               const SizedBox(height: 12),
//               Row(children: [
//                 Expanded(child: TextField(controller: _ageControllers[index], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Usia', hintText: 'Usia dalam tahun', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedGenders[index],
//                     onChanged: (v) => setState(() => _selectedGenders[index] = v ?? 'M'),
//                     items: const [
//                       DropdownMenuItem(value: 'M', child: Text('Laki-laki')),
//                       DropdownMenuItem(value: 'F', child: Text('Perempuan')),
//                       DropdownMenuItem(value: 'O', child: Text('Lainnya')),
//                     ],
//                     decoration: InputDecoration(labelText: 'Jenis Kelamin', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
//                   ),
//                 ),
//               ]),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: _selectedLevels[index],
//                 onChanged: (v) {
//                   if (v != null) {
//                     setState(() {
//                       _selectedLevels[index] = v;
//                       _updatePorterRequirement();
//                     });
//                   }
//                 },
//                 items: const [
//                   DropdownMenuItem(value: 'beginner', child: Text('Pemula')),
//                   DropdownMenuItem(value: 'intermediate', child: Text('Menengah')),
//                   DropdownMenuItem(value: 'advanced', child: Text('Mahir')),
//                 ],
//                 decoration: InputDecoration(labelText: 'Level Pendaki', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
//               ),
//             ],
//           )
//       ],
//     ),
//   );
// }


// }
