// lib/booking/screens/booking_summary.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../booking/models/booking.dart';
import '../../widgets/app_navbar.dart';
import 'payment_page.dart';
import 'edit_booking_page.dart';
import 'booking_history.dart';

class BookingSummaryPage extends StatefulWidget {
  final Booking? booking;
  const BookingSummaryPage({super.key, this.booking});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
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

  Booking? _booking;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _booking = widget.booking;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFromArgs());
    }
  }

  Future<void> _fetchFromArgs() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? bookingId;
    if (args is Map && args['bookingId'] != null) {
      bookingId = args['bookingId'].toString();
    } else if (args is String) {
      bookingId = args;
    }

    if (bookingId == null || bookingId.isEmpty) {
      setState(() {
        _error = 'Tidak ditemukan bookingId di arguments.';
      });
      return;
    }

    await _fetchBookingById(bookingId);
  }

  Future<void> _fetchBookingById(String bookingId) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final request = context.read<CookieRequest>();

    try {
      final candidates = [
        'http://localhost:8000/booking/api/$bookingId/',
        'http://localhost:8000/booking/api/$bookingId/detail/',
        'http://localhost:8000/booking/api/detail/$bookingId/',
        'http://localhost:8000/booking/api/get/$bookingId/',
      ];

      dynamic resp;
      for (final url in candidates) {
        try {
          resp = await request.get(url);
          if (resp != null) break;
        } catch (_) {}
      }

      if (resp == null) {
        throw Exception('Tidak mendapatkan response dari server.');
      }

      if (resp is Map<String, dynamic>) {
        if (resp.containsKey('booking')) {
          setState(() {
            _booking = Booking.fromJson(resp['booking']);
            _loading = false;
          });
        } else {
          setState(() {
            _booking = Booking.fromJson(resp);
            _loading = false;
          });
        }
      } else if (resp is List && resp.isNotEmpty) {
        final first = resp.first;
        if (first is Map<String, dynamic>) {
          setState(() {
            _booking = Booking.fromJson(first);
            _loading = false;
          });
        } else {
          throw Exception('Format response tidak dikenali.');
        }
      } else {
        throw Exception('Format response tidak dikenali.');
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat booking: $e';
        _loading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final args = ModalRoute.of(context)?.settings.arguments;
                  String? bookingId;
                  if (args is Map && args['bookingId'] != null) {
                    bookingId = args['bookingId'].toString();
                  }
                  if (bookingId != null) _fetchBookingById(bookingId);
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_booking == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tidak ada data booking untuk ditampilkan.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      );
    }

    final b = _booking!;
    final pax = b.pax ?? 0;
    final porter = (b.porterRequired ?? false) ? 250000 : 0;
    final total = pax * 500000 + porter;
    final dateDisplay = (b.climbingDate != null && b.climbingDate!.isNotEmpty)
        ? b.climbingDate!
        : (b.createdAt ?? '-');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    'Ringkasan Booking',
                    style: TextStyle(
                      color: bone,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.terrain, color: chiffon, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b.gunungNama ?? '-',
                          style: const TextStyle(
                            color: bone,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: tan, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: chiffon,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('ID Booking', b.id.toString()),
                  const SizedBox(height: 12),
                  _buildDetailRow('Peserta', '$pax orang'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Tanggal Pendakian', dateDisplay),
                  const SizedBox(height: 12),
                  _buildDetailRow('Porter', (b.porterRequired ?? false) ? 'Wajib' : 'Tidak diperlukan'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Status Pemesanan', 'Dibuat: ${b.createdAt ?? '-'}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: tan, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
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
                  const SizedBox(height: 12),
                  if (b.members.isEmpty)
                    const Text(
                      '- Tidak ada anggota tercatat -',
                      style: TextStyle(color: tan),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...b.members.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final m = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: mossGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${idx + 1}',
                                      style: const TextStyle(
                                        color: bone,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: cafeNoir,
                                        ),
                                      ),
                                      Text(
                                        m.level ?? 'beginner',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cafeNoir.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (m.age != null)
                                  Text(
                                    '${m.age} thn',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: tan,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [chiffon, bone],
                ),
                border: Border.all(color: tan),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Biaya',
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
                        '$pax Peserta × Rp 500.000',
                        style: const TextStyle(fontSize: 12, color: cafeNoir),
                      ),
                      Text(
                        'Rp ${(pax * 500000).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cafeNoir,
                        ),
                      ),
                    ],
                  ),
                  if (porter > 0)
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
                            'Rp ${porter.toStringAsFixed(0)}',
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
                        'Rp ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          bookingId: b.id.toString(),
                          totalAmount: total,
                          qrisPayload: null,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mossGreen,
                    foregroundColor: bone,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Lanjut ke Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBookingPage(booking: b),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tangerine,
                    foregroundColor: bone,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Booking',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cafeNoir,
                    side: const BorderSide(color: cafeNoir),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Kembali ke Home'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingHistoryPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Lihat Riwayat Booking',
                    style: TextStyle(color: mossGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: cafeNoir,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: cafeNoir,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bone,
      appBar: AppNavBar(title: 'Booking Summary'),
      body: _buildBody(),
    );
  }
}


// // lib/booking/screens/booking_summary.dart
// import 'package:flutter/material.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';
// import '../../booking/models/booking.dart';
// import '../../widgets/app_navbar.dart';
// import 'edit_booking_page.dart';
// import 'booking_history.dart';

// class BookingSummaryPage extends StatefulWidget {
//   /// If you already have booking object, pass it; otherwise page will try to fetch by bookingId from route arguments.
//   final Booking? booking;
//   const BookingSummaryPage({super.key, this.booking});

//   @override
//   State<BookingSummaryPage> createState() => _BookingSummaryPageState();
// }

// class _BookingSummaryPageState extends State<BookingSummaryPage> {
//   Booking? _booking;
//   bool _loading = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.booking != null) {
//       _booking = widget.booking;
//     } else {
//       // fetch after first frame so ModalRoute is available
//       WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFromArgs());
//     }
//   }

//   Future<void> _fetchFromArgs() async {
//     final args = ModalRoute.of(context)?.settings.arguments;
//     String? bookingId;
//     if (args is Map && args['bookingId'] != null) {
//       bookingId = args['bookingId'].toString();
//     } else if (args is String) {
//       bookingId = args;
//     }

//     if (bookingId == null || bookingId.isEmpty) {
//       setState(() {
//         _error = 'Tidak ditemukan bookingId di arguments.';
//       });
//       return;
//     }

//     await _fetchBookingById(bookingId);
//   }

//   Future<void> _fetchBookingById(String bookingId) async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     final request = context.read<CookieRequest>();

//     try {
//       // candidate endpoints — sesuaikan jika backend-mu hanya punya satu endpoint
//       final candidates = [
//         'http://localhost:8000/booking/api/$bookingId/',
//         'http://localhost:8000/booking/api/$bookingId/detail/',
//         'http://localhost:8000/booking/api/detail/$bookingId/',
//         'http://localhost:8000/booking/api/get/$bookingId/',
//       ];

//       dynamic resp;
//       for (final url in candidates) {
//         try {
//           resp = await request.get(url);
//           if (resp != null) break;
//         } catch (_) {
//           // try next candidate
//         }
//       }

//       if (resp == null) {
//         throw Exception('Tidak mendapatkan response dari server (cek endpoint).');
//       }

//       if (resp is Map<String, dynamic>) {
//         setState(() {
//           _booking = Booking.fromJson(resp);
//           _loading = false;
//         });
//       } else if (resp is List && resp.isNotEmpty) {
//         final first = resp.first;
//         if (first is Map<String, dynamic>) {
//           setState(() {
//             _booking = Booking.fromJson(first);
//             _loading = false;
//           });
//         } else {
//           throw Exception('Format response tidak dikenali.');
//         }
//       } else {
//         throw Exception('Format response tidak dikenali.');
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Gagal memuat booking: $e';
//         _loading = false;
//       });
//     }
//   }

//   Widget _buildBody() {
//     if (_loading) return const Center(child: CircularProgressIndicator());

//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: () {
//                   final args = ModalRoute.of(context)?.settings.arguments;
//                   String? bookingId;
//                   if (args is Map && args['bookingId'] != null) bookingId = args['bookingId'].toString();
//                   if (bookingId != null) _fetchBookingById(bookingId);
//                 },
//                 child: const Text('Coba Lagi'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_booking == null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Tidak ada data booking untuk ditampilkan.'),
//             const SizedBox(height: 12),
//             ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
//           ],
//         ),
//       );
//     }

//     final b = _booking!;
//     final pax = b.pax ?? 0;
//     final porter = (b.porterRequired ?? false) ? 250000 : 0;
//     final total = pax * 500000 + porter;
//     final dateDisplay = (b.climbingDate != null && b.climbingDate!.isNotEmpty) ? b.climbingDate! : (b.createdAt ?? '-');

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Gunung: ${b.gunungNama ?? '-'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text('Peserta: ${pax}'),
//           const SizedBox(height: 8),
//           Text('Tanggal Pendakian: $dateDisplay'),
//           const SizedBox(height: 12),
//           const Text('Anggota:', style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           if (b.members.isEmpty)
//             const Text('- Tidak ada anggota tercatat -')
//           else
//             ...b.members.map((m) => Text('- ${m.name} (${m.level ?? '-'})')),
//           const Spacer(),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 Text('Rp $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => EditBookingPage(booking: b)));
//                   },
//                   child: const Text('Edit Booking'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.popUntil(context, (route) => route.isFirst);
//                   },
//                   child: const Text('Kembali ke Home'),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Center(
//             child: TextButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingHistoryPage()));
//               },
//               child: const Text('Lihat Riwayat Booking'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppNavBar(title: 'Booking Summary'),
//       body: _buildBody(),
//     );
//   }
// }
