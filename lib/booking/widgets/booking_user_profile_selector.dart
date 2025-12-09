import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/booking_user_profile.dart';

class BookingUserProfileSelector extends StatefulWidget {
  final Function(BookingUserProfile?) onSelected;
  final BookingUserProfile? initialProfile;
  final String hint;
  final bool isFirstMember;

  const BookingUserProfileSelector({
    super.key,
    required this.onSelected,
    this.initialProfile,
    this.hint = 'Pilih Peserta',
    this.isFirstMember = false,
  });

  @override
  State<BookingUserProfileSelector> createState() => _BookingUserProfileSelectorState();
}

class _BookingUserProfileSelectorState extends State<BookingUserProfileSelector> {
  List<BookingUserProfile> _profiles = [];
  BookingUserProfile? _selectedProfile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedProfile = widget.initialProfile;
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final request = context.read<CookieRequest>();

    try {
      // Endpoint untuk mendapatkan daftar user profiles
      // Sesuaikan dengan backend Anda
      final response = await request.get('http://localhost:8000/booking/api/profiles/');

      if (response is List) {
        setState(() {
          _profiles = response
              .map((e) {
                final map = Map<String, dynamic>.from(e as Map);
                return BookingUserProfile.fromJson(map);
              })
              .toList();
          _loading = false;
        });
      } else if (response is Map) {
        // Jika response berbentuk {results: [...]}
        final results = response['results'];
        if (results is List) {
          setState(() {
            _profiles = results
                .map((e) {
                  final map = Map<String, dynamic>.from(e as Map);
                  return BookingUserProfile.fromJson(map);
                })
                .toList();
            _loading = false;
          });
        } else {
          setState(() {
            _error = 'Format response tidak dikenali';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Gagal memuat daftar peserta';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 48,
        child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _error!,
          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
        ),
      );
    }

    return DropdownButton<BookingUserProfile>(
      isExpanded: true,
      value: _selectedProfile,
      hint: Text(widget.hint),
      items: _profiles
          .map((profile) => DropdownMenuItem(
                value: profile,
                child: Text('${profile.nama} (${profile.categoryExperience})'),
              ))
          .toList(),
      onChanged: (BookingUserProfile? newValue) {
        setState(() {
          _selectedProfile = newValue;
        });
        widget.onSelected(newValue);
      },
    );
  }
}
