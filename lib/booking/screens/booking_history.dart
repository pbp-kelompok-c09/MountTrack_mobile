import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _loading = true;
    });
    final request = context.read<CookieRequest>();
    try {
      final resp = await request.get('http://localhost:8000/booking/history/');
      if (resp is List) {
        setState(() {
          _bookings = resp.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: 'Riwayat Booking'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Belum ada riwayat booking.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kembali'),
                      )
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _bookings.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final b = _bookings[index];
                    return ListTile(
                      title: Text(b.gunungNama ?? ''),
                      subtitle: Text('Peserta: ${b.pax} — ${b.createdAt}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingSummaryPage(booking: b),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
