// lib/booking/screens/booking_history.dart
import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/booking/screens/booking_summary.dart';
import 'package:mounttrack_mobile/booking/screens/booking_landing.dart';
import 'package:mounttrack_mobile/booking/models/booking.dart';
import 'package:mounttrack_mobile/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../userprofile/screens/login.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _fetchHistory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data setiap kali page di-resume (kembali dari page lain)
      _fetchHistory();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
          _error = 'Silakan login untuk melihat riwayat pesanan';
          _bookings = [];
        });
      }
      return;
    }

    try {
      // gunakan endpoint API yang lebih konsisten
      final resp = await request.get('${AppConfig.baseUrl}/booking/api/history/');

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
          final booking = Booking.fromJson(e as Map<String, dynamic>);
          debugPrint('=== BOOKING FROM API ===');
          debugPrint('Booking ID: ${booking.id}');
          debugPrint('Mountain Name: ${booking.gunungNama}');
          debugPrint('Mountain Image: ${booking.gunungImage}');
          debugPrint('Raw JSON keys: ${(e as Map<String, dynamic>).keys.toList()}');
          return booking;
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
      debugPrint('URL: ${AppConfig.baseUrl}/booking/api/delete/$bookingId/');
      
      final response = await request.post(
        '${AppConfig.baseUrl}/booking/api/delete/$bookingId/',
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
            const SnackBar(content: Text('Riwayat pemasanan berhasil dihapus')),
          );
        } else {
          final errorMsg = response is Map 
              ? response['message'] ?? 'Gagal menghapus pesanan'
              : 'Gagal menghapus pesanan (Response: $response)';
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
        content: Text('Yakin ingin menghapus riwayat pesanan untuk $gunungNama?', style: TextStyle(color: cafeNoir)),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: kombuGreen,
          title: const Text(
            'Riwayat Pesanan',
            style: TextStyle(color: Color(0xFFE5D7C4), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 2,
        ),
      ),
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
                            _error == 'Silakan login untuk melihat riwayat pesanan'
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
                          if (_error == 'Silakan login untuk melihat riwayat pesanan')
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
                            Text('Belum ada riwayat pesanan.', style: TextStyle(color: cafeNoir, fontSize: 16)),
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
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemCount: _bookings.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final b = _bookings[index];
                                  final displayDate = (b.climbingDate != null && b.climbingDate!.isNotEmpty)
                                      ? b.climbingDate!
                                      : (b.createdAt.isNotEmpty ? b.createdAt : '-');

                                  // Build image URL with fallback (like Django template)
                                  final imageUrl = (b.gunungImage != null && b.gunungImage!.isNotEmpty)
                                      ? b.gunungImage!
                                      : 'https://picsum.photos/seed/mountain${b.id}/400/400';

                                      
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 6,
                                    shadowColor: cafeNoir.withOpacity(0.2),
                                    color: chiffon,
                                    child: SizedBox(
                                      height: 140,
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
                                              child: Image.network(
                                                imageUrl,
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
                                                  // Fallback to another random image if network fails
                                                  return Container(
                                                    color: tan.withOpacity(0.3),
                                                    child: Center(
                                                      child: Icon(Icons.landscape, color: mossGreen, size: 40),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          // info
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
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
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Peserta: ${b.pax}',
                                                            style: TextStyle(fontSize: 12, color: mossGreen, fontWeight: FontWeight.w600),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                            decoration: BoxDecoration(
                                                              color: b.isPaid ? mossGreen.withOpacity(0.15) : tangerine.withOpacity(0.15),
                                                              borderRadius: BorderRadius.circular(6),
                                                              border: Border.all(
                                                                color: b.isPaid ? mossGreen : tangerine,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              b.isPaid ? '✓ Sudah Terbayar' : '⏱ Belum Terbayar',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: b.isPaid ? mossGreen : tangerine,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
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
                                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                            ),
                                                            child: const Text('Lihat', style: TextStyle(fontSize: 11)),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          IconButton(
                                                            onPressed: () => _showDeleteConfirmation(b.id, b.gunungNama ?? 'Booking'),
                                                            icon: Icon(Icons.delete_outline, color: tangerine, size: 20),
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
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
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.home),
                              label: const Text('Kembali ke Beranda Pemesanan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kombuGreen,
                                foregroundColor: bone,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                minimumSize: const Size.fromHeight(44),
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
