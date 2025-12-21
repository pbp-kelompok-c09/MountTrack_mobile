import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../widgets/app_navbar.dart';
import '../../mountains/screens/all_mountains.dart';
import '../../userprofile/screens/login.dart';
import '../../home/screens/homepage.dart';
import 'booking_form_page.dart';
import 'booking_history.dart';

class BookingLandingPage extends StatelessWidget {
  final VoidCallback? onHome;
  const BookingLandingPage({super.key, this.onHome});


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: 'Booking',
        showBack: false,
        backgroundColor: kombuGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: bone),
        titleTextStyle: const TextStyle(
          color: bone,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      backgroundColor: bone,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: chiffon,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cafeNoir.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemesanan Pendakian',
                      style: TextStyle(
                        color: kombuGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rencanakan pendakianmu dengan aman. Pilih jumlah peserta, tingkat pengalaman, dan kami akan merekomendasikan kebutuhan porter jika diperlukan.',
                      style: TextStyle(
                        color: pine.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final request = context.read<CookieRequest>();
                              if (!request.loggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Silakan login untuk memulai pesanan.')),
                                );
                                return;
                              }

                              // go directly to booking form
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BookingFormPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kombuGreen,
                              foregroundColor: bone,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Mulai Pesanan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllMountainsPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mossGreen,
                            foregroundColor: bone,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Jelajahi Gunung'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Why book with us
              Text(
                'Kenapa Pesan di sini?',
                style: TextStyle(
                  color: cafeNoir,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _featureTile(
                icon: Icons.verified_user,
                title: 'Keamanan & Verifikasi',
                subtitle: 'Data porter dan pemandu diverifikasi untuk keamanan perjalanan.',
                color: mossGreen,
              ),
              _featureTile(
                icon: Icons.group,
                title: 'Pilihan Paket',
                subtitle: 'Kelola jumlah peserta dan level untuk rekomendasi porter otomatis.',
                color: kombuGreen,
              ),
              _featureTile(
                icon: Icons.support_agent,
                title: 'Dukungan 24/7',
                subtitle: 'Bantuan jika diperlukan sebelum, saat, dan sesudah pendakian.',
                color: pine,
              ),

              const SizedBox(height: 36),
              
              // Booking History Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: tan,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sacramento, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Pesanan',
                          style: TextStyle(
                            color: sacramento,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lihat semua Pesanan Anda',
                          style: TextStyle(
                            color: cafeNoir.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingHistoryPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sacramento,
                        foregroundColor: bone,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('Lihat'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              Center(
                child: Text(
                  'Siap untuk petualanganmu?',
                  style: TextStyle(
                    color: sacramento,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Back to Home Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Jika ada callback dari MainNavigation, gunakan itu
                    if (onHome != null) {
                      onHome!();
                    } else {
                      // Fallback: coba pop atau push HomePage
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mossGreen,
                    foregroundColor: bone,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.home, size: 18),
                  label: const Text('Kembali ke Beranda'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureTile({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: cafeNoir, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: cafeNoir.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
