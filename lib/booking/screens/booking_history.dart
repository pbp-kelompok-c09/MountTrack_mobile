// lib/booking/screens/booking_history.dart
import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/booking/screens/booking_summary.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../../widgets/app_navbar.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
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

    try {
      // gunakan endpoint API yang lebih konsisten
      final resp = await request.get('http://localhost:8000/booking/api/history/');

      List<dynamic> rawList = [];
      if (resp == null) {
        rawList = [];
      } else if (resp is Map && resp.containsKey('bookings') && resp['bookings'] is List) {
        rawList = resp['bookings'] as List<dynamic>;
      } else if (resp is List) {
        rawList = resp as List<dynamic>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: 'Riwayat Booking'),
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
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _fetchHistory, child: const Text('Coba Lagi')),
                        ],
                      ),
                    ),
                  )
                : _bookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Belum ada riwayat booking.'),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
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
                            // prefer climbingDate, fallback createdAt
                            final displayDate = (b.climbingDate != null && b.climbingDate!.isNotEmpty)
                                ? b.climbingDate!
                                : (b.createdAt.isNotEmpty ? b.createdAt : '-');

                            // gunakan getter imageUrl di Booking jika mau sediakan gambar (sekarang null)
                            // imageUrl = (b.imageUrl ?? '').toString();
                      final imageUrl = (b.imageUrl ?? '').toString();
                      final effectiveImage = imageUrl.isNotEmpty
                          ? imageUrl
                          : 'https://picsum.photos/seed/mountain${b.id}/600/400'; // dummy unik per booking

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: SizedBox(
                          height: 110,
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
                                  color: Colors.grey[200],
                                  child: Image.network(
                                    effectiveImage,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null));
                                    },
                                    errorBuilder: (_, __, ___) {
                                      return Image.network('https://picsum.photos/seed/mountain_fallback/600/400', fit: BoxFit.cover);
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
                                          children: [
                                            Text(
                                              b.gunungNama ?? '-',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(displayDate, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
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
                                                  child: const Text('Lihat Riwayat'),
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
