// lib/booking/screens/booking_summary.dart
import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../booking/models/booking.dart';
import '../../widgets/app_navbar.dart';
import 'payment_page.dart';
import 'edit_booking_page.dart';

class BookingSummaryPage extends StatefulWidget {
  final Booking? booking;
  const BookingSummaryPage({super.key, this.booking});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> with WidgetsBindingObserver {
  
  static const Color cafeNoir = Color(0xFF4C3019);
  static const Color kombuGreen = Color(0xFF354024);
  static const Color mossGreen = Color(0xFF889063);
  static const Color tan = Color(0xFFCFBB99);
  static const Color bone = Color(0xFFE5D7C4);
  static const Color pine = Color(0xFF294122);
  static const Color chiffon = Color(0xFFFFFEE2);
  static const Color tangerine = Color(0xFFEB3D00);

  Booking? _booking;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.booking != null) {
      _booking = widget.booking;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFromArgs());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _booking != null) {
      // Refresh data setiap kali page di-resume
      _fetchBookingById(_booking!.id.toString());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
        '${AppConfig.baseUrl}/booking/api/$bookingId/',
        '${AppConfig.baseUrl}/booking/api/$bookingId/detail/',
        '${AppConfig.baseUrl}/booking/api/detail/$bookingId/',
        '${AppConfig.baseUrl}/booking/api/get/$bookingId/',
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
        _error = 'Gagal memuat pesanan: $e';
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
            const Text('Tidak ada data pesanan untuk ditampilkan.'),
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
    final pax = b.pax;
    final porter = (b.porterRequired) ? 250000 : 0;
    final total = pax * 500000 + porter;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(b.id.toString()),
            const SizedBox(height: 12),

            _buildConfirmationCard(),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildMountainInfoCard(b, pax),
                            const SizedBox(height: 12),
                            _buildMembersCard(b),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right Column
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildCostSummaryCard(pax, porter, total),
                            const SizedBox(height: 12),
                            _buildActionsCard(b),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
              
                  return Column(
                    children: [
                      _buildMountainInfoCard(b, pax),
                      const SizedBox(height: 12),
                      _buildMembersCard(b),
                      const SizedBox(height: 12),
                      _buildCostSummaryCard(pax, porter, total),
                      const SizedBox(height: 12),
                      _buildActionsCard(b),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            // Bottom Action Buttons
            _buildBottomActionButtons(b, pax, porter, b.isPaid),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String bookingId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kombuGreen, mossGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.receipt_long, color: bone, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(
                        color: bone,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Lihatlah rangkuman petualangan kamu',
                      style: TextStyle(
                        color: bone,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pesanan ID',
                style: TextStyle(
                  color: bone,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                bookingId,
                style: const TextStyle(
                  color: bone,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard() {
    final b = _booking;
    if (b == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: mossGreen, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: chiffon,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking Status
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: mossGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pesanan Berhasil!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cafeNoir,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Petualangan pendakian gunung Anda telah berhasil dipesan!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: pine,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Payment Status Section
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: b.isPaid 
                  ? mossGreen.withOpacity(0.12) 
                  : tangerine.withOpacity(0.12),
              border: Border.all(
                color: b.isPaid ? mossGreen : tangerine,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  b.isPaid ? Icons.check_circle : Icons.info_outline,
                  color: b.isPaid ? mossGreen : tangerine,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.isPaid ? 'Pembayaran Dikonfirmasi' : 'Belum Terbayar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: b.isPaid ? mossGreen : tangerine,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.isPaid 
                            ? 'Pembayaran Anda sudah dikonfirmasi' 
                            : 'Silakan lakukan pembayaran untuk melanjutkan',
                        style: TextStyle(
                          fontSize: 12,
                          color: b.isPaid 
                              ? mossGreen.withOpacity(0.8)
                              : tangerine.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMountainInfoCard(Booking b, int pax) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: chiffon,
        border: Border.all(color: tan, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: bone,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.terrain, color: mossGreen, size: 24),
              ),
              const SizedBox(width: 14),
              const Text(
                'Informasi Pendakian',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cafeNoir,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildDetailItem('Gunung', b.gunungNama ?? '-'),
              _buildDetailItem('Tanggal Pemesanan', b.createdAt),
              _buildDetailItem('Tanggal Mulai', _formatDate(b.climbingDate)),
              _buildDetailItem('Tanggal Berakhir', _calculateEndDate(b.climbingDate)),
              _buildDetailItem('Durasi Pendakian', '1 Hari'),
              _buildDetailItemWithIcon(
                'Jasa Porter',
                b.porterRequired ? 'Ya' : 'Tidak',
                b.porterRequired,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: mossGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cafeNoir,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _calculateEndDate(String? startDate) {
    if (startDate == null || startDate.isEmpty) return '-';
    try {
      final start = DateTime.parse(startDate);
      final end = start.add(const Duration(days: 1)); 
      final day = end.day.toString().padLeft(2, '0');
      final month = end.month.toString().padLeft(2, '0');
      return '$day/$month/${end.year}';
    } catch (e) {
      return startDate;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(date);
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      return '$day/$month/${parsed.year}';
    } catch (e) {
      return date;
    }
  }

  Widget _buildDetailItemWithIcon(String label, String value, bool isYes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: mossGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(
              isYes ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: mossGreen,
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cafeNoir,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembersCard(Booking b) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: chiffon,
        border: Border.all(color: tan, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: bone,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people, color: mossGreen, size: 24),
              ),
              const SizedBox(width: 14),
              const Text(
                'Daftar Anggota',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cafeNoir,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          
          if (b.members.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '- Tidak ada anggota tercatat -',
                style: TextStyle(color: tan),
              ),
            )
          else
            Column(
              children: [
                ...b.members.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final m = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: tan, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                        color: chiffon,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: cafeNoir,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.3,
                            children: [
                              _buildMemberDetailItem('Usia:', '${m.age} tahun'),
                              _buildMemberDetailItem('Jenis Kelamin:', _formatGender(m.gender)),
                              _buildMemberDetailItem('Level:', _formatLevel(m.level)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  String _formatGender(String? gender) {
    switch (gender) {
      case 'M':
        return 'Laki-laki';
      case 'F':
        return 'Perempuan';
      case 'O':
        return 'Lainnya';
      default:
        return gender ?? '-';
    }
  }

  String _formatLevel(String? level) {
    switch (level) {
      case 'beginner':
        return 'Pemula';
      case 'intermediate':
        return 'Menengah';
      case 'advanced':
        return 'Mahir';
      default:
        return level ?? 'Pemula';
    }
  }

  Widget _buildMemberDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: mossGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cafeNoir,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCostSummaryCard(int pax, int porter, int total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: chiffon,
        border: Border.all(color: tan, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: bone,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt, color: mossGreen, size: 24),
              ),
              const SizedBox(width: 14),
              const Text(
                'Ringkasan Biaya',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cafeNoir,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

        
          _buildCostItem('Biaya per orang', 'Rp 500.000'),
          const SizedBox(height: 10),
          _buildCostItem('Jumlah peserta', '$pax orang'),
          const SizedBox(height: 10),
          _buildCostItem('Jasa Porter', 'Rp ${porter.toString()}'),
          Divider(color: tan, height: 16, thickness: 1),

        
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              Text(
                'Rp ${total.toString()}',
                style: const TextStyle(
                  fontSize: 17,
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

  Widget _buildCostItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: cafeNoir,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: cafeNoir,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(Booking b) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: chiffon,
        border: Border.all(color: tan, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cafeNoir,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBookingPage(booking: b),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cafeNoir,
                  foregroundColor: bone,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Beranda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cafeNoir,
                  foregroundColor: bone,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(Booking b, int pax, int porter, bool isPaid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isPaid)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    bookingId: b.id.toString(),
                    totalAmount: pax * 500000 + (b.porterRequired ? 250000 : 0),
                    qrisPayload: null,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.payment),
            label: const Text('Bayar Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: mossGreen,
              foregroundColor: bone,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (!isPaid) const SizedBox(height: 14),
        if (isPaid)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: mossGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: mossGreen, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: mossGreen, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Pembayaran Sudah Dikonfirmasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mossGreen,
                  ),
                ),
              ],
            ),
          ),
        if (isPaid) const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali'),
          style: OutlinedButton.styleFrom(
            foregroundColor: cafeNoir,
            side: const BorderSide(color: cafeNoir),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bone,
      appBar: AppNavBar(
        title: 'Ringkasan Pesanan',
        backgroundColor: kombuGreen,
        titleTextStyle: const TextStyle(color: bone, fontWeight: FontWeight.bold),
      ),
      body: _buildBody(),
    );
  }
}
