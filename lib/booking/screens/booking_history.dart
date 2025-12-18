// lib/booking/screens/booking_history.dart
import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/booking/screens/booking_summary.dart';
import 'package:mounttrack_mobile/booking/models/booking.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_navbar.dart';
import '../../userprofile/screens/login.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const sacramento = Color(0xFF102114);
  static const tangerine = Color(0xFFEB3D00);
  static const chiffon = Color(0xFFFFEED2);
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);


  List<Booking> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final request = context.read<CookieRequest>();

    // Check if user is logged in
    if (!request.loggedIn) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Silakan login untuk melihat riwayat booking';
          _bookings = [];
        });
      }
      return;
    }

    try {
      // gunakan endpoint API yang lebih konsisten
      final resp = await request.get('http://localhost:8000/booking/api/history/');

      List<dynamic> rawList = [];
      if (resp == null) {
        rawList = [];
      } else if (resp is Map && resp.containsKey('bookings') && resp['bookings'] is List) {
        rawList = resp['bookings'] as List<dynamic>;
      } else if (resp is List) {
        rawList = resp;
      } else {
        // jika server membungkus payload dengan key 'data' atau 'results', tambahkan fallback:
        if (resp is Map && resp['data'] is List) {
          rawList = resp['data'] as List<dynamic>;
        } else {
          throw Exception('Format response tidak dikenali');
        }
      }

      final list = rawList.map<Booking?>((e) {
        try {
          return Booking.fromJson(e as Map<String, dynamic>);
        } catch (err) {
          debugPrint('Parse booking error: $err');
          return null;
        }
      }).whereType<Booking>().toList();

      if (mounted) {
        setState(() => _bookings = list);
      }
    } catch (e, st) {
      debugPrint('Fetch history error: $e\n$st');
      if (mounted) setState(() => _error = 'Gagal memuat riwayat: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteBooking(int bookingId) async {
    final request = context.read<CookieRequest>();
    try {
      debugPrint('=== DELETE BOOKING ===');
      debugPrint('Booking ID: $bookingId');
      debugPrint('URL: http://localhost:8000/booking/api/delete/$bookingId/');
      
      final response = await request.post(
        'http://localhost:8000/booking/api/delete/$bookingId/',
        {},
      );
      
      debugPrint('Response type: ${response.runtimeType}');
      debugPrint('Response: $response');
      
      if (mounted) {
        // Check if response indicates success
        bool success = false;
        if (response is Map && response['success'] == true) {
          success = true;
        }
        
        if (success) {
          await _fetchHistory();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Riwayat booking berhasil dihapus')),
          );
        } else {
          final errorMsg = response is Map 
              ? response['message'] ?? 'Gagal menghapus booking'
              : 'Gagal menghapus booking (Response: $response)';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } catch (e, st) {
      debugPrint('Delete error: $e');
      debugPrint('Stack trace: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(int bookingId, String gunungNama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: chiffon,
        title: Text('Hapus Riwayat', style: TextStyle(color: sacramento, fontWeight: FontWeight.bold)),
        content: Text('Yakin ingin menghapus riwayat booking untuk $gunungNama?', style: TextStyle(color: cafeNoir)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: mossGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBooking(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tangerine,
              foregroundColor: bone,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: 'Riwayat Booking'),
      backgroundColor: bone,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _error == 'Silakan login untuk melihat riwayat booking'
                                ? Icons.lock_outline
                                : Icons.error_outline,
                            size: 48,
                            color: tangerine,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cafeNoir, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          if (_error == 'Silakan login untuk melihat riwayat booking')
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kombuGreen,
                                foregroundColor: bone,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              ),
                              icon: const Icon(Icons.login),
                              label: const Text('Login'),
                            )
                          else
                            ElevatedButton(
                              onPressed: _fetchHistory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kombuGreen,
                                foregroundColor: bone,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                        ],
                      ),
                    ),
                  )
                : _bookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: mossGreen.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('Belum ada riwayat booking.', style: TextStyle(color: cafeNoir, fontSize: 16)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kombuGreen,
                                foregroundColor: bone,
                              ),
                              child: const Text('Kembali'),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: ListView.separated(
                          itemCount: _bookings.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final b = _bookings[index];
                            final displayDate = (b.climbingDate != null && b.climbingDate!.isNotEmpty)
                                ? b.climbingDate!
                                : (b.createdAt.isNotEmpty ? b.createdAt : '-');

                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              color: chiffon,
                              child: SizedBox(
                                height: 120,
                                child: Row(
                                  children: [
                                    // image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                      child: Container(
                                        width: 140,
                                        height: double.infinity,
                                        color: tan.withOpacity(0.3),
                                        child: b.gunungImage != null && b.gunungImage!.isNotEmpty
                                            ? Image.network(
                                                b.gunungImage!,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (ctx, child, progress) {
                                                  if (progress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: progress.expectedTotalBytes != null
                                                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (_, __, ___) {
                                                  return Container(
                                                    color: tan.withOpacity(0.3),
                                                    child: Center(
                                                      child: Icon(Icons.landscape, color: mossGreen, size: 40),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Center(
                                                child: Icon(Icons.landscape, color: mossGreen, size: 40),
                                              ),
                                      ),
                                    ),
                                    // info
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.gunungNama ?? '-',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: sacramento,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              displayDate,
                                              style: TextStyle(fontSize: 13, color: cafeNoir.withOpacity(0.7)),
                                            ),
                                            Text(
                                              'Peserta: ${b.pax}',
                                              style: TextStyle(fontSize: 12, color: mossGreen, fontWeight: FontWeight.w600),
                                            ),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (ctx) => BookingSummaryPage(booking: b),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: kombuGreen,
                                                    foregroundColor: bone,
                                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                  ),
                                                  child: const Text('Lihat', style: TextStyle(fontSize: 12)),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  onPressed: () => _showDeleteConfirmation(b.id, b.gunungNama ?? 'Booking'),
                                                  icon: Icon(Icons.delete_outline, color: tangerine, size: 20),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
